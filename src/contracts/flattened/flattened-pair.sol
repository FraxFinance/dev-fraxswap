// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

// lib/v2-core/contracts/interfaces/IUniswapV2Callee.sol

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}

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

// node_modules/@openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
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

// node_modules/@openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// src/contracts/core/FraxswapERC20.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== FraxswapERC20 ===========================
// ====================================================================

/// @notice Fraxswap ERC-20
/// @author Frax Finance (https://github.com/FraxFinance)
contract FraxswapERC20 {
    string public constant name = "Fraxswap V2";
    string public constant symbol = "FS-V2";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    bytes32 public immutable DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        uint256 chainId = block.chainid;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply + value;
        balanceOf[to] = balanceOf[to] + value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from] - value;
        totalSupply = totalSupply - value;
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint256 value) private {
        balanceOf[from] = balanceOf[from] - value;
        balanceOf[to] = balanceOf[to] + value;
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] = allowance[from][msg.sender] - value;
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp); // EXPIRED
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner); // INVALID_SIGNATURE
        _approve(owner, spender, value);
    }
}

// src/contracts/core/libraries/Math.sol
// SPDX-Licence-Identifier: MIT

// a library for performing various math operations

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// src/contracts/core/libraries/UQ112x112.sol
// SPDX-Licence-Identifier: MIT

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2 ** 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// src/contracts/twamm/LongTermOrders.sol

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

// node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// src/contracts/core/interfaces/IFraxswapFactory.sol

interface IFraxswapFactory is IUniswapV2Factory {
    function createPair(address tokenA, address tokenB, uint256 fee) external returns (address pair);
    function globalPause() external view returns (bool);
    function toggleGlobalPause() external;
}

// node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// src/contracts/core/FraxswapPair.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// =========================== FraxswapPair ===========================
// ====================================================================

/// @notice TWAMM LP Pair Token
/// @author Frax Finance (https://github.com/FraxFinance)
contract FraxswapPair is FraxswapERC20 {
    using UQ112x112 for uint224;
    using LongTermOrdersLib for LongTermOrdersLib.LongTermOrders;
    using LongTermOrdersLib for LongTermOrdersLib.ExecuteVirtualOrdersResult;

    /// ---------------------------
    /// -----TWAMM Parameters -----
    /// ---------------------------

    // address public owner_address;

    ///@notice time interval that are eligible for order expiry (to align expiries)
    uint256 public constant orderTimeInterval = 3600; // sync with LongTermOrders.sol

    ///@notice data structure to handle long term orders
    LongTermOrdersLib.LongTermOrders internal longTermOrders;

    uint112 public twammReserve0;
    uint112 public twammReserve1;

    uint256 public fee;

    bool public newSwapsPaused;

    modifier execVirtualOrders() {
        executeVirtualOrdersInternal(block.timestamp);
        _;
    }

    /// ---------------------------
    /// -------- Modifiers --------
    /// ---------------------------

    ///@notice Throws if called by any account other than the owner.
    modifier onlyOwnerOrFactory() {
        require(factory == msg.sender || IFraxswapFactory(factory).feeToSetter() == msg.sender); // NOT OWNER OR FACTORY
        _;
    }

    ///@notice Checks if new swaps are paused. If they are, only allow closing of existing ones.
    modifier isNotPaused() {
        require(newSwapsPaused == false); // NEW LT ORDERS PAUSED
        _;
    }

    modifier feeCheck(uint256 newFee) {
        require(newFee > 0 && newFee < 101); // fee can't be zero and can't be more than 1%
        _;
    }

    /// ---------------------------
    /// --------- Events ----------
    /// ---------------------------

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
    ///@notice An event emitted when a long term swap from token0 to token1 is performed
    event LongTermSwap0To1(address indexed addr, uint256 orderId, uint256 amount0In, uint256 numberOfTimeIntervals);

    ///@notice An event emitted when a long term swap from token1 to token0 is performed
    event LongTermSwap1To0(address indexed addr, uint256 orderId, uint256 amount1In, uint256 numberOfTimeIntervals);

    ///@notice An event emitted when a long term swap is cancelled
    event CancelLongTermOrder(
        address indexed addr,
        uint256 orderId,
        address sellToken,
        uint256 unsoldAmount,
        address buyToken,
        uint256 purchasedAmount
    );

    ///@notice An event emitted when a long term swap is withdrawn
    event WithdrawProceedsFromLongTermOrder(
        address indexed addr,
        uint256 orderId,
        address indexed proceedToken,
        uint256 proceeds,
        bool orderExpired
    );

    ///@notice An event emitted when lp fee is updated
    event LpFeeUpdated(uint256 fee);

    /// ---------------------------
    /// --------- Errors ----------
    /// ---------------------------

    error InvalidToToken();
    error Uint112Overflow();
    error KConstantError();
    error InsufficientInputAmount();
    error InsufficientOutputAmount();
    error InsufficientLiquidity(uint112 reserve0, uint112 reserve1);

    /// -------------------------------
    /// -----UNISWAPV2 Parameters -----
    /// -------------------------------

    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves

    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    // Track order IDs
    mapping(address => uint256[]) public orderIDsForUser;

    TWAPObservation[] public TWAPObservationHistory;

    struct TWAPObservation {
        uint256 timestamp;
        uint256 price0CumulativeLast;
        uint256 price1CumulativeLast;
    }

    function price0CumulativeLast() public view returns (uint256) {
        return
            TWAPObservationHistory.length > 0
                ? TWAPObservationHistory[TWAPObservationHistory.length - 1].price0CumulativeLast
                : 0;
    }

    function price1CumulativeLast() public view returns (uint256) {
        return
            TWAPObservationHistory.length > 0
                ? TWAPObservationHistory[TWAPObservationHistory.length - 1].price1CumulativeLast
                : 0;
    }

    function getTWAPHistoryLength() public view returns (uint256) {
        return TWAPObservationHistory.length;
    }

    uint256 private unlocked = 1;

    modifier lock() {
        require(unlocked == 1); // LOCKED
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getOrderIDsForUser(address user) external view returns (uint256[] memory) {
        return orderIDsForUser[user];
    }

    function getOrderIDsForUserLength(address user) external view returns (uint256) {
        return orderIDsForUser[user].length;
    }

    function getDetailedOrdersForUser(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (LongTermOrdersLib.Order[] memory detailed_orders) {
        uint256[] memory order_ids = orderIDsForUser[user];
        uint256 limit_to_use = Math.min(limit, order_ids.length - offset);
        detailed_orders = new LongTermOrdersLib.Order[](limit_to_use);

        for (uint256 i = 0; i < limit_to_use; i++) {
            detailed_orders[i] = longTermOrders.orderMap[order_ids[offset + i]];
        }
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        return (reserve0, reserve1, blockTimestampLast);
    }

    function getTwammReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast,
            uint112 _twammReserve0,
            uint112 _twammReserve1,
            uint256 _fee
        )
    {
        return (reserve0, reserve1, blockTimestampLast, twammReserve0, twammReserve1, 10_000 - fee);
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint256 amountIn, address tokenIn) external view returns (uint256) {
        (uint112 reserveIn, uint112 reserveOut) = tokenIn == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        require(amountIn > 0 && reserveIn > 0 && reserveOut > 0); // INSUFFICIENT_INPUT_AMOUNT, INSUFFICIENT_LIQUIDITY
        uint256 amountInWithFee = amountIn * fee;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 10_000) + amountInWithFee;
        return numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint256 amountOut, address tokenOut) external view returns (uint256) {
        (uint112 reserveIn, uint112 reserveOut) = tokenOut == token0 ? (reserve1, reserve0) : (reserve0, reserve1);
        require(amountOut > 0 && reserveIn > 0 && reserveOut > 0); // INSUFFICIENT_OUTPUT_AMOUNT, INSUFFICIENT_LIQUIDITY
        uint256 numerator = reserveIn * amountOut * 10_000;
        uint256 denominator = (reserveOut - amountOut) * fee;
        return (numerator / denominator) + 1;
    }

    function _safeTransfer(address token, address to, uint256 value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool)))); // TRANSFER_FAILED
    }

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment. will revert if fee is bad
    function initialize(address _token0, address _token1, uint256 _fee) external feeCheck(_fee) {
        require(msg.sender == factory); // FORBIDDEN
        // sufficient check
        token0 = _token0;
        token1 = _token1;
        fee = 10_000 - _fee;

        // TWAMM
        longTermOrders.initialize(_token0);

        emit LpFeeUpdated(_fee);
    }

    function _getTimeElapsed() private view returns (uint32) {
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);

        uint32 timeElapsed;
        unchecked {
            timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        }
        return timeElapsed;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 _reserve0,
        uint112 _reserve1,
        uint32 timeElapsed
    ) private {
        if (!(balance0 + twammReserve0 <= type(uint112).max && balance1 + twammReserve1 <= type(uint112).max)) {
            revert Uint112Overflow();
        } // OVERFLOW
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);

        unchecked {
            if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
                // * never overflows, and + overflow is desired
                TWAPObservationHistory.push(
                    TWAPObservation(
                        blockTimestamp,
                        price0CumulativeLast() + uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed,
                        price1CumulativeLast() + uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed
                    )
                );
            }
        }

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);

        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IFraxswapFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(_reserve0) * _reserve1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply * (rootK - rootKLast);
                    uint256 denominator = (rootK * 5) + rootKLast;
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock execVirtualOrders returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this)) - twammReserve0;
        uint256 balance1 = IERC20(token1).balanceOf(address(this)) - twammReserve1;
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min((amount0 * _totalSupply) / _reserve0, (amount1 * _totalSupply) / _reserve1);
        }
        require(liquidity > 0); // INSUFFICIENT_LIQUIDITY_MINTED
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1, _getTimeElapsed());
        if (feeOn) kLast = uint256(reserve0) * reserve1; // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock execVirtualOrders returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint256 balance0 = IERC20(_token0).balanceOf(address(this)) - twammReserve0;
        uint256 balance1 = IERC20(_token1).balanceOf(address(this)) - twammReserve1;
        uint256 liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = (liquidity * balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = (liquidity * balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0); // INSUFFICIENT_LIQUIDITY_BURNED
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this)) - twammReserve0;
        balance1 = IERC20(_token1).balanceOf(address(this)) - twammReserve1;

        _update(balance0, balance1, _reserve0, _reserve1, _getTimeElapsed());
        if (feeOn) kLast = uint256(reserve0) * reserve1; // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external lock execVirtualOrders {
        if (!(amount0Out > 0 || amount1Out > 0)) revert InsufficientOutputAmount(); // INSUFFICIENT_OUTPUT_AMOUNT
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        if (!(amount0Out < _reserve0 && amount1Out < _reserve1)) revert InsufficientLiquidity(_reserve0, _reserve1); // INSUFFICIENT_LIQUIDITY

        uint256 balance0;
        uint256 balance1;
        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            if (!(to != _token0 && to != _token1)) revert InvalidToToken(); // INVALID_TO
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
            if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
            balance0 = IERC20(_token0).balanceOf(address(this)) - twammReserve0;
            balance1 = IERC20(_token1).balanceOf(address(this)) - twammReserve1;
        }
        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        if (!(amount0In > 0 || amount1In > 0)) revert InsufficientInputAmount(); // INSUFFICIENT_INPUT_AMOUNT
        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint256 minusFee = 10_000 - fee;
            uint256 balance0Adjusted = (balance0 * 10_000) - (amount0In * minusFee);
            uint256 balance1Adjusted = (balance1 * 10_000) - (amount1In * minusFee);
            if (!(balance0Adjusted * balance1Adjusted >= uint256(_reserve0) * _reserve1 * (10_000 ** 2))) {
                revert KConstantError();
            } // K
        }

        _update(balance0, balance1, _reserve0, _reserve1, _getTimeElapsed());
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external lock execVirtualOrders {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)) - (reserve0 + twammReserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)) - (reserve1 + twammReserve1));
    }

    // force reserves to match balances
    function sync() external lock execVirtualOrders {
        _update(
            IERC20(token0).balanceOf(address(this)) - twammReserve0,
            IERC20(token1).balanceOf(address(this)) - twammReserve1,
            reserve0,
            reserve1,
            _getTimeElapsed()
        );
    }

    // TWAMM

    ///@notice calculate the amount in for token using the balance diff to handle feeOnTransfer tokens
    function transferAmountIn(address token, uint256 amountIn) internal returns (uint256) {
        // prev balance
        uint256 bal = IERC20(token).balanceOf(address(this));
        // transfer amount to contract

        // safeTransferFrom
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), amountIn)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))));

        // balance change
        return IERC20(token).balanceOf(address(this)) - bal;
    }

    ///@notice create a long term order to swap from token0
    ///@param amount0In total amount of token0 to swap
    ///@param numberOfTimeIntervals number of time intervals over which to execute long term order
    function longTermSwapFrom0To1(
        uint256 amount0In,
        uint256 numberOfTimeIntervals
    ) external lock isNotPaused execVirtualOrders returns (uint256 orderId) {
        uint256 amount0 = transferAmountIn(token0, amount0In);
        twammReserve0 += uint112(amount0);
        require(uint256(reserve0) + twammReserve0 <= type(uint112).max); // OVERFLOW
        orderId = longTermOrders.performLongTermSwap(token0, token1, amount0, numberOfTimeIntervals);
        orderIDsForUser[msg.sender].push(orderId);
        emit LongTermSwap0To1(msg.sender, orderId, amount0, numberOfTimeIntervals);
    }

    ///@notice create a long term order to swap from token1
    ///@param amount1In total amount of token1 to swap
    ///@param numberOfTimeIntervals number of time intervals over which to execute long term order
    function longTermSwapFrom1To0(
        uint256 amount1In,
        uint256 numberOfTimeIntervals
    ) external lock isNotPaused execVirtualOrders returns (uint256 orderId) {
        uint256 amount1 = transferAmountIn(token1, amount1In);
        twammReserve1 += uint112(amount1);
        require(uint256(reserve1) + twammReserve1 <= type(uint112).max); // OVERFLOW
        orderId = longTermOrders.performLongTermSwap(token1, token0, amount1, numberOfTimeIntervals);
        orderIDsForUser[msg.sender].push(orderId);
        emit LongTermSwap1To0(msg.sender, orderId, amount1, numberOfTimeIntervals);
    }

    ///@notice stop the execution of a long term order
    function cancelLongTermSwap(uint256 orderId) external lock execVirtualOrders {
        (address sellToken, uint256 unsoldAmount, address buyToken, uint256 purchasedAmount) = longTermOrders
            .cancelLongTermSwap(orderId);

        bool buyToken0 = buyToken == token0;
        twammReserve0 -= uint112(buyToken0 ? purchasedAmount : unsoldAmount);
        twammReserve1 -= uint112(buyToken0 ? unsoldAmount : purchasedAmount);

        // update order. Used for tracking / informational
        longTermOrders.orderMap[orderId].isComplete = true;

        // transfer to owner of order
        _safeTransfer(buyToken, msg.sender, purchasedAmount);
        _safeTransfer(sellToken, msg.sender, unsoldAmount);

        emit CancelLongTermOrder(msg.sender, orderId, sellToken, unsoldAmount, buyToken, purchasedAmount);
    }

    ///@notice withdraw proceeds from a long term swap
    function withdrawProceedsFromLongTermSwap(
        uint256 orderId
    ) external lock execVirtualOrders returns (bool is_expired, address rewardTkn, uint256 totalReward) {
        (address proceedToken, uint256 proceeds, bool orderExpired) = longTermOrders.withdrawProceedsFromLongTermSwap(
            orderId
        );
        if (proceedToken == token0) {
            twammReserve0 -= uint112(proceeds);
        } else {
            twammReserve1 -= uint112(proceeds);
        }

        // update order. Used for tracking / informational
        if (orderExpired) longTermOrders.orderMap[orderId].isComplete = true;

        // transfer to owner of order
        _safeTransfer(proceedToken, msg.sender, proceeds);

        emit WithdrawProceedsFromLongTermOrder(msg.sender, orderId, proceedToken, proceeds, orderExpired);

        return (orderExpired, proceedToken, proceeds);
    }

    ///@notice execute virtual orders in the twamm, bring it up to the blockNumber passed in
    ///updates the TWAP if it is the first amm tx of the block
    function executeVirtualOrdersInternal(uint256 blockTimestamp) internal {
        if (newSwapsPaused) return; // skip twamm executions
        if (twammUpToDate()) return; // save gas

        LongTermOrdersLib.ExecuteVirtualOrdersResult memory result = LongTermOrdersLib.ExecuteVirtualOrdersResult(
            reserve0,
            reserve1,
            twammReserve0,
            twammReserve1,
            fee
        );

        longTermOrders.executeVirtualOrdersUntilTimestamp(blockTimestamp, result);

        twammReserve0 = uint112(result.newTwammReserve0);
        twammReserve1 = uint112(result.newTwammReserve1);

        uint112 newReserve0 = uint112(result.newReserve0);
        uint112 newReserve1 = uint112(result.newReserve1);

        uint32 timeElapsed = _getTimeElapsed();
        // update reserve0 and reserve1
        if (timeElapsed > 0 && (newReserve0 != reserve0 || newReserve1 != reserve1)) {
            _update(newReserve0, newReserve1, reserve0, reserve1, timeElapsed);
        } else {
            reserve0 = newReserve0;
            reserve1 = newReserve1;
        }
    }

    ///@notice convenience function to execute virtual orders. Note that this already happens
    ///before most interactions with the AMM
    function executeVirtualOrders(uint256 blockTimestamp) public lock {
        // blockTimestamp is valid then execute the long term orders otherwise noop
        if (longTermOrders.lastVirtualOrderTimestamp < blockTimestamp && blockTimestamp <= block.timestamp) {
            executeVirtualOrdersInternal(blockTimestamp);
        }
    }

    /// ---------------------------
    /// ------- TWAMM Views -------
    /// ---------------------------

    ///@notice util function for getting the next orderId
    function getNextOrderID() public view returns (uint256) {
        return longTermOrders.orderId;
    }

    ///@notice util function for checking if the twamm is up to date
    function twammUpToDate() public view returns (bool) {
        return block.timestamp == longTermOrders.lastVirtualOrderTimestamp;
    }

    function getReserveAfterTwamm(
        uint256 blockTimestamp
    )
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint256 lastVirtualOrderTimestamp,
            uint112 _twammReserve0,
            uint112 _twammReserve1
        )
    {
        lastVirtualOrderTimestamp = longTermOrders.lastVirtualOrderTimestamp;

        uint112 bal0 = reserve0 + twammReserve0; // save the balance of token0
        uint112 bal1 = reserve1 + twammReserve1; // save the balance of token1

        LongTermOrdersLib.ExecuteVirtualOrdersResult memory result = LongTermOrdersLib.ExecuteVirtualOrdersResult(
            reserve0,
            reserve1,
            twammReserve0,
            twammReserve1,
            fee
        );

        longTermOrders.executeVirtualOrdersUntilTimestampView(blockTimestamp, result);

        _reserve0 = uint112(bal0 - result.newTwammReserve0);
        _reserve1 = uint112(bal1 - result.newTwammReserve1);
        _twammReserve0 = uint112(result.newTwammReserve0);
        _twammReserve1 = uint112(result.newTwammReserve1);
    }

    ///@notice returns the current state of the twamm
    function getTwammState()
        public
        view
        returns (
            uint256 token0Rate,
            uint256 token1Rate,
            uint256 lastVirtualOrderTimestamp,
            uint256 orderTimeInterval_rtn,
            uint256 rewardFactorPool0,
            uint256 rewardFactorPool1
        )
    {
        token0Rate = longTermOrders.OrderPool0.currentSalesRate;
        token1Rate = longTermOrders.OrderPool1.currentSalesRate;
        lastVirtualOrderTimestamp = longTermOrders.lastVirtualOrderTimestamp;
        orderTimeInterval_rtn = orderTimeInterval;
        rewardFactorPool0 = longTermOrders.OrderPool0.rewardFactor;
        rewardFactorPool1 = longTermOrders.OrderPool1.rewardFactor;
    }

    ///@notice returns salesRates ending on this blockTimestamp
    function getTwammSalesRateEnding(
        uint256 _blockTimestamp
    ) public view returns (uint256 orderPool0SalesRateEnding, uint256 orderPool1SalesRateEnding) {
        uint256 lastExpiryTimestamp = _blockTimestamp - (_blockTimestamp % orderTimeInterval);
        orderPool0SalesRateEnding = longTermOrders.OrderPool0.salesRateEndingPerTimeInterval[lastExpiryTimestamp];
        orderPool1SalesRateEnding = longTermOrders.OrderPool1.salesRateEndingPerTimeInterval[lastExpiryTimestamp];
    }

    ///@notice returns reward factors at this blockTimestamp
    function getTwammRewardFactor(
        uint256 _blockTimestamp
    ) public view returns (uint256 rewardFactorPool0AtTimestamp, uint256 rewardFactorPool1AtTimestamp) {
        uint256 lastExpiryTimestamp = _blockTimestamp - (_blockTimestamp % orderTimeInterval);
        rewardFactorPool0AtTimestamp = longTermOrders.OrderPool0.rewardFactorAtTimestamp[lastExpiryTimestamp];
        rewardFactorPool1AtTimestamp = longTermOrders.OrderPool1.rewardFactorAtTimestamp[lastExpiryTimestamp];
    }

    ///@notice returns the twamm Order struct
    function getTwammOrder(
        uint256 orderId
    )
        public
        view
        returns (
            uint256 id,
            uint256 creationTimestamp,
            uint256 expirationTimestamp,
            uint256 saleRate,
            address owner,
            address sellTokenAddr,
            address buyTokenAddr
        )
    {
        require(orderId < longTermOrders.orderId); // INVALID ORDERID
        LongTermOrdersLib.Order storage order = longTermOrders.orderMap[orderId];
        return (
            order.id,
            order.creationTimestamp,
            order.expirationTimestamp,
            order.saleRate,
            order.owner,
            order.sellTokenAddr,
            order.buyTokenAddr
        );
    }

    ///@notice returns the twamm Order withdrawable proceeds
    // IMPORTANT: Can be stale. Should call executeVirtualOrders first or use getTwammOrderProceeds below.
    // You can also .call() withdrawProceedsFromLongTermSwap
    // blockTimestamp should be <= current
    function getTwammOrderProceedsView(
        uint256 orderId,
        uint256 blockTimestamp
    ) public view returns (bool orderExpired, uint256 totalReward) {
        require(orderId < longTermOrders.orderId); // INVALID ORDERID
        LongTermOrdersLib.OrderPool storage orderPool = LongTermOrdersLib.getOrderPool(
            longTermOrders,
            longTermOrders.orderMap[orderId].sellTokenAddr
        );
        (orderExpired, totalReward) = LongTermOrdersLib.orderPoolGetProceeds(orderPool, orderId, blockTimestamp);
    }

    ///@notice returns the twamm Order withdrawable proceeds
    // Need to update the virtual orders first
    function getTwammOrderProceeds(uint256 orderId) public returns (bool orderExpired, uint256 totalReward) {
        executeVirtualOrders(block.timestamp);
        return getTwammOrderProceedsView(orderId, block.timestamp);
    }

    ///@notice Pauses the execution of existing twamm orders and the creation of new twamm orders
    // Only callable once by anyone once the pause is toggled on the factory
    function togglePauseNewSwaps() external {
        require(!newSwapsPaused && IFraxswapFactory(factory).globalPause()); // globalPause is enabled
        // Pause new swaps
        newSwapsPaused = true;
    }

    /* ========== RESTRICTED FUNCTIONS - Owner only ========== */

    ///@notice sets the pool's lp fee
    function setFee(uint256 newFee) external execVirtualOrders feeCheck(newFee) onlyOwnerOrFactory {
        fee = 10_000 - newFee; // newFee should be in basis points (100th of a pecent). 30 = 0.3%
        emit LpFeeUpdated(newFee);
    }
}
