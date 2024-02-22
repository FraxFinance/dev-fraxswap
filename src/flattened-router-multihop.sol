// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0 >=0.6.0 ^0.8.0 ^0.8.20;

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

// lib/v2-periphery/contracts/interfaces/IWETH.sol

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

// lib/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external;
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolActions.sol

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IUniswapV3PoolActions {
    /// @notice Sets the initial price for the pool
    /// @dev Price is represented as a sqrt(amountToken1/amountToken0) Q64.96 value
    /// @param sqrtPriceX96 the initial sqrt price of the pool as a Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice Adds liquidity for the given recipient/tickLower/tickUpper position
    /// @dev The caller of this method receives a callback in the form of IUniswapV3MintCallback#uniswapV3MintCallback
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    /// @param recipient The address for which the liquidity will be created
    /// @param tickLower The lower tick of the position in which to add liquidity
    /// @param tickUpper The upper tick of the position in which to add liquidity
    /// @param amount The amount of liquidity to mint
    /// @param data Any data that should be passed through to the callback
    /// @return amount0 The amount of token0 that was paid to mint the given amount of liquidity. Matches the value in the callback
    /// @return amount1 The amount of token1 that was paid to mint the given amount of liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Collects tokens owed to a position
    /// @dev Does not recompute fees earned, which must be done either via mint or burn of any amount of liquidity.
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    /// @param recipient The address which should receive the fees collected
    /// @param tickLower The lower tick of the position for which to collect fees
    /// @param tickUpper The upper tick of the position for which to collect fees
    /// @param amount0Requested How much token0 should be withdrawn from the fees owed
    /// @param amount1Requested How much token1 should be withdrawn from the fees owed
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice Burn liquidity from the sender and account tokens owed for the liquidity to the position
    /// @dev Can be used to trigger a recalculation of fees owed to a position by calling with an amount of 0
    /// @dev Fees must be collected separately via a call to #collect
    /// @param tickLower The lower tick of the position for which to burn liquidity
    /// @param tickUpper The upper tick of the position for which to burn liquidity
    /// @param amount How much liquidity to burn
    /// @return amount0 The amount of token0 sent to the recipient
    /// @return amount1 The amount of token1 sent to the recipient
    function burn(int24 tickLower, int24 tickUpper, uint128 amount) external returns (uint256 amount0, uint256 amount1);

    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(address recipient, uint256 amount0, uint256 amount1, bytes calldata data) external;

    /// @notice Increase the maximum number of price and liquidity observations that this pool will store
    /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
    /// the input observationCardinalityNext.
    /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    /// @notice Returns the cumulative tick and liquidity as of each timestamp `secondsAgo` from the current block timestamp
    /// @dev To get a time weighted average tick or liquidity-in-range, you must call this with two values, one representing
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    /// @dev The time weighted average tick represents the geometric time weighted average price of the pool, in
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    /// @param secondsAgos From how long ago each cumulative tick and liquidity value should be returned
    /// @return tickCumulatives Cumulative tick values as of each `secondsAgos` from the current block timestamp
    /// @return secondsPerLiquidityCumulativeX128s Cumulative seconds per liquidity-in-range value as of each `secondsAgos` from the current block
    /// timestamp
    function observe(
        uint32[] calldata secondsAgos
    ) external view returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice Returns a snapshot of the tick cumulative, seconds per liquidity and seconds inside a tick range
    /// @dev Snapshots must only be compared to other snapshots, taken over a period for which a position existed.
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    /// @param tickLower The lower tick of the range
    /// @param tickUpper The upper tick of the range
    /// @return tickCumulativeInside The snapshot of the tick accumulator for the range
    /// @return secondsPerLiquidityInsideX128 The snapshot of seconds per liquidity for the range
    /// @return secondsInside The snapshot of seconds per liquidity for the range
    function snapshotCumulativesInside(
        int24 tickLower,
        int24 tickUpper
    ) external view returns (int56 tickCumulativeInside, uint160 secondsPerLiquidityInsideX128, uint32 secondsInside);
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolEvents.sol

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice Emitted when liquidity is minted for a given position
    /// @param sender The address that minted the liquidity
    /// @param owner The owner of the position and recipient of any minted liquidity
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity minted to the position range
    /// @param amount0 How much token0 was required for the minted liquidity
    /// @param amount1 How much token1 was required for the minted liquidity
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param owner The owner of the position for which liquidity is removed
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity to remove
    /// @param amount0 The amount of token0 withdrawn
    /// @param amount1 The amount of token1 withdrawn
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the output of the swap
    /// @param amount0 The delta of the token0 balance of the pool
    /// @param amount1 The delta of the token1 balance of the pool
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param liquidity The liquidity of the pool after the swap
    /// @param tick The log base 1.0001 of price of the pool after the swap
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolImmutables.sol

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IUniswapV3PoolOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param feeProtocol0 new protocol fee for token0 of the pool
    /// @param feeProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @param recipient The address to which collected protocol fees should be sent
    /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
    /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all ticks
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses the pool either as tick lower or
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(
        int24 tick
    )
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the owner, tickLower and tickUpper
    /// @return _liquidity The amount of liquidity in the position,
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(
        bytes32 key
    )
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(
        uint256 index
    )
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// lib/v3-core/contracts/libraries/SafeCast.sol

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types
library SafeCast {
    /// @notice Cast a uint256 to a uint160, revert on overflow
    /// @param y The uint256 to be downcasted
    /// @return z The downcasted integer, now type uint160
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    /// @notice Cast a int256 to a int128, revert on overflow or underflow
    /// @param y The int256 to be downcasted
    /// @return z The downcasted integer, now type int128
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    /// @notice Cast a uint256 to a int256, revert on overflow
    /// @param y The uint256 to be casted
    /// @return z The casted integer, now type int256
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2 ** 255);
        z = int256(y);
    }
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

// node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// node_modules/@openzeppelin/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// src/contracts/periphery/interfaces/IFraxswapRouterMultihop.sol

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

// src/contracts/periphery/interfaces/IPoolInterface.sol

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

// lib/v3-periphery/contracts/libraries/TransferHelper.sol

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "STF");
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "ST");
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SA");
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{ value: value }(new bytes(0));
        require(success, "STE");
    }
}

// lib/v3-core/contracts/interfaces/IUniswapV3Pool.sol

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{}

// src/contracts/periphery/FraxswapRouterMultihop.sol

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
