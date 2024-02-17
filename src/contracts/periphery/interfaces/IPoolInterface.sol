// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Interface used to call pool specific functions
interface IPoolInterface {
    // Fraxswap
    function executeVirtualOrders(uint256 blockNumber) external;

    function getAmountOut(uint256 amountIn, address tokenIn) external view returns (uint256);

    // Fraxlend
    function deposit(uint256 userId, address userAddress) external returns (uint256 _sharesReceived);

    // FrxETHMinter
    function submitAndGive(address recipient) external payable;

    // Curve
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external;

    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external payable returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address receiver
    ) external payable returns (uint256);

    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);

    function exchange_received(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address receiver
    ) external returns (uint256);

    // Saddle
    function swap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx,
        uint256 minDy,
        uint256 deadline
    ) external returns (uint256);

    //FPI Mint/Redeem
    function mintFPI(uint256 frax_in, uint256 min_fpi_out) external returns (uint256 fpi_out);

    function redeemFPI(uint256 fpi_in, uint256 min_frax_out) external returns (uint256 frax_out);

    // ERC4626 redeem
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    // generic swap wrapper
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address target
    ) external returns (uint256 amountOut);
}
