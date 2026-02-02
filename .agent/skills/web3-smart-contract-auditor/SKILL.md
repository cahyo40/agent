---
name: web3-smart-contract-auditor
description: "Expert smart contract security auditing including vulnerability detection, gas optimization, and Solidity security patterns"
---

# Web3 Smart Contract Auditor

## Overview

This skill transforms you into a **Smart Contract Security Auditor**. You will move beyond simple reentrancy checks to detecting DeFi logic flaws, Flash Loan attack vectors, Oracle manipulation, and mastering Gas Optimization using assembly (Yul).

## When to Use This Skill

- Use when auditing Solidity smart contracts (Pre-deployment)
- Use when optimizing Gas costs (Assembly/Yul)
- Use when validating DeFi protocols (AMMs, Lending)
- Use when writing formal verification specs
- Use when analyzing past hacks (Post-mortem)

---

## Part 1: Top Attack Vectors (Beyond Reentrancy)

### 1.1 Reentrancy (The Classic)

**Vulnerability:**
Calling an external contract *before* updating state.

```solidity
// VULNERABLE
function withdraw() public {
    uint bal = balances[msg.sender];
    (bool success, ) = msg.sender.call{value: bal}(""); // Flow verified here
    require(success);
    balances[msg.sender] = 0; // State updated AFTER
}
```

**Fix (Checks-Effects-Interactions):**

```solidity
// SECURE
function withdraw() public nonReentrant {
    uint bal = balances[msg.sender];
    require(bal > 0);
    balances[msg.sender] = 0; // Effect
    (bool success, ) = msg.sender.call{value: bal}(""); // Interaction
    require(success);
}
```

### 1.2 Flash Loan Attacks (Price Manipulation)

**Vulnerability:** relying on `spot price` from a single logical DEX pair (e.g., Uniswap Pool).

**Attack Vector:**

1. Attacker borrows huge amount of Token A via Flash Loan.
2. Attacker dumps Token A into the pool -> Price crashes.
3. Attacker interacts with *your* protocol which reads this crashed price.
4. Attacker repays Flash Loan + fee. Profit.

**Fix:** Use TWAP (Time-Weighted Average Price) or Chainlink Oracles. Do NOT use `spot` price for collateral valuation.

### 1.3 Signature Replay

**Vulnerability:** Recovering signer without checking `nonce` or `chainId`.

```solidity
// VULNERABLE
function permit(..., uint8 v, bytes32 r, bytes32 s) {
    address signer = ecrecover(hash, v, r, s);
    // ... authorize signer
}
```

**Fix:** Include `nonce` (incremented on use) and `block.chainid` in the signed hash struct (EIP-712).

---

## Part 2: Gas Optimization (Yul / Assembly)

Every opcode costs money.

### 2.1 Storage vs Memory vs Calldata

- **Storage**: Expensive (20k gas). Avoid writing if possible.
- **Memory**: Cheap, strictly temporary.
- **Calldata**: Cheapest. Read-only arguments.

**Optimization:** Use `calldata` for external function array arguments.

```solidity
// Bad
function process(uint[] memory data) external { ... }

// Good
function process(uint[] calldata data) external { ... }
```

### 2.2 Unchecked Arithmetic

Since Solidity 0.8.x, overflow checks are default (costs gas). If you are 100% sure it won't overflow (e.g., loop counter), use `unchecked`.

```solidity
for (uint i = 0; i < len; ) {
    // ... logic
    unchecked { ++i; } // Saves gas per iteration
}
```

---

## Part 3: Auditing Tools & Workflow

### 3.1 Static Analysis

- **Slither**: Gold standard. Finds reentrancy, uninitialized variables, etc.
  `slither .`
- **Aderyn**: Rust-based, fast AST traversing.

### 3.2 Fuzzing (Foundry)

Don't just write unit tests. Write **Invariants**.

```solidity
// Invariant: Total supply should never exceed sum of balances
function invariant_totalSupply() public {
    assertEq(token.totalSupply(), sumBalances);
}
```

Run with Foundry: `forge test --invariant`

---

## Part 4: Token Standards (ERC-20/721/1155)

### 4.1 ERC-777 Reentrancy

ERC-777 has `tokensReceived` hook. If you support it, you ARE vulnerable to reentrancy even on simple transfers. Be careful wrapping ETH.

### 4.2 Fee-on-Transfer Tokens

Some tokens (USDT, SafeMoon) take a fee on transfer.
**Vulnerability:** Assuming `amount` sent = `amount` received.

```solidity
// Bad
token.transferFrom(user, address(this), amount);
balances[user] += amount; // WRONG! Might be less.

// Good
uint before = token.balanceOf(address(this));
token.transferFrom(user, address(this), amount);
uint received = token.balanceOf(address(this)) - before;
balances[user] += received;
```

---

## Part 5: Best Practices Checklist

### ✅ Do This

- ✅ **Use OpenZeppelin**: Don't roll your own crypto/math libraries.
- ✅ **Implement Circuit Breakers**: `pause()` functionality to stop contract in emergency.
- ✅ **Check Return Values**: `transfer` might return false instead of reverting (USDT). Use `SafeERC20`.
- ✅ **Validate Inputs**: `require(address != address(0))` is cheap insurance.

### ❌ Avoid This

- ❌ **`tx.origin`**: Use `msg.sender` for authorization.
- ❌ **`block.timestamp` (for randomness)**: Miners can manipulate it slightly.
- ❌ **Private Variables for Secrets**: Nothing is private on-chain. Everyone can read `private` slots.

---

## Related Skills

- `@senior-web3-developer` - Building the protocols
- `@senior-rust-developer` - Solana Auditing (Anchor)
- `@devsecops-specialist` - Pipeline security (Slither in CI)
