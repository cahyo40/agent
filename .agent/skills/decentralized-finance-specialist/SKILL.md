---
name: decentralized-finance-specialist
description: "Expert in Decentralized Finance (DeFi) including AMM logic, lending protocols, yield farming, and liquidity mining"
---

# Decentralized Finance Specialist

## Overview

This skill transforms you into a **DeFi Protocol Developer**. You will master **Automated Market Makers (AMMs)**, **Lending Protocols**, **Yield Farming Strategies**, and **Smart Contract Security** for building and interacting with DeFi systems.

## When to Use This Skill

- Use when building or auditing DEX protocols (Uniswap, Curve)
- Use when implementing lending/borrowing (Aave, Compound)
- Use when analyzing yield farming strategies
- Use when understanding tokenomics and incentives
- Use when detecting DeFi exploits (flash loans, reentrancy)

---

## Part 1: Automated Market Makers (AMMs)

### 1.1 Constant Product Formula

The foundation of Uniswap V2:
`x * y = k`

- `x`: Reserve of Token A.
- `y`: Reserve of Token B.
- `k`: Constant. Never changes (except when adding/removing liquidity).

**Price Impact**: Large trades move `k` significantly, causing slippage.

### 1.2 Uniswap V3 (Concentrated Liquidity)

LPs provide liquidity in specific price ranges.

- Higher capital efficiency.
- More complex position management.

### 1.3 Curve (StableSwap)

Optimized for assets of similar value (USDC/USDT).

- Lower slippage for stablecoin swaps.
- Uses StableSwap invariant (mix of constant sum and constant product).

---

## Part 2: Lending Protocols

### 2.1 Architecture (Aave/Compound Model)

1. **Deposit**: User deposits collateral, receives aTokens/cTokens.
2. **Borrow**: User borrows against collateral. Interest accrues.
3. **Health Factor**: `Collateral Value / Borrowed Value`. If < 1, liquidation.
4. **Liquidation**: Anyone can repay debt and claim collateral at discount.

### 2.2 Key Parameters

| Parameter | Meaning |
|-----------|---------|
| **LTV** | Loan-to-Value ratio (max borrow %) |
| **Liquidation Threshold** | When liquidation can occur |
| **Liquidation Bonus** | Discount for liquidators |
| **Utilization Rate** | % of deposited funds borrowed |

### 2.3 Interest Rate Models

```
Interest Rate = Base Rate + (Utilization * Slope)
```

When utilization is high, interest rates spike to incentivize deposits.

---

## Part 3: Yield Farming & Liquidity Mining

### 3.1 How It Works

1. User provides liquidity (LP tokens).
2. Protocol rewards LPs with governance tokens.
3. User farms by staking LP tokens in Masterchef-style contracts.

### 3.2 Risks

| Risk | Description |
|------|-------------|
| **Impermanent Loss** | LP value diverges from HODL value |
| **Rug Pull** | Devs drain liquidity |
| **Smart Contract Risk** | Bugs, exploits |
| **Token Inflation** | Rewards dilute token value |

### 3.3 APY vs APR

- **APR**: Simple interest. 100% APR = 100% return in 1 year.
- **APY**: Compound interest. Higher with frequent compounding.

---

## Part 4: Flash Loans

### 4.1 What Are Flash Loans?

Borrow any amount, repay in same transaction. No collateral needed.

- If not repaid, entire transaction reverts.

### 4.2 Use Cases

- **Arbitrage**: Buy cheap on DEX A, sell high on DEX B.
- **Collateral Swaps**: Refinance position without unwinding.
- **Liquidations**: Borrow funds to liquidate underwater positions.

### 4.3 Flash Loan Attacks

Manipulate price oracles within a single transaction to exploit protocols.
**Defense**: Use TWAPs (Time-Weighted Average Prices), Chainlink Oracles.

---

## Part 5: Security Considerations

### 5.1 Common Vulnerabilities

| Vulnerability | Description |
|---------------|-------------|
| **Reentrancy** | Callback before state update |
| **Oracle Manipulation** | Spot price used as oracle |
| **Rounding Errors** | Integer division issues |
| **Access Control** | Missing `onlyOwner` |

### 5.2 Auditing Checklist

- ✅ Use CEI (Checks-Effects-Interactions) pattern.
- ✅ Use Chainlink for price feeds.
- ✅ Test with Foundry fuzzing.
- ✅ Get multi-sig on admin keys.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Simulate First**: Fork mainnet locally (Hardhat Forking, Foundry).
- ✅ **Use Established Libraries**: OpenZeppelin, Solmate.
- ✅ **Time-lock Upgrades**: Governance delay on critical changes.

### ❌ Avoid This

- ❌ **Using Spot Price as Oracle**: Flash loan manipulation.
- ❌ **Minting Unbounded Tokens**: Token inflation.
- ❌ **Skipping Audits**: DeFi is adversarial; assume attacks.

---

## Related Skills

- `@expert-web3-blockchain` - Smart contract fundamentals
- `@web3-smart-contract-auditor` - Security auditing
- `@senior-typescript-developer` - Frontend integration (wagmi)
