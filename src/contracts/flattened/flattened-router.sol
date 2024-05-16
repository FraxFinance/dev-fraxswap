// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

// lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// src/contracts/libraries/TransferHelper.sol

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{ value: value }(new bytes(0));
        require(success, "TransferHelper::safeTransferETH: ETH transfer failed");
    }
}

// src/contracts/periphery/interfaces/IWETH.sol

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

// src/contracts/core/interfaces/IFraxswapFactory.sol

interface IFraxswapFactory is IUniswapV2Factory {
    function createPair(address tokenA, address tokenB, uint256 fee) external returns (address pair);
    function globalPause() external view returns (bool);
    function toggleGlobalPause() external;
}

// src/contracts/core/interfaces/IFraxswapPair.sol

/// @dev Fraxswap LP Pair Interface
interface IFraxswapPair is IUniswapV2Pair {
    // TWAMM

    event LongTermSwap0To1(address indexed addr, uint256 orderId, uint256 amount0In, uint256 numberOfTimeIntervals);
    event LongTermSwap1To0(address indexed addr, uint256 orderId, uint256 amount1In, uint256 numberOfTimeIntervals);
    event CancelLongTermOrder(
        address indexed addr,
        uint256 orderId,
        address sellToken,
        uint256 unsoldAmount,
        address buyToken,
        uint256 purchasedAmount
    );
    event WithdrawProceedsFromLongTermOrder(
        address indexed addr,
        uint256 orderId,
        address indexed proceedToken,
        uint256 proceeds,
        bool orderExpired
    );

    function fee() external view returns (uint256);

    function longTermSwapFrom0To1(uint256 amount0In, uint256 numberOfTimeIntervals) external returns (uint256 orderId);
    function longTermSwapFrom1To0(uint256 amount1In, uint256 numberOfTimeIntervals) external returns (uint256 orderId);
    function cancelLongTermSwap(uint256 orderId) external;
    function withdrawProceedsFromLongTermSwap(
        uint256 orderId
    ) external returns (bool is_expired, address rewardTkn, uint256 totalReward);
    function executeVirtualOrders(uint256 blockTimestamp) external;

    function getAmountOut(uint256 amountIn, address tokenIn) external view returns (uint256);
    function getAmountIn(uint256 amountOut, address tokenOut) external view returns (uint256);

    function orderTimeInterval() external returns (uint256);
    function getTWAPHistoryLength() external view returns (uint256);
    function getTwammReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast,
            uint112 _twammReserve0,
            uint112 _twammReserve1,
            uint256 _fee
        );
    function getReserveAfterTwamm(
        uint256 blockTimestamp
    )
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint256 lastVirtualOrderTimestamp,
            uint112 _twammReserve0,
            uint112 _twammReserve1
        );
    function getNextOrderID() external view returns (uint256);
    function getOrderIDsForUser(address user) external view returns (uint256[] memory);
    function getOrderIDsForUserLength(address user) external view returns (uint256);
    function twammUpToDate() external view returns (bool);
    function getTwammState()
        external
        view
        returns (
            uint256 token0Rate,
            uint256 token1Rate,
            uint256 lastVirtualOrderTimestamp,
            uint256 orderTimeInterval_rtn,
            uint256 rewardFactorPool0,
            uint256 rewardFactorPool1
        );
    function getTwammSalesRateEnding(
        uint256 _blockTimestamp
    ) external view returns (uint256 orderPool0SalesRateEnding, uint256 orderPool1SalesRateEnding);
    function getTwammRewardFactor(
        uint256 _blockTimestamp
    ) external view returns (uint256 rewardFactorPool0AtTimestamp, uint256 rewardFactorPool1AtTimestamp);
    function getTwammOrder(
        uint256 orderId
    )
        external
        view
        returns (
            uint256 id,
            uint256 creationTimestamp,
            uint256 expirationTimestamp,
            uint256 saleRate,
            address owner,
            address sellTokenAddr,
            address buyTokenAddr
        );
    function getTwammOrderProceedsView(
        uint256 orderId,
        uint256 blockTimestamp
    ) external view returns (bool orderExpired, uint256 totalReward);
    function getTwammOrderProceeds(uint256 orderId) external returns (bool orderExpired, uint256 totalReward);

    function togglePauseNewSwaps() external;
}

// src/contracts/periphery/FraxswapRouterLibrary.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ======================= FraxswapRouterLibrary ======================
// ====================================================================

/// @notice Fraxswap Router Library Functions
/// @author Frax Finance: https://github.com/FraxFinance
library FraxswapRouterLibrary {
    bytes public constant INIT_CODE_HASH = hex"46dd19aa7d926c9d41df47574e3c09b978a1572918da0e3da18ad785c1621d48"; // init code / init hash

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "FraxswapRouterLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "FraxswapRouterLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            INIT_CODE_HASH // init code / init hash
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);

        (uint256 reserve0, uint256 reserve1, ) = IFraxswapPair(pairFor(factory, tokenA, tokenB)).getReserves();

        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function getReservesWithTwamm(
        address factory,
        address tokenA,
        address tokenB
    ) internal returns (uint256 reserveA, uint256 reserveB, uint256 twammReserveA, uint256 twammReserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);

        IFraxswapPair pair = IFraxswapPair(pairFor(factory, tokenA, tokenB));

        pair.executeVirtualOrders(block.timestamp);

        (uint256 reserve0, uint256 reserve1, , uint256 twammReserve0, uint256 twammReserve1, ) = pair
            .getTwammReserves();

        (reserveA, reserveB, twammReserveA, twammReserveB) = tokenA == token0
            ? (reserve0, reserve1, twammReserve0, twammReserve1)
            : (reserve1, reserve0, twammReserve1, twammReserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        require(amountA > 0, "FraxswapRouterLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "FraxswapRouterLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = (amountA * reserveB) / reserveA;
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "FraxswapRouterLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            IFraxswapPair pair = IFraxswapPair(FraxswapRouterLibrary.pairFor(factory, path[i], path[i + 1]));
            require(pair.twammUpToDate(), "twamm out of date");
            amounts[i + 1] = pair.getAmountOut(amounts[i], path[i]);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "FraxswapRouterLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            IFraxswapPair pair = IFraxswapPair(FraxswapRouterLibrary.pairFor(factory, path[i - 1], path[i]));
            require(pair.twammUpToDate(), "twamm out of date");
            amounts[i - 1] = pair.getAmountIn(amounts[i], path[i - 1]);
        }
    }

    // performs chained getAmountOut calculations on any number of pairs with Twamm
    function getAmountsOutWithTwamm(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal returns (uint256[] memory amounts) {
        require(path.length >= 2, "FraxswapRouterLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            IFraxswapPair pair = IFraxswapPair(FraxswapRouterLibrary.pairFor(factory, path[i], path[i + 1]));
            pair.executeVirtualOrders(block.timestamp);
            amounts[i + 1] = pair.getAmountOut(amounts[i], path[i]);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs with Twamm
    function getAmountsInWithTwamm(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal returns (uint256[] memory amounts) {
        require(path.length >= 2, "FraxswapRouterLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            IFraxswapPair pair = IFraxswapPair(FraxswapRouterLibrary.pairFor(factory, path[i - 1], path[i]));
            pair.executeVirtualOrders(block.timestamp);
            amounts[i - 1] = pair.getAmountIn(amounts[i], path[i - 1]);
        }
    }
}

// src/contracts/periphery/FraxswapRouter.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== FraxswapRouter ==========================
// ====================================================================

/// @notice TWAMM Router
/// @author Frax Finance (https://github.com/FraxFinance)
contract FraxswapRouter {
    address public immutable factory;
    address public immutable WETH;

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "FraxswapV1Router: EXPIRED");
        _;
    }

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function INIT_CODE_HASH() public pure returns (bytes memory hash) {
        return FraxswapRouterLibrary.INIT_CODE_HASH;
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        // create the pair if it doesn't exist yet
        if (IFraxswapFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IFraxswapFactory(factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB, , ) = FraxswapRouterLibrary.getReservesWithTwamm(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = FraxswapRouterLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "FraxswapV1Router: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = FraxswapRouterLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, "FraxswapV1Router: INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external virtual ensure(deadline) returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = FraxswapRouterLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IFraxswapPair(pair).mint(to);
    }

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable virtual ensure(deadline) returns (uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = FraxswapRouterLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{ value: amountETH }();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IFraxswapPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) public virtual ensure(deadline) returns (uint256 amountA, uint256 amountB) {
        address pair = FraxswapRouterLibrary.pairFor(factory, tokenA, tokenB);
        IFraxswapPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IFraxswapPair(pair).burn(to);
        (address token0, ) = FraxswapRouterLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "FraxswapV1Router: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "FraxswapV1Router: INSUFFICIENT_B_AMOUNT");
    }

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public virtual ensure(deadline) returns (uint256 amountToken, uint256 amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual returns (uint256 amountA, uint256 amountB) {
        address pair = FraxswapRouterLibrary.pairFor(factory, tokenA, tokenB);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IFraxswapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual returns (uint256 amountToken, uint256 amountETH) {
        address pair = FraxswapRouterLibrary.pairFor(factory, token, WETH);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IFraxswapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public virtual ensure(deadline) returns (uint256 amountETH) {
        (, amountETH) = removeLiquidity(token, WETH, liquidity, amountTokenMin, amountETHMin, address(this), deadline);
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual returns (uint256 amountETH) {
        address pair = FraxswapRouterLibrary.pairFor(factory, token, WETH);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IFraxswapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint256[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = FraxswapRouterLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2 ? FraxswapRouterLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IFraxswapPair(FraxswapRouterLibrary.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual ensure(deadline) returns (uint256[] memory amounts) {
        amounts = FraxswapRouterLibrary.getAmountsOutWithTwamm(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FraxswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            FraxswapRouterLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual ensure(deadline) returns (uint256[] memory amounts) {
        amounts = FraxswapRouterLibrary.getAmountsInWithTwamm(factory, amountOut, path);
        require(amounts[0] <= amountInMax, "FraxswapV1Router: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            FraxswapRouterLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual ensure(deadline) returns (uint256[] memory amounts) {
        require(path[0] == WETH, "FraxswapV1Router: INVALID_PATH");
        amounts = FraxswapRouterLibrary.getAmountsOutWithTwamm(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FraxswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(WETH).deposit{ value: amounts[0] }();
        assert(IWETH(WETH).transfer(FraxswapRouterLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual ensure(deadline) returns (uint256[] memory amounts) {
        require(path[path.length - 1] == WETH, "FraxswapV1Router: INVALID_PATH");
        amounts = FraxswapRouterLibrary.getAmountsInWithTwamm(factory, amountOut, path);
        require(amounts[0] <= amountInMax, "FraxswapV1Router: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            FraxswapRouterLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual ensure(deadline) returns (uint256[] memory amounts) {
        require(path[path.length - 1] == WETH, "FraxswapV1Router: INVALID_PATH");
        amounts = FraxswapRouterLibrary.getAmountsOutWithTwamm(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FraxswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            FraxswapRouterLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual ensure(deadline) returns (uint256[] memory amounts) {
        require(path[0] == WETH, "FraxswapV1Router: INVALID_PATH");
        amounts = FraxswapRouterLibrary.getAmountsInWithTwamm(factory, amountOut, path);
        require(amounts[0] <= msg.value, "FraxswapV1Router: EXCESSIVE_INPUT_AMOUNT");
        IWETH(WETH).deposit{ value: amounts[0] }();
        assert(IWETH(WETH).transfer(FraxswapRouterLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = FraxswapRouterLibrary.sortTokens(input, output);
            IFraxswapPair pair = IFraxswapPair(FraxswapRouterLibrary.pairFor(factory, input, output));
            uint256 amountInput;
            uint256 amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint256 reserveInput, , uint256 twammReserveInput, ) = FraxswapRouterLibrary.getReservesWithTwamm(
                    factory,
                    input,
                    output
                );
                amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput - twammReserveInput;
                amountOutput = pair.getAmountOut(amountInput, input);
            }
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
            address to = i < path.length - 2 ? FraxswapRouterLibrary.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            FraxswapRouterLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            "FraxswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual ensure(deadline) {
        require(path[0] == WETH, "FraxswapV1Router: INVALID_PATH");
        uint256 amountIn = msg.value;
        IWETH(WETH).deposit{ value: amountIn }();
        assert(IWETH(WETH).transfer(FraxswapRouterLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            "FraxswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual ensure(deadline) {
        require(path[path.length - 1] == WETH, "FraxswapV1Router: INVALID_PATH");
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            FraxswapRouterLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, "FraxswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) public pure virtual returns (uint256 amountB) {
        return FraxswapRouterLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint256, uint256, uint256) public pure virtual returns (uint256) {
        revert("Deprecated: Use getAmountsOut"); // depends on the fee of the pool
    }

    function getAmountIn(uint256, uint256, uint256) public pure virtual returns (uint256) {
        revert("Deprecated: Use getAmountsIn"); // depends on the fee of the pool
    }

    function getAmountsOut(
        uint256 amountIn,
        address[] memory path
    ) public view virtual returns (uint256[] memory amounts) {
        return FraxswapRouterLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(
        uint256 amountOut,
        address[] memory path
    ) public view virtual returns (uint256[] memory amounts) {
        return FraxswapRouterLibrary.getAmountsIn(factory, amountOut, path);
    }

    function getAmountsOutWithTwamm(uint256 amountIn, address[] memory path) public returns (uint256[] memory amounts) {
        return FraxswapRouterLibrary.getAmountsOutWithTwamm(factory, amountIn, path);
    }

    function getAmountsInWithTwamm(uint256 amountOut, address[] memory path) public returns (uint256[] memory amounts) {
        return FraxswapRouterLibrary.getAmountsInWithTwamm(factory, amountOut, path);
    }
}
