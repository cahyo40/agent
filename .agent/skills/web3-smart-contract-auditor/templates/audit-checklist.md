# Audit Checklist Template

Comprehensive smart contract audit methodology.

## Phase 1: Information Gathering

### 1.1 Project Understanding

```markdown
- [ ] Read project documentation
- [ ] Understand business requirements
- [ ] Identify user roles and permissions
- [ ] Map contract interactions
- [ ] Review previous audits (if any)
```

### 1.2 Scope Definition

```markdown
| Contract | Lines | Complexity | Priority |
|----------|-------|------------|----------|
| Token.sol | 200 | Low | Medium |
| Vault.sol | 450 | High | Critical |
| Oracle.sol | 150 | Medium | High |
```

### 1.3 Trust Boundaries

```text
TRUST MODEL
├── Trusted
│   ├── Owner/Admin (multisig)
│   ├── Chainlink Oracle
│   └── OpenZeppelin contracts
├── Semi-Trusted
│   ├── Whitelisted tokens
│   └── Approved operators
└── Untrusted
    ├── All user inputs
    ├── External contract calls
    └── Token transfer callbacks
```

---

## Phase 2: Automated Analysis

### 2.1 Compiler Checks

```bash
# Enable all warnings
forge build --extra-output-files ir,metadata

# Check for optimizer issues
solc --optimize --optimize-runs 200 contracts/*.sol
```

### 2.2 Static Analysis

```bash
# Slither - comprehensive analysis
slither . --exclude-dependencies --print human-summary

# Specific detectors
slither . --detect reentrancy-eth,arbitrary-send-eth,controlled-delegatecall

# Generate call graph
slither . --print call-graph
```

### 2.3 Security Tools Matrix

| Tool | Focus | When to Use |
|------|-------|-------------|
| **Slither** | Pattern detection | Always first |
| **Mythril** | Symbolic execution | Complex logic |
| **Echidna** | Property testing | Invariants |
| **Foundry Fuzz** | Input fuzzing | Edge cases |
| **Certora** | Formal verification | High-value contracts |

---

## Phase 3: Manual Review Checklist

### 3.1 Access Control

```markdown
Critical:
- [ ] onlyOwner on admin functions
- [ ] No tx.origin authentication
- [ ] Role-based access properly implemented
- [ ] Modifiers cannot be bypassed

Upgradeability:
- [ ] initialize() is protected
- [ ] Storage layout is correct
- [ ] Upgrade logic is safe
- [ ] No storage collisions
```

### 3.2 Reentrancy

```markdown
- [ ] CEI pattern followed everywhere
- [ ] ReentrancyGuard on state-changing externals
- [ ] No callback before state update
- [ ] Read-only reentrancy considered
- [ ] Cross-contract reentrancy mapped
```

### 3.3 Math & Logic

```markdown
- [ ] Solidity 0.8+ or SafeMath used
- [ ] Division by zero prevented
- [ ] Rounding direction correct (up/down)
- [ ] No precision loss in calculations
- [ ] Correct use of unchecked {} blocks
```

### 3.4 External Interactions

```markdown
- [ ] External call return values checked
- [ ] Reentrancy protection before external calls
- [ ] Low-level call handling is safe
- [ ] No unbounded external loops
- [ ] Token approvals use safeApprove pattern
```

### 3.5 DeFi Specific

```markdown
Price Oracles:
- [ ] Chainlink/TWAP used (not spot price)
- [ ] Staleness check implemented
- [ ] Price bounds validated
- [ ] Multi-oracle fallback for critical prices

Flash Loans:
- [ ] Cannot manipulate within single tx
- [ ] Snapshot before external calls
- [ ] Minimum lock duration where appropriate

MEV:
- [ ] Slippage protection
- [ ] Deadline parameter
- [ ] Private mempool integration if needed
```

---

## Phase 4: Testing

### 4.1 Unit Tests

```solidity
function test_CannotWithdrawMoreThanBalance() public {
    vm.prank(user);
    vm.expectRevert("Insufficient balance");
    vault.withdraw(type(uint256).max);
}
```

### 4.2 Fuzz Testing

```solidity
function testFuzz_DepositWithdraw(uint256 amount) public {
    amount = bound(amount, 1, type(uint128).max);
    
    vault.deposit{value: amount}();
    assertEq(vault.balanceOf(address(this)), amount);
    
    vault.withdraw(amount);
    assertEq(vault.balanceOf(address(this)), 0);
}
```

### 4.3 Invariant Testing

```solidity
function invariant_TotalSupplyEqualsSumOfBalances() public {
    uint256 sum;
    for (uint256 i; i < actors.length; ++i) {
        sum += token.balanceOf(actors[i]);
    }
    assertEq(token.totalSupply(), sum);
}
```

### 4.4 Fork Testing

```solidity
function setUp() public {
    vm.createSelectFork("mainnet", 18000000);
    // Test against real state
}
```

---

## Phase 5: Reporting

### 5.1 Severity Classification

| Severity | Definition | Example |
|----------|------------|---------|
| **Critical** | Direct loss of funds | Reentrancy drain |
| **High** | Significant loss possible | Oracle manipulation |
| **Medium** | Limited impact | DoS on non-critical function |
| **Low** | Minimal impact | Gas optimization |
| **Informational** | Suggestions | Code quality |

### 5.2 Finding Template

```markdown
### [SEVERITY] Finding Title

**Location:** Contract.sol#L123

**Description:**
Brief description of the vulnerability.

**Impact:**
What can an attacker do with this?

**Proof of Concept:**
```solidity
// Attack code
```

**Recommendation:**
How to fix the issue.

```

---

## Quick Reference Commands

```bash
# Full audit pipeline
slither . --print human-summary
forge test -vvv
forge test --fuzz-runs 10000
echidna . --contract InvariantTest

# Generate report
slither . --print contract-summary > report.md
```
