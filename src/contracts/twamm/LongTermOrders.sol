// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================= LongTermOrdersLib ========================
// ====================================================================
// TWAMM long term order execution logic

/// @notice This library handles the state and execution of long term orders.
library LongTermOrdersLib {
    using LongTermOrdersLib for OrderPool;

    /// ---------------------------
    /// ---------- Events ---------
    /// ---------------------------

    ///@notice An event emitted when virtual orders are executed
    event VirtualOrderExecution(
        uint256 blockTimestamp,
        uint256 blockTimestampElapsed,
        uint256 newReserve0,
        uint256 newReserve1,
        uint256 newTwammReserve0,
        uint256 newTwammReserve1,
        uint256 token0Bought,
        uint256 token1Bought,
        uint256 token0Sold,
        uint256 token1Sold
    );

    /// ---------------------------
    /// ----- LongTerm Orders -----
    /// ---------------------------

    uint112 internal constant SELL_RATE_ADDITIONAL_PRECISION = 1_000_000;
    uint256 internal constant Q112 = 2 ** 112;
    uint256 internal constant orderTimeInterval = 3600; // sync with FraxswapPair.sol

    ///@notice information associated with a long term order
    ///fields should NOT be changed after Order struct is created
    struct Order {
        uint256 id;
        uint256 creationTimestamp;
        uint256 expirationTimestamp;
        uint256 saleRate;
        address owner;
        address sellTokenAddr;
        address buyTokenAddr;
        bool isComplete;
    }

    ///@notice structure contains full state related to long term orders
    struct LongTermOrders {
        ///@notice last virtual orders were executed immediately before this block.timestamp
        uint256 lastVirtualOrderTimestamp;
        ///@notice token0 being traded in amm
        address token0;
        ///@notice mapping from token address to pool that is selling that token
        ///we maintain two order pools, one for each token that is tradable in the AMM
        OrderPool OrderPool0;
        OrderPool OrderPool1;
        ///@notice incrementing counter for order ids, this is the next order id
        uint256 orderId;
        ///@notice mapping from order ids to Orders
        mapping(uint256 => Order) orderMap;
    }

    struct ExecuteVirtualOrdersResult {
        uint112 newReserve0;
        uint112 newReserve1;
        uint256 newTwammReserve0;
        uint256 newTwammReserve1;
        uint256 fee;
    }

    ///@notice initialize state
    function initialize(LongTermOrders storage longTermOrders, address token0) internal {
        longTermOrders.token0 = token0;
        longTermOrders.lastVirtualOrderTimestamp = block.timestamp;
    }

    ///@notice get the OrderPool for this token
    function getOrderPool(
        LongTermOrders storage longTermOrders,
        address token
    ) internal view returns (OrderPool storage orderPool) {
        orderPool = token == longTermOrders.token0 ? longTermOrders.OrderPool0 : longTermOrders.OrderPool1;
    }

    ///@notice adds long term swap to order pool
    function performLongTermSwap(
        LongTermOrders storage longTermOrders,
        address from,
        address to,
        uint256 amount,
        uint256 numberOfTimeIntervals
    ) internal returns (uint256) {
        // make sure to update virtual order state (before calling this function)

        //determine the selling rate based on number of blocks to expiry and total amount
        uint256 currentTime = block.timestamp;
        uint256 lastExpiryTimestamp = currentTime - (currentTime % orderTimeInterval);
        uint256 orderExpiry = orderTimeInterval * (numberOfTimeIntervals + 1) + lastExpiryTimestamp;
        uint256 sellingRate = (SELL_RATE_ADDITIONAL_PRECISION * amount) / (orderExpiry - currentTime);

        require(sellingRate > 0); // tokenRate cannot be zero

        //add order to correct pool
        OrderPool storage orderPool = getOrderPool(longTermOrders, from);
        orderPoolDepositOrder(orderPool, longTermOrders.orderId, sellingRate, orderExpiry);

        //add to order map
        longTermOrders.orderMap[longTermOrders.orderId] = Order(
            longTermOrders.orderId,
            currentTime,
            orderExpiry,
            sellingRate,
            msg.sender,
            from,
            to,
            false
        );
        return longTermOrders.orderId++;
    }

    ///@notice cancel long term swap, pay out unsold tokens and well as purchased tokens
    function cancelLongTermSwap(
        LongTermOrders storage longTermOrders,
        uint256 orderId
    ) internal returns (address sellToken, uint256 unsoldAmount, address buyToken, uint256 purchasedAmount) {
        // make sure to update virtual order state (before calling this function)

        Order storage order = longTermOrders.orderMap[orderId];
        buyToken = order.buyTokenAddr;
        sellToken = order.sellTokenAddr;

        OrderPool storage orderPool = getOrderPool(longTermOrders, sellToken);
        (unsoldAmount, purchasedAmount) = orderPoolCancelOrder(
            orderPool,
            orderId,
            longTermOrders.lastVirtualOrderTimestamp
        );

        require(order.owner == msg.sender && (unsoldAmount > 0 || purchasedAmount > 0)); // owner and amounts check
    }

    ///@notice withdraw proceeds from a long term swap (can be expired or ongoing)
    function withdrawProceedsFromLongTermSwap(
        LongTermOrders storage longTermOrders,
        uint256 orderId
    ) internal returns (address proceedToken, uint256 proceeds, bool orderExpired) {
        // make sure to update virtual order state (before calling this function)

        Order storage order = longTermOrders.orderMap[orderId];
        proceedToken = order.buyTokenAddr;

        OrderPool storage orderPool = getOrderPool(longTermOrders, order.sellTokenAddr);
        (proceeds, orderExpired) = orderPoolWithdrawProceeds(
            orderPool,
            orderId,
            longTermOrders.lastVirtualOrderTimestamp
        );

        require(order.owner == msg.sender && proceeds > 0); // owner and amounts check
    }

    ///@notice computes the result of virtual trades by the token pools
    function computeVirtualBalances(
        uint256 token0Start,
        uint256 token1Start,
        uint256 token0In,
        uint256 token1In,
        uint256 fee
    ) internal pure returns (uint256 token0Out, uint256 token1Out) {
        token0Out = 0;
        token1Out = 0;
        //if no tokens are sold to the pool, we don't need to execute any orders
        if (token0In < 2 && token1In < 2) {
            // do nothing
        }
        //in the case where only one pool is selling, we just perform a normal swap
        else if (token0In < 2) {
            //constant product formula
            uint256 token1InWithFee = token1In * fee;
            token0Out = (token0Start * token1InWithFee) / ((token1Start * 10_000) + token1InWithFee);
        } else if (token1In < 2) {
            //constant product formula
            uint256 token0InWithFee = token0In * fee;
            token1Out = (token1Start * token0InWithFee) / ((token0Start * 10_000) + token0InWithFee);
        }
        //when both pools sell, we use the TWAMM formula
        else {
            uint256 newToken0 = token0Start + ((token0In * fee) / 10_000);
            uint256 newToken1 = token1Start + ((token1In * fee) / 10_000);
            token0Out = newToken0 - ((token1Start * (newToken0)) / (newToken1));
            token1Out = newToken1 - ((token0Start * (newToken1)) / (newToken0));
        }
    }

    ///@notice executes all virtual orders between current lastVirtualOrderTimestamp and blockTimestamp
    //also handles orders that expire at end of final blockTimestamp. This assumes that no orders expire inside the given interval
    function executeVirtualTradesAndOrderExpiries(
        ExecuteVirtualOrdersResult memory reserveResult,
        uint256 token0SellAmount,
        uint256 token1SellAmount
    ) private view returns (uint256 token0Out, uint256 token1Out) {
        //initial amm balance
        uint256 bal0 = reserveResult.newReserve0 + reserveResult.newTwammReserve0;
        uint256 bal1 = reserveResult.newReserve1 + reserveResult.newTwammReserve1;

        //updated balances from sales
        (token0Out, token1Out) = computeVirtualBalances(
            reserveResult.newReserve0,
            reserveResult.newReserve1,
            token0SellAmount,
            token1SellAmount,
            reserveResult.fee
        );

        //update balances reserves
        reserveResult.newTwammReserve0 = reserveResult.newTwammReserve0 + token0Out - token0SellAmount;
        reserveResult.newTwammReserve1 = reserveResult.newTwammReserve1 + token1Out - token1SellAmount;
        reserveResult.newReserve0 = uint112(bal0 - reserveResult.newTwammReserve0); // calculate reserve0 incl LP fees
        reserveResult.newReserve1 = uint112(bal1 - reserveResult.newTwammReserve1); // calculate reserve1 incl LP fees
    }

    ///@notice executes all virtual orders until blockTimestamp is reached.
    function executeVirtualOrdersUntilTimestamp(
        LongTermOrders storage longTermOrders,
        uint256 blockTimestamp,
        ExecuteVirtualOrdersResult memory reserveResult
    ) internal {
        uint256 lastVirtualOrderTimestampLocal = longTermOrders.lastVirtualOrderTimestamp; // save gas
        uint256 nextExpiryBlockTimestamp = lastVirtualOrderTimestampLocal -
            (lastVirtualOrderTimestampLocal % orderTimeInterval) +
            orderTimeInterval;
        //iterate through time intervals eligible for order expiries, moving state forward

        OrderPool storage orderPool0 = longTermOrders.OrderPool0;
        OrderPool storage orderPool1 = longTermOrders.OrderPool1;

        while (nextExpiryBlockTimestamp <= blockTimestamp) {
            // Optimization for skipping blocks with no expiry
            if (
                orderPool0.salesRateEndingPerTimeInterval[nextExpiryBlockTimestamp] > 0 ||
                orderPool1.salesRateEndingPerTimeInterval[nextExpiryBlockTimestamp] > 0
            ) {
                //amount sold from virtual trades
                uint256 blockTimestampElapsed = nextExpiryBlockTimestamp - lastVirtualOrderTimestampLocal;
                uint256 token0SellAmount = (orderPool0.currentSalesRate * blockTimestampElapsed) /
                    SELL_RATE_ADDITIONAL_PRECISION;
                uint256 token1SellAmount = (orderPool1.currentSalesRate * blockTimestampElapsed) /
                    SELL_RATE_ADDITIONAL_PRECISION;

                (uint256 token0Out, uint256 token1Out) = executeVirtualTradesAndOrderExpiries(
                    reserveResult,
                    token0SellAmount,
                    token1SellAmount
                );

                //distribute proceeds to pools. make sure to call this before orderPoolUpdateStateFromTimestampExpiry.
                orderPoolDistributePayment(orderPool0, token1Out);
                orderPoolDistributePayment(orderPool1, token0Out);

                //handle orders expiring at end of interval. call orderPoolDistributePayment before calling this.
                orderPoolUpdateStateFromTimestampExpiry(orderPool0, nextExpiryBlockTimestamp);
                orderPoolUpdateStateFromTimestampExpiry(orderPool1, nextExpiryBlockTimestamp);

                emit VirtualOrderExecution(
                    nextExpiryBlockTimestamp,
                    blockTimestampElapsed,
                    reserveResult.newReserve0,
                    reserveResult.newReserve1,
                    reserveResult.newTwammReserve0,
                    reserveResult.newTwammReserve1,
                    token0Out,
                    token1Out,
                    token0SellAmount,
                    token1SellAmount
                );

                lastVirtualOrderTimestampLocal = nextExpiryBlockTimestamp;
            }
            nextExpiryBlockTimestamp += orderTimeInterval;
        }
        //finally, move state to current blockTimestamp if necessary
        if (lastVirtualOrderTimestampLocal != blockTimestamp) {
            //amount sold from virtual trades
            uint256 blockTimestampElapsed = blockTimestamp - lastVirtualOrderTimestampLocal;
            uint256 token0SellAmount = (orderPool0.currentSalesRate * blockTimestampElapsed) /
                SELL_RATE_ADDITIONAL_PRECISION;
            uint256 token1SellAmount = (orderPool1.currentSalesRate * blockTimestampElapsed) /
                SELL_RATE_ADDITIONAL_PRECISION;

            (uint256 token0Out, uint256 token1Out) = executeVirtualTradesAndOrderExpiries(
                reserveResult,
                token0SellAmount,
                token1SellAmount
            );

            emit VirtualOrderExecution(
                blockTimestamp,
                blockTimestampElapsed,
                reserveResult.newReserve0,
                reserveResult.newReserve1,
                reserveResult.newTwammReserve0,
                reserveResult.newTwammReserve1,
                token0Out,
                token1Out,
                token0SellAmount,
                token1SellAmount
            );

            //distribute proceeds to pools
            orderPoolDistributePayment(orderPool0, token1Out);
            orderPoolDistributePayment(orderPool1, token0Out);

            // skip call to orderPoolUpdateStateFromTimestampExpiry, this will not be an expiry timestamp. save gas
        }

        longTermOrders.lastVirtualOrderTimestamp = blockTimestamp;
    }

    ///@notice executes all virtual orders until blockTimestamp is reached (AS A VIEW)
    function executeVirtualOrdersUntilTimestampView(
        LongTermOrders storage longTermOrders,
        uint256 blockTimestamp,
        ExecuteVirtualOrdersResult memory reserveResult
    ) internal view {
        uint256 lastVirtualOrderTimestampLocal = longTermOrders.lastVirtualOrderTimestamp; // save gas
        uint256 nextExpiryBlockTimestamp = lastVirtualOrderTimestampLocal -
            (lastVirtualOrderTimestampLocal % orderTimeInterval) +
            orderTimeInterval;
        //iterate through time intervals eligible for order expiries, moving state forward

        OrderPool storage orderPool0 = longTermOrders.OrderPool0;
        OrderPool storage orderPool1 = longTermOrders.OrderPool1;

        // currentSales for each pool is mutated in the non-view (mutate locally)
        uint256 currentSalesRate0 = orderPool0.currentSalesRate;
        uint256 currentSalesRate1 = orderPool1.currentSalesRate;

        while (nextExpiryBlockTimestamp <= blockTimestamp) {
            // Optimization for skipping blocks with no expiry
            if (
                orderPool0.salesRateEndingPerTimeInterval[nextExpiryBlockTimestamp] > 0 ||
                orderPool1.salesRateEndingPerTimeInterval[nextExpiryBlockTimestamp] > 0
            ) {
                //amount sold from virtual trades
                uint256 blockTimestampElapsed = nextExpiryBlockTimestamp - lastVirtualOrderTimestampLocal;
                uint256 token0SellAmount = (currentSalesRate0 * blockTimestampElapsed) / SELL_RATE_ADDITIONAL_PRECISION;
                uint256 token1SellAmount = (currentSalesRate1 * blockTimestampElapsed) / SELL_RATE_ADDITIONAL_PRECISION;

                executeVirtualTradesAndOrderExpiries(reserveResult, token0SellAmount, token1SellAmount);

                currentSalesRate0 -= orderPool0.salesRateEndingPerTimeInterval[nextExpiryBlockTimestamp];
                currentSalesRate1 -= orderPool1.salesRateEndingPerTimeInterval[nextExpiryBlockTimestamp];

                lastVirtualOrderTimestampLocal = nextExpiryBlockTimestamp;
            }
            nextExpiryBlockTimestamp += orderTimeInterval;
        }
        //finally, move state to current blockTimestamp if necessary
        if (lastVirtualOrderTimestampLocal != blockTimestamp) {
            //amount sold from virtual trades
            uint256 blockTimestampElapsed = blockTimestamp - lastVirtualOrderTimestampLocal;
            uint256 token0SellAmount = (currentSalesRate0 * blockTimestampElapsed) / SELL_RATE_ADDITIONAL_PRECISION;
            uint256 token1SellAmount = (currentSalesRate1 * blockTimestampElapsed) / SELL_RATE_ADDITIONAL_PRECISION;

            executeVirtualTradesAndOrderExpiries(reserveResult, token0SellAmount, token1SellAmount);
        }
    }

    /// ---------------------------
    /// -------- OrderPool --------
    /// ---------------------------

    ///@notice An Order Pool is an abstraction for a pool of long term orders that sells a token at a constant rate to the embedded AMM.
    ///the order pool handles the logic for distributing the proceeds from these sales to the owners of the long term orders through a modified
    ///version of the staking algorithm from  https://uploads-ssl.webflow.com/5ad71ffeb79acc67c8bcdaba/5ad8d1193a40977462982470_scalable-reward-distribution-paper.pdf

    ///@notice you can think of this as a staking pool where all long term orders are staked.
    /// The pool is paid when virtual long term orders are executed, and each order is paid proportionally
    /// by the order's sale rate per time intervals
    struct OrderPool {
        ///@notice current rate that tokens are being sold (per time interval)
        uint256 currentSalesRate;
        ///@notice sum of (salesProceeds_k / salesRate_k) over every period k. Stored as a fixed precision floating point number
        uint256 rewardFactor;
        ///@notice this maps time interval numbers to the cumulative sales rate of orders that expire on that block (time interval)
        mapping(uint256 => uint256) salesRateEndingPerTimeInterval;
        ///@notice map order ids to the block timestamp in which they expire
        mapping(uint256 => uint256) orderExpiry;
        ///@notice map order ids to their sales rate
        mapping(uint256 => uint256) salesRate;
        ///@notice reward factor per order at time of submission
        mapping(uint256 => uint256) rewardFactorAtSubmission;
        ///@notice reward factor at a specific time interval
        mapping(uint256 => uint256) rewardFactorAtTimestamp;
    }

    ///@notice distribute payment amount to pool (in the case of TWAMM, proceeds from trades against amm)
    function orderPoolDistributePayment(OrderPool storage orderPool, uint256 amount) internal {
        if (orderPool.currentSalesRate != 0) {
            unchecked {
                // Addition is with overflow
                orderPool.rewardFactor += (amount * Q112 * SELL_RATE_ADDITIONAL_PRECISION) / orderPool.currentSalesRate;
            }
        }
    }

    ///@notice deposit an order into the order pool.
    function orderPoolDepositOrder(
        OrderPool storage orderPool,
        uint256 orderId,
        uint256 amountPerInterval,
        uint256 orderExpiry
    ) internal {
        orderPool.currentSalesRate += amountPerInterval;
        orderPool.rewardFactorAtSubmission[orderId] = orderPool.rewardFactor;
        orderPool.orderExpiry[orderId] = orderExpiry;
        orderPool.salesRate[orderId] = amountPerInterval;
        orderPool.salesRateEndingPerTimeInterval[orderExpiry] += amountPerInterval;
    }

    ///@notice when orders expire after a given timestamp, we need to update the state of the pool
    function orderPoolUpdateStateFromTimestampExpiry(OrderPool storage orderPool, uint256 blockTimestamp) internal {
        orderPool.currentSalesRate -= orderPool.salesRateEndingPerTimeInterval[blockTimestamp];
        orderPool.rewardFactorAtTimestamp[blockTimestamp] = orderPool.rewardFactor;
    }

    ///@notice cancel order and remove from the order pool
    function orderPoolCancelOrder(
        OrderPool storage orderPool,
        uint256 orderId,
        uint256 blockTimestamp
    ) internal returns (uint256 unsoldAmount, uint256 purchasedAmount) {
        uint256 expiry = orderPool.orderExpiry[orderId];
        require(expiry > blockTimestamp);

        //calculate amount that wasn't sold, and needs to be returned
        uint256 salesRate = orderPool.salesRate[orderId];
        unsoldAmount = ((expiry - blockTimestamp) * salesRate) / SELL_RATE_ADDITIONAL_PRECISION;

        //calculate amount of other token that was purchased
        unchecked {
            // subtraction is with underflow
            purchasedAmount =
                (((orderPool.rewardFactor - orderPool.rewardFactorAtSubmission[orderId]) * salesRate) /
                    SELL_RATE_ADDITIONAL_PRECISION) /
                Q112;
        }

        //update state
        orderPool.currentSalesRate -= salesRate;
        orderPool.salesRate[orderId] = 0;
        orderPool.orderExpiry[orderId] = 0;
        orderPool.salesRateEndingPerTimeInterval[expiry] -= salesRate;
    }

    ///@notice withdraw proceeds from pool for a given order. This can be done before or after the order has expired.
    //If the order has expired, we calculate the reward factor at time of expiry. If order has not yet expired, we
    //use current reward factor, and update the reward factor at time of staking (effectively creating a new order)
    function orderPoolWithdrawProceeds(
        OrderPool storage orderPool,
        uint256 orderId,
        uint256 blockTimestamp
    ) internal returns (uint256 totalReward, bool orderExpired) {
        (orderExpired, totalReward) = orderPoolGetProceeds(orderPool, orderId, blockTimestamp);

        if (orderExpired) {
            //remove stake
            orderPool.salesRate[orderId] = 0;
        }
        //if order has not yet expired, we just adjust the start
        else {
            orderPool.rewardFactorAtSubmission[orderId] = orderPool.rewardFactor;
        }
    }

    ///@notice view function for getting the current proceeds for the given order
    function orderPoolGetProceeds(
        OrderPool storage orderPool,
        uint256 orderId,
        uint256 blockTimestamp
    ) internal view returns (bool orderExpired, uint256 totalReward) {
        uint256 stakedAmount = orderPool.salesRate[orderId];
        require(stakedAmount > 0);
        uint256 orderExpiry = orderPool.orderExpiry[orderId];
        uint256 rewardFactorAtSubmission = orderPool.rewardFactorAtSubmission[orderId];

        //if order has expired, we need to calculate the reward factor at expiry
        if (blockTimestamp >= orderExpiry) {
            uint256 rewardFactorAtExpiry = orderPool.rewardFactorAtTimestamp[orderExpiry];
            unchecked {
                // subtraction is with underflow
                totalReward =
                    (((rewardFactorAtExpiry - rewardFactorAtSubmission) * stakedAmount) /
                        SELL_RATE_ADDITIONAL_PRECISION) /
                    Q112;
            }
            orderExpired = true;
        } else {
            unchecked {
                // subtraction is with underflow
                totalReward =
                    (((orderPool.rewardFactor - rewardFactorAtSubmission) * stakedAmount) /
                        SELL_RATE_ADDITIONAL_PRECISION) /
                    Q112;
            }
            orderExpired = false;
        }
    }
}
