// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFraxswapRouterMultihop {
    /// @notice Input to the swap function
    /// @dev contains the top level info for the swap
    /// @param tokenIn input token address
    /// @param amountIn input token amount
    /// @param tokenOut output token address
    /// @param amountOutMinimum output token minimum amount (reverts if lower)
    /// @param recipient recipient of the output token
    /// @param deadline deadline for this swap transaction (reverts if exceeded)
    /// @param v v value for permit signature if supported
    /// @param r r value for permit signature if supported
    /// @param s s value for permit signature if supported
    /// @param route byte encoded
    struct FraxswapParams {
        address tokenIn;
        uint256 amountIn;
        address tokenOut;
        uint256 amountOutMinimum;
        address recipient;
        uint256 deadline;
        bool approveMax;
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes route;
    }

    /// @notice A hop along the swap route
    /// @dev a series of swaps (steps) containing the same input token and output token
    /// @param tokenOut output token address
    /// @param amountOut output token amount
    /// @param percentOfHop amount of output tokens from the previous hop going into this hop
    /// @param steps list of swaps from the same input token to the same output token
    /// @param nextHops next hops from this one, the next hops' input token is the tokenOut
    struct FraxswapRoute {
        address tokenOut;
        uint256 amountOut;
        uint256 percentOfHop;
        bytes[] steps;
        bytes[] nextHops;
    }

    /// @notice A swap step in a specific route. routes can have multiple swap steps
    /// @dev a single swap to a token from the token of the previous hop in the route
    /// @param swapType type of the swap performed (Uniswap V2, Fraxswap,Curve, etc)
    /// @param directFundNextPool 0 = funds go via router, 1 = fund are sent directly to pool
    /// @param directFundThisPool 0 = funds go via router, 1 = fund are sent directly to pool
    /// @param tokenOut the target token of the step. output token address
    /// @param pool address of the pool to use in the step
    /// @param extraParam1 extra data used in the step
    /// @param extraParam2 extra data used in the step
    /// @param percentOfHop percentage of all of the steps in this route (hop)
    struct FraxswapStepData {
        uint8 swapType;
        uint8 directFundNextPool;
        uint8 directFundThisPool;
        address tokenOut;
        address pool;
        uint256 extraParam1;
        uint256 extraParam2;
        uint256 percentOfHop;
    }

    /// @notice struct for Uniswap V3 callback
    /// @param tokenIn address of input token
    /// @param directFundThisPool this pool already been funded
    struct SwapCallbackData {
        address tokenIn;
        bool directFundThisPool;
    }

    /// @notice Routing event emitted every swap
    /// @param tokenIn address of the original input token
    /// @param tokenOut address of the final output token
    /// @param amountIn input amount for original input token
    /// @param amountOut output amount for the final output token
    event Routed(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    function encodeRoute(
        address tokenOut,
        uint256 percentOfHop,
        bytes[] memory steps,
        bytes[] memory nextHops
    ) external pure returns (bytes memory out);
    function encodeStep(
        uint8 swapType,
        uint8 directFundNextPool,
        uint8 directFundThisPool,
        address tokenOut,
        address pool,
        uint256 extraParam1,
        uint256 extraParam2,
        uint256 percentOfHop
    ) external pure returns (bytes memory out);
    function swap(FraxswapParams memory params) external payable returns (uint256 amountOut);
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes memory _data) external;
}
