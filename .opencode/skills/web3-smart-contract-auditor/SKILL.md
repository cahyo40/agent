---
name: web3-smart-contract-auditor
description: "Expert smart contract security auditing including vulnerability detection, gas optimization, and Solidity security patterns"
---

# Web3 Smart Contract Auditor

## Overview

Audit smart contracts for security vulnerabilities, gas inefficiencies, and best practice violations. Master common attack vectors and mitigation patterns.

## When to Use This Skill

- Use when auditing smart contracts
- Use when reviewing Solidity code
- Use when checking for vulnerabilities
- Use when optimizing gas usage

## How It Works

### Step 1: Common Vulnerabilities

```
VULNERABILITY CHECKLIST
├── REENTRANCY
│   ├── External calls before state updates
│   └── Fix: Checks-Effects-Interactions pattern
│
├── INTEGER OVERFLOW/UNDERFLOW
│   ├── Pre-0.8.0 Solidity issue
│   └── Fix: Use SafeMath or Solidity 0.8+
│
├── ACCESS CONTROL
│   ├── Missing onlyOwner modifiers
│   └── Fix: OpenZeppelin AccessControl
│
├── FRONT-RUNNING
│   ├── Transaction ordering attacks
│   └── Fix: Commit-reveal schemes
│
├── ORACLE MANIPULATION
│   ├── Price oracle attacks
│   └── Fix: TWAP, Chainlink oracles
│
└── FLASH LOAN ATTACKS
    ├── Instant liquidity exploitation
    └── Fix: Time-weighted checks
```

### Step 2: Security Patterns

```solidity
// Checks-Effects-Interactions Pattern
function withdraw(uint amount) external {
    // 1. CHECKS
    require(balances[msg.sender] >= amount, "Insufficient");
    
    // 2. EFFECTS (update state FIRST)
    balances[msg.sender] -= amount;
    
    // 3. INTERACTIONS (external calls LAST)
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}

// ReentrancyGuard
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyContract is ReentrancyGuard {
    function withdraw() external nonReentrant {
        // Safe from reentrancy
    }
}
```

### Step 3: Gas Optimization

```solidity
// Gas Optimization Techniques

// ❌ Bad: Multiple storage reads
function bad() external {
    for (uint i = 0; i < array.length; i++) {
        // array.length read each loop
    }
}

// ✅ Good: Cache storage in memory
function good() external {
    uint len = array.length;
    for (uint i = 0; i < len; i++) {
        // len is memory variable
    }
}

// ✅ Use unchecked for safe math
unchecked { i++; } // Saves gas when overflow impossible

// ✅ Pack struct variables
struct Packed {
    uint128 a;  // Same slot
    uint128 b;  // Same slot
}
```

### Step 4: Audit Checklist

```
AUDIT PROCESS
├── 1. Scope Definition
│   └── Which contracts? Which functions?
├── 2. Manual Review
│   ├── Line-by-line code analysis
│   └── Logic flow verification
├── 3. Automated Tools
│   ├── Slither, Mythril, Echidna
│   └── Gas profiling
├── 4. Testing
│   ├── Unit tests coverage
│   └── Fuzz testing
└── 5. Report
    ├── Severity ratings (Critical/High/Medium/Low)
    └── Remediation recommendations
```

## Best Practices

### ✅ Do This

- ✅ Use OpenZeppelin contracts
- ✅ Follow CEI pattern
- ✅ Use ReentrancyGuard
- ✅ Validate all inputs
- ✅ Emit events for state changes
- ✅ Use time-locks for admin functions

### ❌ Avoid This

- ❌ Don't use tx.origin for auth
- ❌ Don't hardcode addresses
- ❌ Don't ignore compiler warnings
- ❌ Don't skip external audit

## Related Skills

- `@senior-web3-developer` - Web3 development
- `@expert-web3-blockchain` - Blockchain expertise
