// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
pragma abicoder v2;

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ===================== Fraxswap Router Multihop =====================
// ====================================================================

import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { SafeCast } from "@uniswap/v3-core/contracts/libraries/SafeCast.sol";
import { IWETH } from "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import { TransferHelper } from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import { IUniswapV3SwapCallback } from "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { IUniswapV2Pair } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

import { IPoolInterface } from "./interfaces/IPoolInterface.sol";
import { IFraxswapRouterMultihop } from "./interfaces/IFraxswapRouterMultihop.sol";

/// @title Fraxswap Router Multihop
/// @dev Router for swapping across the majority of the FRAX liquidity
/// @author Frax Finance (https://github.com/FraxFinance)
contract FraxswapRouterMultihop is ReentrancyGuard, IFraxswapRouterMultihop {
    using SafeCast for uint256;
    using SafeCast for int256;

    IWETH public immutable WETH9;
    address public immutable FRAX;
    bool public immutable CHECK_AMOUNTOUT_IN_ROUTER;

    constructor(IWETH _WETH9, address _FRAX, bool _CHECK_AMOUNTOUT_IN_ROUTER) {
        WETH9 = _WETH9;
        FRAX = _FRAX;
        CHECK_AMOUNTOUT_IN_ROUTER = _CHECK_AMOUNTOUT_IN_ROUTER;
    }

    /// @notice modifier for checking deadline
    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, "Transaction too old");
        _;
    }

    /// @notice accept ETH
    receive() external payable {}

    /// ---------------------------
    /// --------- Public ----------
    /// ---------------------------

    /// @notice Main external swap function
    /// @param params all parameters for this swap
    /// @return amountOut output amount from this swap
    function swap(
        FraxswapParams memory params
    ) external payable nonReentrant checkDeadline(params.deadline) returns (uint256 amountOut) {
        if (params.recipient == address(0)) params.recipient = msg.sender;
        FraxswapRoute memory route = abi.decode(params.route, (FraxswapRoute));
        route.tokenOut = params.tokenIn;
        route.amountOut = params.amountIn;
        FraxswapRoute memory firstRoute = abi.decode(route.nextHops[0], (FraxswapRoute));

        if (params.tokenIn == address(0)) {
            // ETH sent in via msg.value
            require(msg.value == params.amountIn, "FSR:II"); // Insufficient input ETH
        } else if (params.tokenIn == address(WETH9) && msg.value > 0) {
            // ETH sent in via msg.value
            require(msg.value == params.amountIn, "FSR:II"); // Insufficient input ETH
            WETH9.deposit{ value: msg.value }();
        } else {
            require(msg.value == 0, "FSR:IE"); // ETH transfer that is not used, prevent mistakes
            if (params.v != 0) {
                // use permit instead of approval
                uint256 amount = params.approveMax ? type(uint256).max : params.amountIn;
                IERC20Permit(params.tokenIn).permit(
                    msg.sender,
                    address(this),
                    amount,
                    params.deadline,
                    params.v,
                    params.r,
                    params.s
                );
            }
            address targetPool = address(this);
            if (firstRoute.steps.length > 0) {
                FraxswapStepData memory step = abi.decode(firstRoute.steps[0], (FraxswapStepData));
                if (step.directFundThisPool == 1) targetPool = step.pool;
            }
            // Pull tokens into the Router Contract
            TransferHelper.safeTransferFrom(params.tokenIn, msg.sender, targetPool, params.amountIn);
        }
        bool outputETH = params.tokenOut == address(0); // save gas
        uint256 initialBalance;
        if (!CHECK_AMOUNTOUT_IN_ROUTER) {
            initialBalance = outputETH ? params.recipient.balance : IERC20(params.tokenOut).balanceOf(params.recipient);
        }
        for (uint256 i; i < route.nextHops.length; ++i) {
            FraxswapRoute memory nextRoute = i == 0 ? firstRoute : abi.decode(route.nextHops[i], (FraxswapRoute));
            executeAllHops(route, nextRoute, params.recipient);
        }

        amountOut = outputETH ? address(this).balance : IERC20(params.tokenOut).balanceOf(address(this));

        if (outputETH && amountOut == 0) {
            amountOut = IERC20(address(WETH9)).balanceOf(address(this));
            if (amountOut > 0) WETH9.withdraw(amountOut);
        }

        if (amountOut > 0) {
            if (outputETH) {
                // sending ETH
                (bool success, ) = payable(params.recipient).call{ value: amountOut }("");
                require(success, "FSR:Invalid transfer");
            } else {
                TransferHelper.safeTransfer(params.tokenOut, params.recipient, amountOut);
            }
        }
        if (!CHECK_AMOUNTOUT_IN_ROUTER) {
            amountOut = outputETH
                ? params.recipient.balance
                : IERC20(params.tokenOut).balanceOf(params.recipient) - initialBalance;
        }

        // Check output amounts (IMPORTANT CHECK)
        require(amountOut >= params.amountOutMinimum, "FSR:IO"); // Insufficient output

        emit Routed(params.tokenIn, params.tokenOut, params.amountIn, amountOut);
    }

    /// @notice Uniswap V3 callback function
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata _data) external {
        require(amount0Delta > 0 || amount1Delta > 0);
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        if (!data.directFundThisPool) {
            // it isn't directly funded we pay from the router address
            TransferHelper.safeTransfer(
                data.tokenIn,
                msg.sender,
                uint256(amount0Delta > 0 ? amount0Delta : amount1Delta)
            );
        }
    }

    /// ---------------------------
    /// --------- Internal --------
    /// ---------------------------

    /// @notice Function that will execute a particular swap step
    /// @param prevRoute previous hop of the route
    /// @param route current hop of the route
    /// @param step swap to execute
    /// @return amountOut actual output from this swap step
    function executeSwap(
        FraxswapRoute memory prevRoute,
        FraxswapRoute memory route,
        FraxswapStepData memory step,
        address recipient
    ) internal returns (uint256 amountOut) {
        uint256 amountIn = getAmountForPct(step.percentOfHop, route.percentOfHop, prevRoute.amountOut);
        if (step.swapType < 2) {
            // Fraxswap/Uni v2
            bool zeroForOne = (step.extraParam2 == 0 && prevRoute.tokenOut < step.tokenOut) || step.extraParam2 == 1;
            if (step.swapType == 0) {
                // Execute virtual orders for Fraxswap
                IPoolInterface(step.pool).executeVirtualOrders(block.timestamp);
            }
            if (step.extraParam1 == 1) {
                // Fraxswap V2 has getAmountOut in the pair (different fees)
                amountOut = IPoolInterface(step.pool).getAmountOut(amountIn, prevRoute.tokenOut);
            } else {
                // use the reserves and helper function for Uniswap V2 and Fraxswap V1
                (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(step.pool).getReserves();
                amountOut = getAmountOut(amountIn, zeroForOne ? reserve0 : reserve1, zeroForOne ? reserve1 : reserve0);
            }
            if (step.directFundThisPool == 0) {
                // this pool is funded by router
                TransferHelper.safeTransfer(prevRoute.tokenOut, step.pool, amountIn);
            }
            IUniswapV2Pair(step.pool).swap(
                zeroForOne ? 0 : amountOut,
                zeroForOne ? amountOut : 0,
                step.directFundNextPool == 1 ? getNextDirectFundingPool(route, recipient) : address(this),
                new bytes(0)
            );
        } else if (step.swapType == 2) {
            // Uni v3
            bool zeroForOne = (step.extraParam2 == 0 && prevRoute.tokenOut < step.tokenOut) || step.extraParam2 == 1;
            bytes memory callBackData = abi.encode(
                SwapCallbackData({ tokenIn: prevRoute.tokenOut, directFundThisPool: step.directFundThisPool == 1 })
            );
            (int256 amount0, int256 amount1) = IUniswapV3Pool(step.pool).swap(
                step.directFundNextPool == 1 ? getNextDirectFundingPool(route, recipient) : address(this),
                zeroForOne,
                amountIn.toInt256(),
                zeroForOne ? 4_295_128_740 : 1_461_446_703_485_210_103_287_273_052_203_988_822_378_723_970_341, // Do not fail because of price
                callBackData
            );
            amountOut = uint256(zeroForOne ? -amount1 : -amount0);
        } else if (step.swapType == 3) {
            // Curve exchange V2
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            IPoolInterface(step.pool).exchange(step.extraParam1, step.extraParam2, amountIn, 0);
            amountOut = IERC20(step.tokenOut).balanceOf(address(this));
        } else if (step.swapType == 4) {
            // Curve exchange, with returns (no ETH)
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            amountOut = IPoolInterface(step.pool).exchange(
                int128(int256(step.extraParam1)),
                int128(int256(step.extraParam2)),
                amountIn,
                0
            );
        } else if (step.swapType == 5) {
            // Curve exchange_underlying
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            amountOut = IPoolInterface(step.pool).exchange_underlying(
                int128(int256(step.extraParam1)),
                int128(int256(step.extraParam2)),
                amountIn,
                0
            );
        } else if (step.swapType == 6) {
            // Saddle
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            amountOut = IPoolInterface(step.pool).swap(
                uint8(step.extraParam1),
                uint8(step.extraParam2),
                amountIn,
                0,
                block.timestamp
            );
        } else if (step.swapType == 7) {
            // FPIController
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            if (prevRoute.tokenOut == FRAX) {
                amountOut = IPoolInterface(step.pool).mintFPI(amountIn, 0);
            } else {
                amountOut = IPoolInterface(step.pool).redeemFPI(amountIn, 0);
            }
        } else if (step.swapType == 8) {
            // ERC4626/Fraxlend deposit
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            amountOut = IPoolInterface(step.pool).deposit(
                amountIn,
                step.directFundNextPool == 1 ? getNextDirectFundingPool(route, recipient) : address(this)
            );
        } else if (step.swapType == 9) {
            // FrxETHMinter
            if (step.extraParam1 == 0 && prevRoute.tokenOut == address(WETH9)) {
                // Unwrap WETH
                WETH9.withdraw(amountIn);
            }
            IPoolInterface(step.pool).submitAndGive{ value: amountIn }(
                step.directFundNextPool == 1 ? getNextDirectFundingPool(route, recipient) : address(this)
            );
            amountOut = amountIn; // exchange 1 for 1
        } else if (step.swapType == 10) {
            // WETH
            if (prevRoute.tokenOut == address(WETH9)) {
                // Unwrap WETH
                WETH9.withdraw(amountIn);
            } else {
                // Wrap the ETH
                WETH9.deposit{ value: amountIn }();
            }
            amountOut = amountIn; // exchange 1 for 1
        } else if (step.swapType == 11) {
            // Curve exchange, with returns and ETH
            uint256 value = 0;
            if (prevRoute.tokenOut == address(WETH9)) {
                // WETH send as ETH
                WETH9.withdraw(amountIn);
                value = amountIn;
            } else if (prevRoute.tokenOut == address(0)) {
                value = amountIn;
            } else {
                TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            }
            amountOut = IPoolInterface(step.pool).exchange{ value: value }(
                int128(int256(step.extraParam1)),
                int128(int256(step.extraParam2)),
                amountIn,
                0
            );
            if (route.tokenOut == address(WETH9)) {
                // Wrap the received ETH as WETH
                WETH9.deposit{ value: amountOut }();
            }
        } else if (step.swapType == 12) {
            // Curve exchange_received (NG)
            if (step.directFundThisPool == 0) {
                // this pool is funded by router
                TransferHelper.safeTransfer(prevRoute.tokenOut, step.pool, amountIn);
            }
            amountOut = IPoolInterface(step.pool).exchange_received(
                int128(int256(step.extraParam1)),
                int128(int256(step.extraParam2)),
                amountIn,
                0,
                step.directFundNextPool == 1 ? getNextDirectFundingPool(route, recipient) : address(this)
            );
        } else if (step.swapType == 13) {
            // Redeem ERC4626
            amountOut = IPoolInterface(step.pool).redeem(
                amountIn,
                step.directFundNextPool == 1 ? getNextDirectFundingPool(route, recipient) : address(this),
                address(this)
            );
        } else if (step.swapType == 14) {
            // Curve exchange, with returns + receiver (no ETH)
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            amountOut = IPoolInterface(step.pool).exchange(
                int128(int256(step.extraParam1)),
                int128(int256(step.extraParam2)),
                amountIn,
                0,
                step.directFundNextPool == 1 ? getNextDirectFundingPool(route, recipient) : address(this)
            );
        } else if (step.swapType == 255) {
            // Delegatecall
            bytes4 signature = bytes4(uint32(step.extraParam1));
            (bool success, bytes memory data) = address(address(uint160(step.extraParam1 >> 32))).delegatecall(
                abi.encodeWithSelector(
                    signature,
                    prevRoute.tokenOut,
                    step.tokenOut,
                    amountIn,
                    step.pool,
                    step.directFundThisPool,
                    step.directFundNextPool == 1 ? getNextDirectFundingPool(route, recipient) : address(this),
                    step.extraParam2
                )
            );
            require(success, "FSR:Delecatecall failed");
            amountOut = abi.decode(data, (uint256));
        }
    }

    /// @notice Function that will loop through and execute swap steps
    /// @param prevRoute previous hop of the route
    /// @param route current hop of the route
    function executeAllStepsForRoute(
        FraxswapRoute memory prevRoute,
        FraxswapRoute memory route,
        address recipient
    ) internal {
        for (uint256 j; j < route.steps.length; ++j) {
            FraxswapStepData memory step = abi.decode(route.steps[j], (FraxswapStepData));
            route.amountOut += executeSwap(
                prevRoute,
                route,
                step,
                j == route.steps.length - 1 ? recipient : address(0)
            );
        }
    }

    /// @notice Function that will loop through and execute route hops and execute all steps for each hop
    /// @param prevRoute previous hop of the route
    /// @param route current hop of the route
    function executeAllHops(FraxswapRoute memory prevRoute, FraxswapRoute memory route, address recipient) internal {
        executeAllStepsForRoute(prevRoute, route, route.nextHops.length == 0 ? recipient : address(0));
        for (uint256 i; i < route.nextHops.length; ++i) {
            FraxswapRoute memory nextRoute = abi.decode(route.nextHops[i], (FraxswapRoute));
            executeAllHops(route, nextRoute, recipient);
        }
    }

    /// ---------------------------
    /// ------ Views / Pure -------
    /// ---------------------------

    /// @notice Utility function to build an encoded hop of route
    /// @param tokenOut output token address
    /// @param percentOfHop amount of output tokens from the previous hop going into this hop
    /// @param steps list of swaps from the same input token to the same output token
    /// @param nextHops next hops from this one, the next hops' input token is the tokenOut
    /// @return out encoded FraxswapRoute
    function encodeRoute(
        address tokenOut,
        uint256 percentOfHop,
        bytes[] memory steps,
        bytes[] memory nextHops
    ) external pure returns (bytes memory out) {
        FraxswapRoute memory route;
        route.tokenOut = tokenOut;
        route.amountOut = 0;
        route.percentOfHop = percentOfHop;
        route.steps = steps;
        route.nextHops = nextHops;
        out = abi.encode(route);
    }

    /// @notice Utility function to build an encoded step
    /// @param swapType type of the swap performed (Uniswap V2, Fraxswap,Curve, etc)
    /// @param directFundNextPool 0 = funds go via router, 1 = fund are sent directly to pool
    /// @param directFundThisPool 0 = funds go via router, 1 = fund are sent directly to pool
    /// @param tokenOut the target token of the step. output token address
    /// @param pool address of the pool to use in the step
    /// @param extraParam1 extra data used in the step
    /// @param extraParam2 extra data used in the step
    /// @param percentOfHop percentage of all of the steps in this route (hop)
    /// @return out encoded FraxswapStepData
    function encodeStep(
        uint8 swapType,
        uint8 directFundNextPool,
        uint8 directFundThisPool,
        address tokenOut,
        address pool,
        uint256 extraParam1,
        uint256 extraParam2,
        uint256 percentOfHop
    ) external pure returns (bytes memory out) {
        FraxswapStepData memory step;
        step.swapType = swapType;
        step.directFundNextPool = directFundNextPool;
        step.directFundThisPool = directFundThisPool;
        step.tokenOut = tokenOut;
        step.pool = pool;
        step.extraParam1 = extraParam1;
        step.extraParam2 = extraParam2;
        step.percentOfHop = percentOfHop;
        out = abi.encode(step);
    }

    /// @notice Utility function to calculate the amount given the percentage of hop and route 10000 = 100%
    /// @return amountOut amount of input token
    function getAmountForPct(
        uint256 pctOfHop1,
        uint256 pctOfHop2,
        uint256 amountIn
    ) internal pure returns (uint256 amountOut) {
        return (pctOfHop1 * pctOfHop2 * amountIn) / 100_000_000;
    }

    /// @notice Utility function to get the next pool to directly fund
    /// @return nextPoolAddress address of the next pool
    function getNextDirectFundingPool(
        FraxswapRoute memory route,
        address recipient
    ) internal pure returns (address nextPoolAddress) {
        if (recipient != address(0)) return recipient;
        require(route.steps.length == 1 && route.nextHops.length == 1, "FSR: DFRoutes"); // directFunding
        FraxswapRoute memory nextRoute = abi.decode(route.nextHops[0], (FraxswapRoute));

        require(nextRoute.steps.length == 1, "FSR: DFSteps"); // directFunding
        FraxswapStepData memory nextStep = abi.decode(nextRoute.steps[0], (FraxswapStepData));

        return nextStep.pool; // pool to send funds to
    }

    /// @notice given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    /// @return amountOut constant product curve expected output amount
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
