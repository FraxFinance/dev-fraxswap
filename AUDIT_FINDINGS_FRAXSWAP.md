# Fraxswap Security Audit Findings

**Repo**: dev-fraxswap
**Branch**: master (8f342f9)
**Date**: 2026-02-07
**Status**: Complete

---

## Table of Contents

### Periphery (FraxswapRouterMultihop)
- [F-01: swapType 255 Plugin — Unvalidated External Call (HIGH)](#f-01-swaptype-255-plugin--unvalidated-external-call-to-user-supplied-address)
- [F-02: Unprotected Uniswap V3 Callback (HIGH)](#f-02-unprotected-uniswap-v3-callback)

### TWAMM Core Math (LongTermOrders + FraxswapPair)
- [F-03: computeVirtualBalances Approximation (INFORMATIONAL)](#f-03-computevirtualbalances--bilateral-twamm-approximation)
- [F-04: Unchecked rewardFactor Arithmetic (INFORMATIONAL)](#f-04-intentional-overflowunderflow-in-rewardfactor-arithmetic)
- [F-05: Rounding Dust from Precision (INFORMATIONAL)](#f-05-rounding-dust-from-sell_rate_additional_precision)
- [F-06: Reserve Accounting Consistency (INFORMATIONAL)](#f-06-reserve-accounting-consistency)
- [F-07: Unsafe uint112 Casts (LOW)](#f-07-unsafe-uint112-casts-in-longtermswap-functions)
- [F-08: Virtual Order Execution Gas DoS (MEDIUM)](#f-08-virtual-order-execution-gas-dos)
- [F-09: sellingRate Edge Cases (INFORMATIONAL)](#f-09-sellingrate-edge-cases)

### Access Control (P1)
- [F-10: Ownership Check After State Modification (INFORMATIONAL)](#f-10-ownership-check-after-state-modification-in-cancelwithdraw)
- [F-11: One-Way Pause Without Unpause Mechanism (LOW)](#f-11-one-way-pause-without-unpause-mechanism)
- [F-12: feeToSetter Single-Step Transfer (LOW)](#f-12-feetosetter-single-step-transfer)
- [F-13: Permissionless Pair Creation with Custom Fee (LOW)](#f-13-permissionless-pair-creation-with-custom-fee)

### Standard AMM Edge Cases (P2)
- [F-14: Curve V2 swapType 3 — amountOut via Total Balance (LOW)](#f-14-curve-v2-swaptype-3--amountout-via-total-balance)
- [F-15: Lingering Token Approvals in Multihop Router (LOW)](#f-15-lingering-token-approvals-in-multihop-router)
- [F-16: TWAP Observation Array Unbounded Growth (INFORMATIONAL)](#f-16-twap-observation-array-unbounded-growth)
- [F-17: Fee Encoding and K-Check Correctness (INFORMATIONAL)](#f-17-fee-encoding-and-k-check-correctness)
- [F-18: First Depositor Attack Mitigation (INFORMATIONAL)](#f-18-first-depositor-attack-mitigation)
- [F-19: Unrestricted receive() in Multihop Router (INFORMATIONAL)](#f-19-unrestricted-receive-in-multihop-router)

### ERC20, Factory, Helpers (P3)
- [F-20: Immutable DOMAIN_SEPARATOR — Cross-Chain Permit Replay (LOW)](#f-20-immutable-domain_separator--cross-chain-permit-replay)
- [F-21: ERC20 Transfer to address(0) Not Blocked (INFORMATIONAL)](#f-21-erc20-transfer-to-address0-not-blocked)
- [F-22: TransferHelper / Math / UQ112x112 Libraries (INFORMATIONAL)](#f-22-transferhelper--math--uq112x112-libraries)

---

## F-01: swapType 255 Plugin — Unvalidated External Call to User-Supplied Address

**Severity**: HIGH
**Contract**: `FraxswapRouterMultihop.sol:326-339`
**Category**: Access Control / Untrusted External Call

### Description

When `swapType == 255`, `executeSwap` calls an arbitrary `IPluginSwaptype` contract at an address entirely specified by the user via `step.extraParam1`:

```solidity
} else if (step.swapType == 255) {
    // Plugin
    address plugin = address(uint160(step.extraParam1));
    if (step.directFundThisPool == 0) TransferHelper.safeApprove(prevRoute.tokenOut, plugin, amountIn);
    amountOut = IPluginSwaptype(plugin).swap(
        prevRoute.tokenOut,
        step.tokenOut,
        amountIn,
        step.pool,
        step.directFundThisPool,
        step.directFundNextPool == 1 ? getNextDirectFundingPool(route, recipient) : address(this),
        step.extraParam2
    );
}
```

Note: On the old `travis` branch this was a raw `delegatecall` (CRITICAL). On master, it has been changed to a regular external call via `IPluginSwaptype`, which reduces severity but still has issues.

### Call Chain

All data is user-supplied with no validation:

```
swap(FraxswapParams)                           // user calls with arbitrary params.route
  abi.decode(params.route) -> FraxswapRoute    // user-controlled
    executeAllHops()
      executeAllStepsForRoute()
        abi.decode(route.steps[j]) -> FraxswapStepData   // user-controlled
          executeSwap()
            if step.swapType == 255 -> IPluginSwaptype(user_address).swap(...)
```

### Impact

**Approval Drain**: When `step.directFundThisPool == 0` (line 329), the router calls `safeApprove(prevRoute.tokenOut, plugin, amountIn)` — granting the attacker's plugin contract an ERC-20 approval on the router. A malicious plugin can:
1. Receive the approval
2. Call `transferFrom(router, attacker, amountIn)` within its `swap()` function to take the tokens
3. Return any `amountOut` value it likes (including 0)

Since the router holds intermediate tokens during multi-step swaps, this can drain those tokens.

**Return Value Manipulation**: The plugin controls the return value. If the plugin is a middle step, it can report a large `amountOut` without actually sending tokens, which inflates `route.amountOut` and may cause downstream steps to attempt transfers that fail or succeed with unexpected amounts.

**No Whitelist**: There is no registry, whitelist, or governance check on which plugin addresses are allowed. Any address conforming to `IPluginSwaptype` is accepted.

### Mitigating Factors (vs old branch)

- This is now a regular `call` not `delegatecall`, so the plugin **cannot** modify the router's storage or execute code in its context.
- The reentrancy guard (`nonReentrant` on `swap()`) prevents the plugin from re-entering the top-level `swap` function. However, the callback `uniswapV3SwapCallback` is NOT protected by `nonReentrant` and could be called by the plugin.

### Likelihood

High. Route data is 100% user-controlled, no special setup required.

### Recommended Fix

Add a plugin whitelist controlled by governance:

```solidity
mapping(address => bool) public approvedPlugins;

function setPluginApproval(address plugin, bool approved) external onlyOwner {
    approvedPlugins[plugin] = approved;
}
```

Then in the `swapType == 255` branch:
```solidity
address plugin = address(uint160(step.extraParam1));
require(approvedPlugins[plugin], "FSR:Unapproved plugin");
```

Additionally, after the plugin call completes, reset the approval to zero to prevent lingering allowances:
```solidity
if (step.directFundThisPool == 0) {
    TransferHelper.safeApprove(prevRoute.tokenOut, plugin, amountIn);
}
amountOut = IPluginSwaptype(plugin).swap(...);
if (step.directFundThisPool == 0) {
    TransferHelper.safeApprove(prevRoute.tokenOut, plugin, 0); // revoke leftover approval
}
```

---

## F-02: Unprotected Uniswap V3 Callback

**Severity**: HIGH
**Contract**: `FraxswapRouterMultihop.sol:138-149`
**Category**: Access Control / Missing Validation

### Description

The V3 swap callback has no `msg.sender` validation:

```solidity
function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata _data) external {
    require(amount0Delta > 0 || amount1Delta > 0);
    SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
    if (!data.directFundThisPool) {
        TransferHelper.safeTransfer(
            data.tokenIn,
            msg.sender,          // sends tokens to WHOEVER called this
            uint256(amount0Delta > 0 ? amount0Delta : amount1Delta)
        );
    }
}
```

The standard Uniswap V3 SwapRouter verifies that `msg.sender` is the expected pool address computed from `factory + token0 + token1 + fee`. This router does not.

### Attack Vector 1: Direct External Call

If the router holds any token balance (dust, stuck tokens, mid-transaction):

1. Attacker calls `uniswapV3SwapCallback(desired_amount, 0, abi.encode(SwapCallbackData(targetToken, false)))` directly.
2. Router transfers `desired_amount` of `targetToken` to the attacker.
3. The only check is `amount0Delta > 0 || amount1Delta > 0` — attacker controls this.

### Attack Vector 2: Malicious V3 Pool in User Route

Exploitable during normal swap execution via user-supplied route:

1. Attacker calls `swap()` with a multi-step route.
2. **Step 1** (swapType 0/1): Legitimate swap leaves intermediate tokens (e.g., USDC) in the router.
3. **Step 2** (swapType 2): Points `step.pool` at a malicious contract pretending to be a V3 pool.

The malicious pool:
```solidity
function swap(address, bool, int256, uint160, bytes calldata) external returns (int256, int256) {
    // Ignore original callbackData, craft attacker-controlled data
    IUniswapV3SwapCallback(msg.sender).uniswapV3SwapCallback(
        int256(IERC20(USDC).balanceOf(msg.sender)),  // drain full balance
        0,
        abi.encode(SwapCallbackData(USDC, false))     // tell router to send USDC
    );
    return (0, 0);
}
```

The callback data (`tokenIn`, `directFundThisPool`) is attacker-controlled because the malicious pool can pass **different callback data** than what the router originally encoded. The router never verifies the returned callback data matches what it sent.

### Compounds with F-01

The plugin (F-01) can also call `uniswapV3SwapCallback` on the router since it's an external function with no access control and not protected by `nonReentrant` (only `swap()` has the guard). This gives the plugin a second path to drain tokens.

### Likelihood

High. Constructing a malicious V3 pool contract is trivial. `step.pool` in the route is user-controlled.

### Recommended Fix

Verify `msg.sender` is a legitimate Uniswap V3 pool. The standard approach is to compute the expected pool address from the factory and check it matches:

```solidity
function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata _data) external {
    require(amount0Delta > 0 || amount1Delta > 0);
    SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));

    // Verify msg.sender is the expected V3 pool
    // Option A: maintain a mapping of known V3 pools (set during swap execution)
    require(msg.sender == _expectedV3Pool, "FSR:Invalid callback sender");

    if (!data.directFundThisPool) {
        TransferHelper.safeTransfer(
            data.tokenIn,
            msg.sender,
            uint256(amount0Delta > 0 ? amount0Delta : amount1Delta)
        );
    }
}
```

A simpler approach: store the expected pool address in a transient storage variable before calling `IUniswapV3Pool.swap()`, and verify it in the callback:

```solidity
address private _cachedPool; // set before V3 swap, checked in callback

// In executeSwap, swapType == 2:
_cachedPool = step.pool;
IUniswapV3Pool(step.pool).swap(...);
_cachedPool = address(0);

// In callback:
require(msg.sender == _cachedPool, "FSR:Invalid callback sender");
```

---

## TWAMM Math Analysis

**Status**: Complete
**Contracts**: `LongTermOrders.sol`, `FraxswapPair.sol`

---

## F-03: `computeVirtualBalances` — Bilateral TWAMM Approximation

**Severity**: INFORMATIONAL (no vulnerability found)
**Contract**: `LongTermOrders.sol:175-205`
**Category**: Math Correctness

### Analysis

The bilateral TWAMM case (both order pools selling simultaneously):

```solidity
uint256 newToken0 = token0Start + ((token0In * fee) / 10_000);
uint256 newToken1 = token1Start + ((token1In * fee) / 10_000);
token0Out = newToken0 - ((token1Start * (newToken0)) / (newToken1));
token1Out = newToken1 - ((token0Start * (newToken1)) / (newToken0));
```

This computes:
- `token0Out = newToken0 * y_fee / newToken1` (token0 given to token1 sellers)
- `token1Out = newToken1 * x_fee / newToken0` (token1 given to token0 sellers)

Where `x_fee` and `y_fee` are the fee-adjusted sell amounts.

**Constant product check**: The AMM reserves after the swap portion become:
- `R0' = R1 * newToken0 / newToken1`
- `R1' = R0 * newToken1 / newToken0`
- `K' = R0' * R1' = R0 * R1 = K` (constant product preserved for the swap portion)

LP fees are captured separately: the full sell amounts go into reserves but only fee-adjusted amounts participate in the swap, so the fee portion accretes to reserves.

**Approximation vs Paradigm TWAMM**: The Paradigm TWAMM uses continuous exponential/hyperbolic formulas. Fraxswap's formula is a discrete approximation that processes each interval as a single batch. This gives traders *slightly less favorable* prices than the ideal continuous TWAMM, which is the **safe direction** (LP-favorable, not exploitable by traders).

**Division by zero**: Impossible. In the bilateral path, both `token0In >= 2` and `token1In >= 2` (guarded by the `< 2` checks). With `fee >= 9900`, `newToken0 >= token0Start + 1 >= 1` and `newToken1 >= token1Start + 1 >= 1`.

**Integer overflow in multiplication**: `token1Start * newToken0` could overflow for very large reserves. Both values are bounded by `type(uint112).max` (~5.2e33), so the product is bounded by ~2.7e67, well within `type(uint256).max` (~1.16e77). Safe.

### The `< 2` Threshold

Lines 185-189 use `< 2` instead of `== 0` to decide between one-sided and bilateral formulas. This means a sell amount of exactly 1 wei is treated as "no sell" for that side. This is intentional to avoid edge cases in the bilateral formula with near-zero amounts. The 1 wei "lost" per interval is negligible.

### Verdict

The formula is mathematically sound and conservative for traders (discrete batch processing gives slightly worse prices than ideal continuous TWAMM). In real arithmetic, K is exactly preserved. In integer arithmetic, floor division causes `R0' * R1' <= K` per interval — a negligible rounding loss of a few wei (see F-05 for dust analysis). No exploitable value extraction is possible.

---

## F-04: Intentional Overflow/Underflow in rewardFactor Arithmetic

**Severity**: INFORMATIONAL (by design, verified correct)
**Contract**: `LongTermOrders.sol:410-417, 452-458, 502-517`
**Category**: Math / Unchecked Arithmetic

### Analysis

The reward distribution uses the [Scalable Reward Distribution](https://uploads-ssl.webflow.com/5ad71ffeb79acc67c8bcdaba/5ad8d1193a40977462982470_scalable-reward-distribution-paper.pdf) algorithm. `rewardFactor` accumulates `payment / totalStaked` over time, and each order's reward is `(rewardFactor_now - rewardFactor_at_deposit) * stake`.

**Unchecked addition** (line 412-414):
```solidity
unchecked {
    orderPool.rewardFactor += (amount * Q112 * SELL_RATE_ADDITIONAL_PRECISION) / orderPool.currentSalesRate;
}
```

**Unchecked subtraction** (e.g., lines 504-507):
```solidity
unchecked {
    totalReward = (((rewardFactorAtExpiry - rewardFactorAtSubmission) * stakedAmount) /
        SELL_RATE_ADDITIONAL_PRECISION) / Q112;
}
```

This relies on modular arithmetic: if `rewardFactor` wraps past `2^256`, the subtraction `rewardFactor - rewardFactorAtSubmission` still gives the correct mathematical delta as long as the factor wraps at most **once** between deposit and withdrawal.

**Can it wrap more than once?**

The increment per distribution: `(amount * 2^112 * 10^6) / currentSalesRate`

With realistic values (amount ~10^18, currentSalesRate ~10^20):
- Increment ≈ `10^18 * 5.2e33 * 10^6 / 10^20` ≈ `5.2e37` ≈ `2^123`

To overflow `2^256` requires `2^(256-123)` = `2^133` ≈ `10^40` distributions. At one per 3600 seconds, that's `~10^33` years. **Wrapping more than once is physically impossible**.

### Verdict

The unchecked arithmetic is correct and safe for the scalable reward distribution pattern.

---

## F-05: Rounding Dust from SELL_RATE_ADDITIONAL_PRECISION

**Severity**: INFORMATIONAL
**Contract**: `LongTermOrders.sol:111, 257-260, 297-300, 450`
**Category**: Precision / Economic

### Analysis

Selling rate calculation:
```solidity
sellingRate = (SELL_RATE_ADDITIONAL_PRECISION * amount) / (orderExpiry - currentTime);
// = (1_000_000 * amount) / duration
```

Amount sold per interval:
```solidity
sellAmount = (sellingRate * elapsed) / SELL_RATE_ADDITIONAL_PRECISION;
// ≈ (amount * elapsed) / duration  (with rounding)
```

Due to integer division truncation at each step:
1. **Total sold <= deposited amount**: Since `sellingRate` rounds down, `sellingRate * duration <= 10^6 * amount`, so total sold over the full duration <= `amount`. Users always sell slightly less.
2. **Dust stays in twammReserve**: The unsold remainder (a few wei) stays in the pair's twammReserve permanently. There's no sweep mechanism.
3. **Dust per order**: Max ~1 wei per interval of rounding error. Over 1000 intervals ≈ 1000 wei. Negligible for any real token.

On cancel, `unsoldAmount = ((expiry - blockTimestamp) * salesRate) / SELL_RATE_ADDITIONAL_PRECISION` also rounds down, so the user gets back slightly less than the actual unsold portion. The difference stays in twammReserve.

### Verdict

Accepted precision limitation. The `SELL_RATE_ADDITIONAL_PRECISION = 10^6` multiplier keeps rounding error negligible. Dust accumulation over the lifetime of the protocol is immaterial.

---

## F-06: Reserve Accounting Consistency

**Severity**: INFORMATIONAL (no vulnerability found)
**Contract**: `FraxswapPair.sol`, `LongTermOrders.sol:209-232`
**Category**: Invariant Verification

### The Invariant

`token_balance_in_contract = reserve + twammReserve` (for each token)

### Verification

All state modifications preserve the invariant:

| Operation | reserve | twammReserve | token balance | Invariant |
|-----------|---------|--------------|---------------|-----------|
| `longTermSwapFrom0To1` | unchanged | `+= amount` | `+= amount` (transferAmountIn) | Preserved |
| `cancelLongTermSwap` | unchanged | `-= amounts` | `-= amounts` (_safeTransfer) | Preserved |
| `withdrawProceeds` | unchanged | `-= proceeds` | `-= proceeds` (_safeTransfer) | Preserved |
| `executeVirtualOrders` | updated | updated | unchanged (no transfers) | See below |
| `swap` / `mint` / `burn` | updated via _update | unchanged | changes via transfers | Preserved (uses `balance - twammReserve`) |

For `executeVirtualOrdersInternal` (line 535-563), the key accounting in `executeVirtualTradesAndOrderExpiries`:
```
bal0 = reserve0 + twammReserve0          // save total
newTwammReserve0 = twammReserve0 + token0Out - token0SellAmount
newReserve0 = bal0 - newTwammReserve0    // => newReserve0 + newTwammReserve0 = bal0
```

The invariant `reserve + twammReserve = total` is explicitly maintained by computing one from the other.

**Potential edge case with `_update` overflow check** (FraxswapPair:286):
```solidity
if (!(balance0 + twammReserve0 <= type(uint112).max ...)) revert Uint112Overflow();
```
This ensures `reserve + twammReserve <= uint112.max`, which also means the `uint112()` casts in `executeVirtualTradesAndOrderExpiries` lines 230-231 are safe (result <= bal0 <= uint112.max).

### Verdict

Reserve accounting is correct. The dual-reserve system consistently maintains the invariant.

---

## F-07: Unsafe uint112 Casts in longTermSwap Functions

**Severity**: LOW
**Contract**: `FraxswapPair.sol:468, 483, 496-497, 517, 519, 549-553`
**Category**: Integer Truncation

### Description

Multiple locations cast `uint256` values to `uint112` without using SafeCast:

**Deposit path** (lines 467-469):
```solidity
uint256 amount0 = transferAmountIn(token0, amount0In);
twammReserve0 += uint112(amount0);                             // cast FIRST
require(uint256(reserve0) + twammReserve0 <= type(uint112).max); // check AFTER
```

The `uint112()` cast on line 468 happens **before** the overflow check on line 469. If `amount0 > type(uint112).max`, the cast silently truncates. The subsequent require passes because twammReserve0 received the truncated (small) value.

Result: The contract receives the full `amount0` tokens but only tracks `uint112(amount0)` in twammReserve. The excess tokens become permanently locked — accessible via `skim()` but not properly accounted for in the order.

**Cancel/Withdraw paths** (lines 496-497, 517, 519):
```solidity
twammReserve0 -= uint112(purchasedAmount);  // truncation risk
```

If `purchasedAmount > type(uint112).max`, the subtracted value is truncated, leaving excess in twammReserve (favorable to the protocol, unfavorable to the user).

**Virtual order execution** (lines 549-553):
```solidity
twammReserve0 = uint112(result.newTwammReserve0);
twammReserve1 = uint112(result.newTwammReserve1);
uint112 newReserve0 = uint112(result.newReserve0);
uint112 newReserve1 = uint112(result.newReserve1);
```

These values derive from initial uint112 reserves through bounded arithmetic. The `_update` function on line 286 validates the sum fits in uint112. So these casts are safe in practice, but lack explicit checks.

### Practical Impact

Exploiting the deposit truncation requires depositing > 2^112 tokens (~5.2e33). For 18-decimal tokens, that's ~5.2e15 whole tokens. For most tokens this is unrealistic. For low-decimal tokens (e.g., 2 decimals), 2^112 is ~5.2e31 units — still extreme.

### Verdict

Theoretical bug with negligible practical impact. The cast-before-check pattern on lines 468-469 is a real code defect.

### Recommended Fix

Check before casting. In `longTermSwapFrom0To1` (and similarly in `longTermSwapFrom1To0`):

```solidity
uint256 amount0 = transferAmountIn(token0, amount0In);
require(amount0 <= type(uint112).max, "TWAMM: amount overflow"); // check FIRST
twammReserve0 += uint112(amount0);                                // cast AFTER
require(uint256(reserve0) + twammReserve0 <= type(uint112).max);  // total check
```

For the cancel/withdraw paths, the same pattern applies:
```solidity
require(purchasedAmount <= type(uint112).max && unsoldAmount <= type(uint112).max, "TWAMM: overflow");
twammReserve0 -= uint112(buyToken0 ? purchasedAmount : unsoldAmount);
twammReserve1 -= uint112(buyToken0 ? unsoldAmount : purchasedAmount);
```

Alternatively, use OpenZeppelin's `SafeCast.toUint112()` which reverts on truncation.

---

## F-08: Virtual Order Execution Gas DoS

**Severity**: MEDIUM
**Contract**: `LongTermOrders.sol:249-292`
**Category**: Denial of Service / Gas Exhaustion

### Description

`executeVirtualOrdersUntilTimestamp` iterates through every `orderTimeInterval` (3600 seconds) between `lastVirtualOrderTimestamp` and `blockTimestamp`:

```solidity
while (nextExpiryBlockTimestamp <= blockTimestamp) {
    if (salesRateEndingPerTimeInterval[...] > 0 || ...) {
        // expensive: compute trades, update state, emit event
    }
    nextExpiryBlockTimestamp += orderTimeInterval;
}
```

The `execVirtualOrders` modifier on `swap`, `mint`, `burn`, and the long-term swap functions calls `executeVirtualOrdersInternal(block.timestamp)`, which triggers this loop.

### Gas Cost Analysis

| Inactivity Period | Iterations | Gas (no expiries) | Gas (with expiries) |
|---|---|---|---|
| 1 day | 24 | ~120K | ~2.4M |
| 1 week | 168 | ~840K | ~16.8M |
| 1 month | 720 | ~3.6M | **~72M** (exceeds block limit) |
| 3 months | 2,160 | ~10.8M | **~216M** |

Per-iteration costs:
- **No expiries**: ~2 cold SLOADs + loop overhead ≈ ~5,000 gas
- **With expiries**: SLOADs, SSTOREs, computation, emit ≈ ~50,000-100,000 gas

### Attack Scenario

1. Attacker creates long-term orders with many different expiry timestamps spread across a long period.
2. No one interacts with the pair for weeks/months.
3. When someone tries to `swap()`, `mint()`, or `burn()`, the `execVirtualOrders` modifier triggers the catch-up loop.
4. Transaction reverts due to gas exhaustion. The pair is temporarily frozen.

### Mitigation

The public `executeVirtualOrders(uint256 blockTimestamp)` function (FraxswapPair:567) accepts an arbitrary timestamp, allowing incremental catch-up:
```solidity
function executeVirtualOrders(uint256 blockTimestamp) public lock {
    if (longTermOrders.lastVirtualOrderTimestamp < blockTimestamp && blockTimestamp <= block.timestamp) {
        executeVirtualOrdersInternal(blockTimestamp);
    }
}
```

Anyone can call this with intermediate timestamps to catch up in chunks. However, this requires awareness of the issue and manual intervention.

### Verdict

Temporary DoS vector. Mitigated by the incremental catch-up mechanism, but the pair can become unusable until someone manually intervenes.

### Recommended Fix

Add a maximum iteration cap to the while-loop to bound gas consumption. If the cap is hit, update `lastVirtualOrderTimestamp` to where the loop stopped and return, requiring another call to continue:

```solidity
uint256 constant MAX_ITERATIONS = 200; // ~8.3 days of catch-up
uint256 iterations;

while (nextExpiryBlockTimestamp <= blockTimestamp) {
    if (iterations++ >= MAX_ITERATIONS) {
        // Save progress and bail out — caller must invoke again to continue
        longTermOrders.lastVirtualOrderTimestamp = nextExpiryBlockTimestamp - orderTimeInterval;
        return;
    }
    // ... existing loop body ...
}
```

This ensures the pair never becomes completely stuck due to gas limits. The tradeoff is that very stale pairs require multiple catch-up transactions, but they remain functional.

Alternatively, a keeper bot or incentivized mechanism could be added to call `executeVirtualOrders()` regularly to prevent staleness.

---

## F-09: sellingRate Edge Cases

**Severity**: INFORMATIONAL
**Contract**: `LongTermOrders.sol:111-113`
**Category**: Edge Cases

### Analysis

```solidity
uint256 sellingRate = (SELL_RATE_ADDITIONAL_PRECISION * amount) / (orderExpiry - currentTime);
require(sellingRate > 0); // tokenRate cannot be zero
```

**Zero selling rate**: Occurs when `10^6 * amount < duration`. For a 1-hour order: rejected if `amount < 4` (since duration ≈ 3600). For a 1-year order: rejected if `amount < 32`.

The `require(sellingRate > 0)` correctly rejects these.

**Minimum selling rate (sellingRate = 1)**:
- Sell per interval: `(1 * 3600) / 10^6 = 0` (rounds to zero)
- The order exists but sells 0 tokens per interval, effectively acting as a no-op
- Contributes to `currentSalesRate` but negligibly (1 in ~10^20)
- On expiry, user gets full amount back via cancel (minus rounding dust)

**No DoS vector**: Each order creation costs the caller gas. Creating many trivial orders only wastes the attacker's own gas.

### Verdict

Edge cases handled correctly. Minimum sellingRate orders are inert but not harmful.

---

## Access Control Analysis (P1)

**Status**: Complete
**Contracts**: `FraxswapPair.sol`, `FraxswapFactory.sol`, `LongTermOrders.sol`, `GlobalPauseHelper.sol`

---

## F-10: Ownership Check After State Modification in Cancel/Withdraw

**Severity**: INFORMATIONAL
**Contract**: `LongTermOrders.sol:134-172`
**Category**: Access Control / Code Quality

### Description

Both `cancelLongTermSwap` and `withdrawProceedsFromLongTermSwap` in `LongTermOrdersLib` perform state modifications **before** checking that `msg.sender` is the order owner.

**cancelLongTermSwap** (lines 134-152):
```solidity
function cancelLongTermSwap(...) internal returns (...) {
    Order storage order = longTermOrders.orderMap[orderId];
    OrderPool storage orderPool = getOrderPool(longTermOrders, sellToken);
    (unsoldAmount, purchasedAmount) = orderPoolCancelOrder(     // STATE MODIFIED HERE
        orderPool, orderId, longTermOrders.lastVirtualOrderTimestamp
    );
    require(order.owner == msg.sender && ...);                  // OWNERSHIP CHECK HERE
}
```

Inside `orderPoolCancelOrder` (lines 461-465), these state changes happen before the require:
```solidity
orderPool.currentSalesRate -= salesRate;
orderPool.salesRate[orderId] = 0;
orderPool.orderExpiry[orderId] = 0;
orderPool.salesRateEndingPerTimeInterval[expiry] -= salesRate;
```

**withdrawProceedsFromLongTermSwap** (lines 155-172):
```solidity
function withdrawProceedsFromLongTermSwap(...) internal returns (...) {
    Order storage order = longTermOrders.orderMap[orderId];
    OrderPool storage orderPool = getOrderPool(longTermOrders, order.sellTokenAddr);
    (proceeds, orderExpired) = orderPoolWithdrawProceeds(       // STATE MODIFIED HERE
        orderPool, orderId, longTermOrders.lastVirtualOrderTimestamp
    );
    require(order.owner == msg.sender && proceeds > 0);         // OWNERSHIP CHECK HERE
}
```

### Impact

**No exploitable vulnerability.** If the ownership check fails, the `require` reverts the entire transaction, rolling back all state modifications. Solidity's atomic transaction model ensures no partial state changes persist.

However, this violates the **checks-effects-interactions** pattern. The recommended ordering is: (1) validate inputs, (2) modify state, (3) perform external calls. Here, state is modified before input validation.

Practical consequence: a non-owner calling cancel/withdraw for someone else's order wastes their own gas on state modifications that will be reverted. This is not a griefing vector since the caller pays their own gas.

### Verdict

Code quality issue only. Moving the ownership check before `orderPoolCancelOrder` / `orderPoolWithdrawProceeds` would be cleaner and save gas for invalid calls, but the current code is not exploitable.

---

## F-11: One-Way Pause Without Unpause Mechanism

**Severity**: LOW
**Contract**: `FraxswapPair.sol:715-719`, `FraxswapFactory.sol:77-80`
**Category**: Access Control / Emergency Mechanism Design

### Description

Both the factory's global pause and the pair's local pause are **one-way only** — once activated, they can never be deactivated.

**Factory** (`FraxswapFactory.sol:77-80`):
```solidity
function toggleGlobalPause() external onlyFTS {
    require(!globalPause);
    globalPause = true;          // no path to set back to false
}
```

**Pair** (`FraxswapPair.sol:715-719`):
```solidity
function togglePauseNewSwaps() external {
    require(!newSwapsPaused && IFraxswapFactory(factory).globalPause());
    newSwapsPaused = true;       // no path to set back to false
}
```

### Issues

**1. Misleading naming**: Both functions are called "toggle" but they only go one direction. `toggle` conventionally implies flipping between two states.

**2. No access control on `togglePauseNewSwaps`**: Anyone can call this on any pair — the only gate is that `globalPause` must be true on the factory. Once the `feeToSetter` activates global pause, **any address** can pause any individual pair.

**3. Permanent TWAMM shutdown**: When `newSwapsPaused = true`:
- New long-term orders are blocked (`isNotPaused` modifier on `longTermSwapFrom0To1` / `longTermSwapFrom1To0`)
- `executeVirtualOrdersInternal` returns immediately (line 536: `if (newSwapsPaused) return`), freezing all TWAMM execution
- The `execVirtualOrders` modifier becomes a no-op on `swap`, `mint`, `burn`

**4. Existing orders are frozen but recoverable**: Users with active orders can still call `cancelLongTermSwap` (no `isNotPaused` check), which returns unsold tokens and accumulated proceeds as of the last virtual order execution before the pause.

**5. Regular AMM functions still work**: `swap`, `mint`, `burn`, `skim`, `sync` are not gated by `isNotPaused`. The pair continues functioning as a standard Uniswap V2 pair.

### `GlobalPauseHelper` amplifies the issue

`GlobalPauseHelper.sol` provides a batch function that pauses multiple pairs in a single transaction:
```solidity
function globalPause(address[] calldata pairAddresses) external returns (bool[] memory successful) {
    for (uint256 i = 0; i < pairAddresses.length; ++i) {
        try IFraxswapPair(pairAddress).togglePauseNewSwaps() {
            successful[i] = true;
        } catch {}
    }
}
```
Anyone can call this once `globalPause` is enabled on the factory, permanently shutting down TWAMM for every pair in the array. The `try/catch` means it silently skips already-paused pairs.

### Verdict

Appears intentional as a nuclear emergency kill switch. The one-way design prevents accidental or malicious unpausing. However, the lack of an unpause mechanism means the only recovery path is redeploying all affected pair contracts and migrating liquidity.

### Recommended Fix

If unpause functionality is desired, add it behind the `onlyOwnerOrFactory` modifier:

```solidity
function togglePauseNewSwaps() external {
    if (!newSwapsPaused) {
        require(IFraxswapFactory(factory).globalPause()); // pause: requires global pause
        newSwapsPaused = true;
    } else {
        require(factory == msg.sender || IFraxswapFactory(factory).feeToSetter() == msg.sender);
        newSwapsPaused = false; // unpause: admin only
    }
}
```

If one-way is intentional, rename to `pauseNewSwaps()` to avoid confusion.

---

## F-12: feeToSetter Single-Step Transfer

**Severity**: LOW
**Contract**: `FraxswapFactory.sol:73-75`
**Category**: Access Control / Centralization Risk

### Description

The `feeToSetter` admin role controls critical operations across the entire protocol:
- `setFeeTo` — set fee recipient for all pairs
- `setFeeToSetter` — transfer admin ownership
- `toggleGlobalPause` — permanently freeze TWAMM on all pairs
- Indirectly via `onlyOwnerOrFactory` modifier: `setFee` on any pair

The transfer of this role is a **single-step** process with no confirmation:

```solidity
function setFeeToSetter(address _feeToSetter) external onlyFTS {
    feeToSetter = _feeToSetter;
}
```

### Impact

**Irreversible admin loss**: If `_feeToSetter` is set to an incorrect address (typo, wrong checksum, contract without ability to call back), the admin role is permanently lost. There is no recovery mechanism.

**Consequences of lost admin**:
- Cannot change fee on any pair
- Cannot set fee recipient
- Cannot activate global pause (emergency shutdown unavailable)
- Cannot transfer admin to a correct address

**feeToSetter also controls all pair fees via `onlyOwnerOrFactory`**:
```solidity
modifier onlyOwnerOrFactory() {
    require(factory == msg.sender || IFraxswapFactory(factory).feeToSetter() == msg.sender);
    _;
}
```

Note: The `factory == msg.sender` branch is effectively dead code — the current factory has no code path that calls `setFee` on pairs. In practice, `onlyOwnerOrFactory` is equivalent to `require(feeToSetter == msg.sender)`.

### Verdict

Standard centralization risk found in many Uniswap V2 forks. The single-step transfer is a known anti-pattern.

### Recommended Fix

Implement a two-step transfer pattern:

```solidity
address public pendingFeeToSetter;

function setPendingFeeToSetter(address _pendingFeeToSetter) external onlyFTS {
    pendingFeeToSetter = _pendingFeeToSetter;
}

function acceptFeeToSetter() external {
    require(msg.sender == pendingFeeToSetter);
    feeToSetter = pendingFeeToSetter;
    pendingFeeToSetter = address(0);
}
```

This ensures the new admin can actually call the contract before the transfer is finalized.

---

## F-13: Permissionless Pair Creation with Custom Fee

**Severity**: LOW
**Contract**: `FraxswapFactory.sol:52-67`
**Category**: Access Control / Front-Running

### Description

`createPair` is callable by anyone with an arbitrary fee parameter (1–100 basis points):

```solidity
function createPair(address tokenA, address tokenB, uint256 fee) public returns (address pair) {
    if (tokenA == tokenB) revert IdenticalAddress();
    (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    if (token0 == address(0)) revert ZeroAddress();
    if (getPair[token0][token1] != address(0)) revert PairExists();
    // ... create2 deployment ...
    FraxswapPair(pair).initialize(token0, token1, fee);
    // ...
}
```

Key properties:
1. **No access control** — anyone can create a pair
2. **Caller chooses the fee** — range 1 (0.01%) to 100 (1%), validated by `feeCheck` modifier in `initialize`
3. **Only one pair per token pair** — `PairExists` check prevents duplicates
4. **First creator wins** — whoever creates the pair first locks in the fee
5. **CREATE2 salt does not include fee** — `salt = keccak256(abi.encodePacked(token0, token1))`, so the pair address is deterministic regardless of the chosen fee

### Attack Scenario

1. Attacker monitors the mempool for `createPair` transactions.
2. Attacker front-runs with the same token pair but an extreme fee:
   - `fee = 1` (0.01%): minimizes LP revenue, disadvantaging liquidity providers
   - `fee = 100` (1%): maximizes slippage cost for traders
3. The legitimate caller's transaction reverts with `PairExists`.

### Mitigating Factors

- The `feeToSetter` admin can correct the fee via `setFee` on the pair, so the attack is recoverable.
- The default overload `createPair(tokenA, tokenB)` uses fee = 30 (0.30%), so standard tooling gets the default.
- CREATE2 deterministic addressing means the pair address remains the same regardless of fee, so integrations are unaffected.

### Verdict

Standard behavior inherited from Uniswap V2. The permissionless creation is a feature. The fee front-running is a nuisance but not a security issue since `feeToSetter` can correct it.

### Recommended Fix

If fee front-running is a concern, restrict the custom fee overload:

```solidity
function createPair(address tokenA, address tokenB, uint256 fee) public returns (address pair) {
    require(msg.sender == feeToSetter, "FSF: custom fee restricted");
    // ... existing logic ...
}
```

This keeps the default `createPair(tokenA, tokenB)` permissionless (always 0.30%) while restricting custom fees to the admin.

---

## Standard AMM Edge Cases (P2)

**Status**: Complete
**Contracts**: `FraxswapPair.sol`, `FraxswapRouter.sol`, `FraxswapRouterLibrary.sol`, `FraxswapRouterMultihop.sol`

---

## F-14: Curve V2 swapType 3 — amountOut via Total Balance

**Severity**: LOW
**Contract**: `FraxswapRouterMultihop.sol:206-210`
**Category**: Accounting / Multi-Step Routing

### Description

SwapType 3 (Curve V2 exchange) determines `amountOut` using the router's full token balance rather than the swap's actual output:

```solidity
} else if (step.swapType == 3) {
    // Curve exchange V2
    TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
    PoolInterface(step.pool).exchange(step.extraParam1, step.extraParam2, amountIn, 0);
    amountOut = IERC20(step.tokenOut).balanceOf(address(this));  // TOTAL balance, not delta
}
```

The Curve V2 `exchange(uint256,uint256,uint256,uint256)` function doesn't return the output amount, so the code uses `balanceOf` as a workaround. Other swap types (4, 5, 6, 7, 8, 12, 13, 14) correctly use the return value from their respective pool calls.

### Double-Counting Scenario

When a route has multiple steps (split-route for the same trade), all steps share the same output token. The bug triggers whenever a type-3 step follows **any** earlier step that left output tokens in the router — not just other type-3 steps.

**Example with mixed types**:

1. **Step 1** (type 0 — UniV2): swap outputs 100 tokenX to router. `amountOut = 100` (computed from reserves). `route.amountOut = 100`.
2. **Step 2** (type 3 — Curve V2): exchange outputs 50 tokenX to router. `amountOut = balanceOf(router, tokenX)` = **150** (includes step 1's 100). `route.amountOut = 100 + 150 = 250`.

The actual output is 150, but `route.amountOut` reports 250. This inflated value propagates to the next hop via `getAmountForPct`:

```solidity
uint256 amountIn = getAmountForPct(step.percentOfHop, route.percentOfHop, prevRoute.amountOut);
// prevRoute.amountOut = 250 (inflated), actual tokens available = 150
```

The issue applies to any type-3 step that is NOT the first step in a route (or is the first step but the router already holds the output token from a prior hop).

### Impact

**No direct fund loss.** The final slippage check in `swap()` uses the actual router balance or recipient balance diff:

```solidity
amountOut = outputETH ? address(this).balance : IERC20(params.tokenOut).balanceOf(address(this));
// ... or if !CHECK_AMOUNTOUT_IN_ROUTER:
amountOut = IERC20(params.tokenOut).balanceOf(params.recipient) - initialBalance;
```

Both correctly reflect reality. The double-counting only affects intermediate hop calculations, which would cause the next hop to request more tokens than available, resulting in a **revert** (failed transaction). So the impact is DoS for specific multi-step routes that include a type-3 swap, not fund loss.

### Verdict

Routing issue affecting any multi-step route with a type-3 Curve V2 step (not only routes with multiple type-3 steps). The trigger condition is broader than it first appears.

### Recommended Fix

Track the balance delta instead of the absolute balance:

```solidity
} else if (step.swapType == 3) {
    TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
    uint256 balBefore = IERC20(step.tokenOut).balanceOf(address(this));
    PoolInterface(step.pool).exchange(step.extraParam1, step.extraParam2, amountIn, 0);
    amountOut = IERC20(step.tokenOut).balanceOf(address(this)) - balBefore;
}
```

---

## F-15: Lingering Token Approvals in Multihop Router

**Severity**: LOW
**Contract**: `FraxswapRouterMultihop.sol` (swap types 3, 4, 5, 6, 7, 8, 11, 14, 255)
**Category**: Token Approval Hygiene

### Description

Nine swap types call `TransferHelper.safeApprove` to authorize external pools before swapping, but never reset the approval to zero afterward:

| SwapType | Pool Type | Line |
|----------|-----------|------|
| 3 | Curve V2 | 208 |
| 4 | Curve (int128, returns) | 213 |
| 5 | Curve exchange_underlying | 222 |
| 6 | Saddle | 231 |
| 7 | FPIController | 241 |
| 8 | ERC4626/Fraxlend | 249 |
| 11 | Curve (ETH, returns) | 284 |
| 14 | Curve (receiver) | 318 |
| 255 | Plugin | 329 |

Pattern:
```solidity
TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
PoolInterface(step.pool).exchange(...);
// No: TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, 0);
```

### Impact

If a pool does not consume the full approved amount (e.g., due to rounding, partial fills, or pool-specific behavior), the leftover approval persists. This means:

1. The pool retains the ability to `transferFrom` the remaining approved amount from the router.
2. If the router later holds tokens of the same type (from a subsequent swap), a malicious or compromised pool could steal them.

In practice, the router should not hold user tokens between transactions (`nonReentrant` + tokens are transferred out at the end of `swap()`). However, residual approvals are a surface area for attacks if any token becomes unexpectedly stuck in the router.

This is also inconsistent with F-01's recommendation to revoke plugin approvals after use.

### Verdict

Low practical risk given the router's transaction-scoped token handling, but violates the principle of least privilege for token approvals.

### Recommended Fix

Reset approvals to zero after each swap step:

```solidity
TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
PoolInterface(step.pool).exchange(...);
TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, 0); // revoke
```

Note: Some tokens (like USDT) revert if `approve` is called with a non-zero value when the current allowance is non-zero. The existing `safeApprove` pattern works because it sets a fresh value each time. Adding a reset to zero after each swap avoids this issue since the pool should have consumed the full allowance.

---

## F-16: TWAP Observation Array Unbounded Growth

**Severity**: INFORMATIONAL
**Contract**: `FraxswapPair.sol:150, 294-300`
**Category**: Storage Growth / Gas Economics

### Description

The TWAP observation history is stored as an unbounded dynamic array:

```solidity
TWAPObservation[] public TWAPObservationHistory;
```

A new entry is pushed on every `_update` call when `timeElapsed > 0` (first transaction in each block):

```solidity
if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
    TWAPObservationHistory.push(TWAPObservation(
        blockTimestamp,
        price0CumulativeLast() + uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed,
        price1CumulativeLast() + uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed
    ));
}
```

### Growth Analysis

| Timeframe | Blocks (12s) | Entries (if active every block) | Storage Slots (3 per entry) |
|-----------|--------------|--------------------------------|---------------------------|
| 1 year | ~2.6M | ~2.6M | ~7.8M |
| 5 years | ~13M | ~13M | ~39M |

Each push costs ~20,000 gas for the new storage slot. Access via `TWAPObservationHistory(i)` or `price0CumulativeLast()` (which reads the last element) is O(1) regardless of array size.

### Comparison to Uniswap

- **Uniswap V2**: Uses `price0CumulativeLast` and `price1CumulativeLast` as single storage slots (overwritten each block). No array growth.
- **Uniswap V3**: Uses a fixed-size ring buffer (`Oracle` library) with configurable cardinality.
- **Fraxswap**: Stores the full history as an unbounded array. More data available for TWAP consumers, but at the cost of ever-growing storage.

### Verdict

Not a vulnerability. The array growth is linear and each push is O(1). There is no pruning mechanism, so storage consumed by the pair grows monotonically. The `price0CumulativeLast()` / `price1CumulativeLast()` functions correctly read the last element for cumulative price calculations. This is a design choice — richer historical data at the cost of storage.

---

## F-17: Fee Encoding and K-Check Correctness

**Severity**: INFORMATIONAL (no vulnerability found)
**Contract**: `FraxswapPair.sol:45, 227-243, 408-416`
**Category**: Math Correctness

### Analysis

The `fee` storage variable uses an inverted encoding: `fee = 10_000 - inputFee`. For a 0.30% fee: `inputFee = 30`, `fee = 9970`.

**getAmountOut** (line 227-234):
```solidity
uint256 amountInWithFee = amountIn * fee;           // amountIn * 9970
uint256 numerator = amountInWithFee * reserveOut;    // amountIn * 9970 * reserveOut
uint256 denominator = (reserveIn * 10_000) + amountInWithFee;
return numerator / denominator;
```
Equivalent to standard formula: `amountOut = (amountIn * 0.997 * reserveOut) / (reserveIn + amountIn * 0.997)`. Correct.

**getAmountIn** (line 237-243):
```solidity
uint256 numerator = reserveIn * amountOut * 10_000;
uint256 denominator = (reserveOut - amountOut) * fee;
return (numerator / denominator) + 1;
```
Inverse formula with `+ 1` to round up (ensuring sufficient input). Correct.

**K-Check in swap()** (line 408-416):
```solidity
uint256 minusFee = 10_000 - fee;                    // = inputFee (e.g., 30)
uint256 balance0Adjusted = (balance0 * 10_000) - (amount0In * minusFee);
uint256 balance1Adjusted = (balance1 * 10_000) - (amount1In * minusFee);
require(balance0Adjusted * balance1Adjusted >= uint256(_reserve0) * _reserve1 * (10_000 ** 2));
```
The naming `minusFee` is confusing — it actually equals `inputFee` (the fee percentage, not the complement). But the math is correct: it deducts `inputFee / 10_000` of the input from the adjusted balance, ensuring the fee is collected.

**Overflow analysis for K multiplication**:
- `balance0Adjusted` max: `uint112.max * 10_000` ≈ `5.2e37` ≈ `2^128`
- `balance0Adjusted * balance1Adjusted` ≈ `2^256` (tight but within bounds)
- `_reserve0 * _reserve1 * 10_000^2` ≈ `(5.2e33)^2 * 10^8` ≈ `2.7e75` < `2^256`. Safe.

**Multihop router hardcoded fee** (`FraxswapRouterMultihop.sol:464`):
```solidity
uint256 amountInWithFee = amountIn * 997;  // hardcoded 0.3%
```
This is only used for swapType 1 (vanilla UniV2 pairs). Fraxswap V2 pairs (swapType 0) use `pair.getAmountOut()` when `extraParam1 == 1`, which reads the pair's actual fee. When `extraParam1 == 0` (Fraxswap V1 compatibility), the hardcoded 0.3% formula is used. Callers must ensure `extraParam1` is correctly set for pairs with custom fees.

### Verdict

Fee encoding is confusing but mathematically consistent across all usage sites. No overflow possible in the K-check multiplication. The `minusFee` variable name is misleading and should be renamed to `inputFee` or `feeNumerator` for clarity.

---

## F-18: First Depositor Attack Mitigation

**Severity**: INFORMATIONAL (no vulnerability found)
**Contract**: `FraxswapPair.sol:342-347`
**Category**: Economic Security

### Analysis

First-mint LP token calculation:
```solidity
if (_totalSupply == 0) {
    liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
    _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
} else {
    liquidity = Math.min((amount0 * _totalSupply) / _reserve0, (amount1 * _totalSupply) / _reserve1);
}
require(liquidity > 0);
```

The **inflation attack** (also known as the "donation attack") against LP share calculation:

1. Attacker is the first depositor, mints minimal LP tokens
2. Attacker donates a large amount directly to the pair (via `transfer`, not `mint`)
3. Subsequent depositors receive 0 LP tokens due to integer division truncation: `amount * totalSupply / (reserve + donation)` rounds to 0

**Mitigation**: `MINIMUM_LIQUIDITY = 10^3` permanently locks 1000 LP tokens at `address(0)`. This means even after the attacker removes their LP, 1000 tokens remain. For the attack to grief a deposit of value `v`, the attacker must donate `> 1000 * v` worth of tokens — making it economically prohibitive for meaningful deposits.

**TWAMM interaction**: During the first mint, `twammReserve0` and `twammReserve1` are 0 (no long-term orders can exist without liquidity), so the balance calculation `IERC20.balanceOf(address(this)) - twammReserve0` correctly reduces to the raw balance. No TWAMM-specific edge case.

### Verdict

Standard Uniswap V2 protection. The `MINIMUM_LIQUIDITY` lock is adequate. No TWAMM-specific amplification of the attack.

---

## F-19: Unrestricted receive() in Multihop Router

**Severity**: INFORMATIONAL
**Contract**: `FraxswapRouterMultihop.sol:51`
**Category**: ETH Handling

### Description

The multihop router accepts ETH from any sender without restriction:

```solidity
receive() external payable {}
```

This contrasts with the standard `FraxswapRouter.sol` which restricts ETH receipt:

```solidity
receive() external payable {
    assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
}
```

### Why It Exists

The multihop router handles multiple ETH-related swap types that require receiving ETH from various sources:

- **SwapType 9** (FrxETHMinter): Unwraps WETH then sends ETH via `submitAndGive{value: amountIn}`
- **SwapType 10** (WETH wrap/unwrap): `WETH9.withdraw(amountIn)` sends ETH to router
- **SwapType 11** (Curve ETH): Receives ETH from Curve pool output, wraps to WETH
- **ETH output**: User requests `tokenOut = address(0)`, router collects ETH and forwards

Restricting `receive()` to only known senders would be complex (multiple Curve pools, WETH, FrxETHMinter, etc.) and brittle.

### Impact

Any ETH accidentally sent to the router can be absorbed by the next ETH-output swap:

```solidity
amountOut = outputETH ? address(this).balance : IERC20(params.tokenOut).balanceOf(address(this));
```

This uses `address(this).balance` which includes any pre-existing ETH. The next swapper would receive the bonus ETH. This is standard router behavior — **routers are not intended to hold funds between transactions**.

### Verdict

Design property, not a vulnerability. The unrestricted `receive()` is necessary for the router's multi-protocol ETH handling. Users should never send ETH directly to the router outside of a swap transaction.

---

## ERC20, Factory, Helpers (P3)

**Status**: Complete
**Contracts**: `FraxswapERC20.sol`, `FraxswapFactory.sol`, `GlobalPauseHelper.sol`, `TransferHelper.sol`, `Math.sol`, `UQ112x112.sol`

---

## F-20: Immutable DOMAIN_SEPARATOR — Cross-Chain Permit Replay

**Severity**: LOW
**Contract**: `FraxswapERC20.sol:25, 33-43`
**Category**: EIP-2612 / Cryptographic

### Description

The `DOMAIN_SEPARATOR` is computed once at construction and stored as `immutable`:

```solidity
bytes32 public immutable DOMAIN_SEPARATOR;

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
```

The `permit` function uses this stored value:

```solidity
bytes32 digest = keccak256(
    abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,    // immutable — always contains the construction-time chainId
        keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
    )
);
```

### Cross-Chain Replay Scenario

If the chain hard-forks (e.g., ETH/ETC-style split):

1. The pair contract exists at the **same address** on both chains (CREATE2 with deterministic salt).
2. `DOMAIN_SEPARATOR` on both copies contains the **original chain's** `chainId`.
3. After the fork, `block.chainid` returns different values on each chain, but the stored `DOMAIN_SEPARATOR` still has the old one.
4. A `permit` signature created for one chain is valid on the other, because both contracts verify against the same `DOMAIN_SEPARATOR`.

**Attack**: User signs a permit on chain A. Attacker observes the signature (from a pending/confirmed tx) and replays it on chain B before the user's nonce advances on chain B.

### Mitigating Factors

- The **nonce** prevents same-chain replay. Once a permit is used on one chain, the nonce increments and the same signature can't be reused on that chain.
- Cross-chain replay requires: (a) chain fork, (b) pair at same address on both chains, (c) attacker replays before user uses that nonce on the other chain.
- The attacker can only set an **approval** (not transfer tokens directly), so they still need a separate step to exploit it.
- Hard forks are rare events.

### Verdict

Known limitation inherited from Uniswap V2. EIP-2612 best practice is to recompute `DOMAIN_SEPARATOR` per call when `block.chainid != cachedChainId`, but the gas cost trade-off was accepted by the original UniV2 design.

### Recommended Fix

Compute `DOMAIN_SEPARATOR` dynamically when the chain ID has changed:

```solidity
bytes32 public immutable CACHED_DOMAIN_SEPARATOR;
uint256 public immutable CACHED_CHAIN_ID;

constructor() {
    CACHED_CHAIN_ID = block.chainid;
    CACHED_DOMAIN_SEPARATOR = _computeDomainSeparator();
}

function DOMAIN_SEPARATOR() public view returns (bytes32) {
    return block.chainid == CACHED_CHAIN_ID ? CACHED_DOMAIN_SEPARATOR : _computeDomainSeparator();
}

function _computeDomainSeparator() private view returns (bytes32) {
    return keccak256(abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes(name)),
        keccak256(bytes("1")),
        block.chainid,
        address(this)
    ));
}
```

This preserves gas efficiency on the primary chain while protecting against cross-chain replay on forks.

---

## F-21: ERC20 Transfer to address(0) Not Blocked

**Severity**: INFORMATIONAL
**Contract**: `FraxswapERC20.sol:63-67`
**Category**: ERC20 Compliance

### Description

The `_transfer` function does not prevent transfers to `address(0)`:

```solidity
function _transfer(address from, address to, uint256 value) private {
    balanceOf[from] = balanceOf[from] - value;
    balanceOf[to] = balanceOf[to] + value;       // to can be address(0)
    emit Transfer(from, to, value);
}
```

If a user calls `transfer(address(0), amount)` or a spender calls `transferFrom(user, address(0), amount)`:

1. The user's balance decreases by `amount`
2. `balanceOf[address(0)]` increases by `amount`
3. `totalSupply` is **not** updated (unlike `_burn` which decrements it)

This creates a discrepancy: `sum(balanceOf) == totalSupply` still holds (the tokens are in address(0)'s balance, not destroyed), but the tokens are effectively unrecoverable. The `burn()` function in `FraxswapPair` burns from `address(this)`, never from `address(0)`.

### Impact

- Users who accidentally transfer to `address(0)` lose their LP tokens permanently.
- `totalSupply` remains correct (tokens still "exist" at address(0)), so LP share calculations in `mint`/`burn` are unaffected.
- The `MINIMUM_LIQUIDITY` tokens are intentionally minted to `address(0)` via `_mint` — this is by design and works correctly.

### Verdict

Standard Uniswap V2 behavior. The ERC-20 standard does not mandate blocking transfers to `address(0)` (OpenZeppelin's implementation does, but it's not required). This is a user-error protection issue, not a security vulnerability.

---

## F-22: TransferHelper / Math / UQ112x112 Libraries

**Severity**: INFORMATIONAL (no vulnerabilities found)
**Contracts**: `TransferHelper.sol`, `Math.sol`, `UQ112x112.sol`
**Category**: Library Verification

### TransferHelper.sol

Standard helper library (identical to Uniswap's). Handles tokens that don't return a boolean on `transfer`/`approve` (e.g., USDT, BNB):

```solidity
(bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
require(success && (data.length == 0 || abi.decode(data, (bool))));
```

- `data.length == 0`: Accepts tokens that return nothing (USDT-style)
- `abi.decode(data, (bool))`: Accepts tokens that return `true`
- Reverts if call fails or returns `false`

**Known limitation**: `safeApprove` does not handle the USDT pattern where `approve(spender, newAmount)` reverts if the current allowance is non-zero and the new amount is also non-zero. Callers must manage approval resetting themselves. This is not a bug in the library — it's a well-known USDT compatibility issue.

### Math.sol

**`sqrt` (Babylonian/Newton-Raphson)**:

```solidity
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
```

- `y = 0` → `z = 0`. Correct.
- `y = 1, 2, 3` → `z = 1`. Correct (floor of sqrt).
- `y > 3` → Babylonian method converges to `floor(sqrt(y))`. The initial guess `y/2 + 1` is always >= `sqrt(y)` for `y > 3`, and each iteration monotonically decreases until convergence. No overflow in `y / x + x` because after the first iteration `x ≈ sqrt(y) ≈ 2^128` for max uint256, so `y/x + x ≈ 2^129` — well within bounds.

**`min`**: Trivial, correct.

### UQ112x112.sol

Fixed-point arithmetic for Q112.112 format:

- `encode(uint112 y)`: `uint224(y) * 2^112`. Max: `(2^112 - 1) * 2^112 = 2^224 - 2^112 < 2^224 - 1 = uint224.max`. Comment "never overflows" is correct.
- `uqdiv(uint224 x, uint112 y)`: `x / uint224(y)`. Division by zero if `y == 0`, but all callers guard with `_reserve != 0` checks.

### Verdict

All three libraries are standard Uniswap V2 implementations. No vulnerabilities found. Math operations are correct and bounded.

---

## Audit Summary

All planned phases are now complete:

| Phase | Scope | Findings |
|-------|-------|----------|
| P0 | Periphery access control + TWAMM math | F-01 through F-09 |
| P1 | Access control (pair, factory, pause) | F-10 through F-13 |
| P2 | Standard AMM edge cases | F-14 through F-19 |
| P3 | ERC20, factory, helper libraries | F-20 through F-22 |

### Severity Distribution

| Severity | Count | Findings |
|----------|-------|----------|
| HIGH | 2 | F-01 (plugin), F-02 (V3 callback) |
| MEDIUM | 1 | F-08 (gas DoS) |
| LOW | 7 | F-07, F-11, F-12, F-13, F-14, F-15, F-20 |
| INFORMATIONAL | 12 | F-03, F-04, F-05, F-06, F-09, F-10, F-16, F-17, F-18, F-19, F-21, F-22 |

### Critical Action Items

1. **F-01**: Add plugin whitelist for swapType 255; revoke approvals after use
2. **F-02**: Validate `msg.sender` in `uniswapV3SwapCallback` against expected pool address
3. **F-08**: Cap the virtual order execution loop to prevent gas exhaustion DoS
