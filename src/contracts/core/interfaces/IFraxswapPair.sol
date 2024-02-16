// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import { IUniswapV2PairV5 } from "./IUniswapV2PairV5.sol";

/// @dev Fraxswap LP Pair Interface
interface IFraxswapPair is IUniswapV2PairV5 {
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
