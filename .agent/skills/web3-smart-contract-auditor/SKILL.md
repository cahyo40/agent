---
name: web3-smart-contract-auditor
description: "Expert smart contract security auditing including vulnerability detection, gas optimization, and Solidity security patterns"
---

# Web3 Smart Contract Auditor

## Overview

This skill transforms you into a **Smart Contract Security Auditor**. Master vulnerability detection, gas optimization, formal verification, and systematic audit methodologies used by professional auditors.

## When to Use This Skill

- Use when auditing Solidity smart contracts
- Use when optimizing gas costs
- Use when reviewing DeFi protocol security
- Use when performing pre-deployment checks
- Use when analyzing past exploits

## Templates Reference

| Template | Description |
| -------- | ----------- |
| [audit-checklist.md](templates/audit-checklist.md) | Comprehensive audit methodology |
| [static-analysis.md](templates/static-analysis.md) | Slither, Mythril, and tool setup |
| [fuzzing.md](templates/fuzzing.md) | Foundry fuzz and invariant testing |

## How It Works

### Step 1: Understand Attack Vectors

```text
VULNERABILITY CATEGORIES
├── Access Control
│   ├── Missing onlyOwner
│   ├── tx.origin authentication
│   └── Unprotected initialize()
├── Reentrancy
│   ├── Single-function
│   ├── Cross-function
│   └── Cross-contract (read-only)
├── Economic Attacks
│   ├── Flash loan price manipulation
│   ├── Sandwich attacks
│   └── Oracle manipulation
├── Logic Errors
│   ├── Integer overflow (pre-0.8)
│   ├── Rounding errors
│   └── Incorrect state transitions
└── Gas & DoS
    ├── Unbounded loops
    ├── Block gas limit
    └── Griefing attacks
```

### Step 2: Critical Vulnerabilities

**Reentrancy (CEI Violation)**

```solidity
// ❌ VULNERABLE
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] -= amount; // State update AFTER external call
}

// ✅ SECURE (Checks-Effects-Interactions)
function withdraw(uint256 amount) external nonReentrant {
    require(balances[msg.sender] >= amount, "Insufficient");
    balances[msg.sender] -= amount; // State update BEFORE external call
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

**Oracle Manipulation**

```solidity
// ❌ VULNERABLE - Uses spot price
function getPrice() public view returns (uint256) {
    (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
    return (reserve1 * 1e18) / reserve0; // Manipulable in same tx
}

// ✅ SECURE - Uses Chainlink TWAP
function getPrice() public view returns (uint256) {
    (, int256 answer, , uint256 updatedAt, ) = priceFeed.latestRoundData();
    require(block.timestamp - updatedAt < 1 hours, "Stale price");
    require(answer > 0, "Invalid price");
    return uint256(answer);
}
```

### Step 3: Audit Methodology

See [templates/audit-checklist.md](templates/audit-checklist.md) for complete methodology.

**Phase 1: Reconnaissance**

- Understand business logic
- Identify trust boundaries
- Map data flow

**Phase 2: Static Analysis**

- Run Slither, Mythril
- Review compiler warnings
- Check known vulnerabilities

**Phase 3: Manual Review**

- Line-by-line code review
- State machine analysis
- Edge case exploration

**Phase 4: Dynamic Testing**

- Foundry fuzz testing
- Invariant testing
- Mainnet fork testing

### Step 4: Gas Optimization

```solidity
// Use uint256 over smaller types (no packing benefit)
uint256 counter; // 20,000 gas for storage

// Batch operations
function batchTransfer(address[] calldata to, uint256[] calldata amounts) external {
    for (uint256 i; i < to.length; ) {
        _transfer(to[i], amounts[i]);
        unchecked { ++i; } // Save gas in Solidity 0.8+
    }
}

// Cache storage reads
function process() external {
    uint256 _counter = counter; // Cache storage
    // Use _counter multiple times
}
```

## Critical Audit Checklist

### Access Control

- [ ] Owner/admin functions have proper modifiers
- [ ] No tx.origin authentication
- [ ] Initializers are protected
- [ ] Upgradeable proxies use proper patterns

### Reentrancy

- [ ] CEI pattern followed
- [ ] ReentrancyGuard where needed
- [ ] Cross-contract reentrancy considered

### Math & Logic

- [ ] No division by zero
- [ ] Proper rounding (up vs down)
- [ ] Overflow checks (or Solidity 0.8+)
- [ ] Correct comparison operators

### External Calls

- [ ] Return values checked
- [ ] Timeouts on external data
- [ ] No unbounded loops with external calls

### DeFi Specific

- [ ] Flash loan protection
- [ ] TWAP or Chainlink oracles
- [ ] Slippage protection
- [ ] MEV awareness

## Best Practices

### ✅ Do This

- ✅ Use OpenZeppelin contracts
- ✅ Run Slither before manual review
- ✅ Test with Foundry fuzzing
- ✅ Fork mainnet for integration tests
- ✅ Document all findings with severity

### ❌ Avoid This

- ❌ Skip static analysis
- ❌ Ignore compiler warnings
- ❌ Trust external contract behavior
- ❌ Assume inputs are valid
- ❌ Deploy without invariant tests

## Related Skills

- `@senior-web3-developer` - Smart contract development
- `@decentralized-finance-specialist` - DeFi protocols
- `@senior-cybersecurity-engineer` - Security testing
