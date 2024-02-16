pragma solidity >=0.6.6;

import "src/contracts/core/interfaces/IFraxswapPair.sol";
import "src/contracts/libraries/Babylonian.sol";
import "src/contracts/libraries/TransferHelper.sol";

import "src/contracts/periphery/libraries/UniswapV2LiquidityMathLibrary.sol";
import "src/contracts/periphery/interfaces/IERC20.sol";
import "src/contracts/periphery/interfaces/IUniswapV2Router01V5.sol";
import "src/contracts/periphery/libraries/SafeMath.sol";
import "src/contracts/periphery/libraries/FraxswapRouterLibrary.sol";

contract ExampleSwapToPrice {
    using SafeMath for uint256;

    IUniswapV2Router01V5 public immutable router;
    address public immutable factory;

    constructor(address factory_, IUniswapV2Router01V5 router_) {
        factory = factory_;
        router = router_;
    }

    // swaps an amount of either token such that the trade is profit-maximizing, given an external true price
    // true price is expressed in the ratio of token A to token B
    // caller must approve this contract to spend whichever token is intended to be swapped
    function swapToPrice(
        address tokenA,
        address tokenB,
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 maxSpendTokenA,
        uint256 maxSpendTokenB,
        address to,
        uint256 deadline
    ) public {
        // true price is expressed as a ratio, so both values must be non-zero
        require(truePriceTokenA != 0 && truePriceTokenB != 0, "ExampleSwapToPrice: ZERO_PRICE");
        // caller can specify 0 for either if they wish to swap in only one direction, but not both
        require(maxSpendTokenA != 0 || maxSpendTokenB != 0, "ExampleSwapToPrice: ZERO_SPEND");

        bool aToB;
        uint256 amountIn;
        {
            (uint256 reserveA, uint256 reserveB) = FraxswapRouterLibrary.getReserves(factory, tokenA, tokenB);

            IFraxswapPair pair = IFraxswapPair(FraxswapRouterLibrary.pairFor(factory, tokenA, tokenB));
            (aToB, amountIn) = UniswapV2LiquidityMathLibrary.computeProfitMaximizingTrade(
                truePriceTokenA,
                truePriceTokenB,
                reserveA,
                reserveB,
                pair.fee()
            );
        }

        require(amountIn > 0, "ExampleSwapToPrice: ZERO_AMOUNT_IN");

        // spend up to the allowance of the token in
        uint256 maxSpend = aToB ? maxSpendTokenA : maxSpendTokenB;
        if (amountIn > maxSpend) {
            amountIn = maxSpend;
        }

        address tokenIn = aToB ? tokenA : tokenB;
        address tokenOut = aToB ? tokenB : tokenA;
        TransferHelper.safeTransferFrom(tokenIn, msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(tokenIn, address(router), amountIn);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        router.swapExactTokensForTokens(
            amountIn,
            0, // amountOutMin: we can skip computing this number because the math is tested
            path,
            to,
            deadline
        );
    }
}