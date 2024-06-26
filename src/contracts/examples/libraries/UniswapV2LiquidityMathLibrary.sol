pragma solidity ^0.8.0;

import "src/contracts/core/interfaces/IFraxswapPair.sol";
import "src/contracts/core/interfaces/IFraxswapFactory.sol";

import "src/contracts/periphery/FraxswapRouterLibrary.sol";
import "./FullMath.sol";
import "./Babylonian.sol";

// library containing some math for dealing with the liquidity shares of a pair, e.g. computing their exact value
// in terms of the underlying tokens
library UniswapV2LiquidityMathLibrary {
    // computes the direction and magnitude of the profit-maximizing trade
    function computeProfitMaximizingTrade(
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 reserveA,
        uint256 reserveB,
        uint256 fee
    ) internal pure returns (bool aToB, uint256 amountIn) {
        aToB = FullMath.mulDiv(reserveA, truePriceTokenB, reserveB) < truePriceTokenA;

        uint256 invariant = reserveA * reserveB;

        uint256 leftSide = Babylonian.sqrt(
            FullMath.mulDiv(
                invariant * 10_000,
                aToB ? truePriceTokenA : truePriceTokenB,
                (aToB ? truePriceTokenB : truePriceTokenA) * fee
            )
        );
        uint256 rightSide = ((aToB ? reserveA : reserveB) * 10_000) / fee;

        if (leftSide < rightSide) return (false, 0);

        // compute the amount that must be sent to move the price to the profit-maximizing price
        amountIn = leftSide - rightSide;
    }

    // gets the reserves after an arbitrage moves the price to the profit-maximizing ratio given an externally observed true price
    function getReservesAfterArbitrage(
        address factory,
        address tokenA,
        address tokenB,
        uint256 truePriceTokenA,
        uint256 truePriceTokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        // first get reserves before the swap
        (reserveA, reserveB) = FraxswapRouterLibrary.getReserves(factory, tokenA, tokenB);

        require(reserveA > 0 && reserveB > 0, "UniswapV2ArbitrageLibrary: ZERO_PAIR_RESERVES");

        IFraxswapPair pair = IFraxswapPair(FraxswapRouterLibrary.pairFor(factory, tokenA, tokenB));

        uint256 fee = pair.fee();

        // then compute how much to swap to arb to the true price
        (bool aToB, uint256 amountIn) = computeProfitMaximizingTrade(
            truePriceTokenA,
            truePriceTokenB,
            reserveA,
            reserveB,
            fee
        );

        if (amountIn == 0) {
            return (reserveA, reserveB);
        }

        // now affect the trade to the reserves
        if (aToB) {
            uint256 amountOut = pair.getAmountOut(amountIn, tokenA);
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            uint256 amountOut = pair.getAmountOut(amountIn, tokenB);
            reserveB += amountIn;
            reserveA -= amountOut;
        }
    }

    // computes liquidity value given all the parameters of the pair
    function computeLiquidityValue(
        uint256 reservesA,
        uint256 reservesB,
        uint256 totalSupply,
        uint256 liquidityAmount,
        bool feeOn,
        uint256 kLast
    ) internal pure returns (uint256 tokenAAmount, uint256 tokenBAmount) {
        if (feeOn && kLast > 0) {
            uint256 rootK = Babylonian.sqrt(reservesA * reservesB);
            uint256 rootKLast = Babylonian.sqrt(kLast);
            if (rootK > rootKLast) {
                uint256 numerator1 = totalSupply;
                uint256 numerator2 = rootK - rootKLast;
                uint256 denominator = (rootK * 5) + rootKLast;
                uint256 feeLiquidity = FullMath.mulDiv(numerator1, numerator2, denominator);
                totalSupply = totalSupply + feeLiquidity;
            }
        }
        return ((reservesA * liquidityAmount) / totalSupply, (reservesB * liquidityAmount) / totalSupply);
    }

    // get all current parameters from the pair and compute value of a liquidity amount
    // **note this is subject to manipulation, e.g. sandwich attacks**. prefer passing a manipulation resistant price to
    // #getLiquidityValueAfterArbitrageToPrice
    function getLiquidityValue(
        address factory,
        address tokenA,
        address tokenB,
        uint256 liquidityAmount
    ) internal view returns (uint256 tokenAAmount, uint256 tokenBAmount) {
        (uint256 reservesA, uint256 reservesB) = FraxswapRouterLibrary.getReserves(factory, tokenA, tokenB);
        IFraxswapPair pair = IFraxswapPair(FraxswapRouterLibrary.pairFor(factory, tokenA, tokenB));
        bool feeOn = IFraxswapFactory(factory).feeTo() != address(0);
        uint256 kLast = feeOn ? pair.kLast() : 0;
        uint256 totalSupply = pair.totalSupply();
        return computeLiquidityValue(reservesA, reservesB, totalSupply, liquidityAmount, feeOn, kLast);
    }

    // given two tokens, tokenA and tokenB, and their "true price", i.e. the observed ratio of value of token A to token B,
    // and a liquidity amount, returns the value of the liquidity in terms of tokenA and tokenB
    function getLiquidityValueAfterArbitrageToPrice(
        address factory,
        address tokenA,
        address tokenB,
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 liquidityAmount
    ) internal view returns (uint256 tokenAAmount, uint256 tokenBAmount) {
        bool feeOn = IFraxswapFactory(factory).feeTo() != address(0);
        IFraxswapPair pair = IFraxswapPair(FraxswapRouterLibrary.pairFor(factory, tokenA, tokenB));
        uint256 kLast = feeOn ? pair.kLast() : 0;
        uint256 totalSupply = pair.totalSupply();

        // this also checks that totalSupply > 0
        require(totalSupply >= liquidityAmount && liquidityAmount > 0, "ComputeLiquidityValue: LIQUIDITY_AMOUNT");

        (uint256 reservesA, uint256 reservesB) = getReservesAfterArbitrage(
            factory,
            tokenA,
            tokenB,
            truePriceTokenA,
            truePriceTokenB
        );

        return computeLiquidityValue(reservesA, reservesB, totalSupply, liquidityAmount, feeOn, kLast);
    }
}
