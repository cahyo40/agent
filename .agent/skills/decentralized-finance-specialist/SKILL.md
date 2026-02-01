---
name: decentralized-finance-specialist
description: "Expert in Decentralized Finance (DeFi) including AMM logic, lending protocols, yield farming, and liquidity mining"
---

# DeFi Specialist

## Overview

Master the complex world of Decentralized Finance. Expertise in AMM (Automated Market Maker) mathematics (Uniswap v2/v3), flash loans, algorithmic stablecoins, yield farming strategies, and liquid staking.

## When to Use This Skill

- Use when building or auditing DEXs (Decentralized Exchanges)
- Use when designing lending or borrowing protocols (Aave, Compound)
- Use for creating complex yield strategies or portfolio aggregators
- Use when implementing flash loan logic for arbitrage or rebalancing

## How It Works

### Step 1: Constant Product Formula (AMM)

- **Uniswap v2**: `x * y = k`. Understanding slippage, price impact, and impermanent loss.
- **Uniswap v3 (Concentrated Liquidity)**: Providing liquidity in specific price ranges to increase capital efficiency.

### Step 2: Lending & Interest Rate Logic

```solidity
// Simplified Lending logic
function calculateInterest(uint principal, uint time, uint rate) public pure returns (uint) {
    return principal * rate * time / (1e18 * 365 days);
}
```

- **Collateral Factor**: Maximum amount a user can borrow against their collateral.
- **Liquidation**: Closing under-collateralized positions to protect the protocol.

### Step 3: Flash Loans & Arbitrage

- **Flash Loans**: Multi-million dollar loans that must be repaid within the same block.
- **Arbitrage**: Exploiting price differences between different pools or exchanges.

### Step 4: Staking & Governance

- **Liquid Staking (LSD)**: Staking tokens while receiving a liquid representative (e.g., stETH).
- **DAO Governance**: Implementing voting systems and treasury management.

## Best Practices

### ✅ Do This

- ✅ Use secure Oracles (Chainlink) to prevent price manipulation
- ✅ Implement rigorous time-weighted average price (TWAP) calculations
- ✅ Conduct extensive economic simulations using tools like Gauntlet
- ✅ Use battle-tested OpenZeppelin libraries for smart contracts
- ✅ Design for composability with other DeFi protocols

### ❌ Avoid This

- ❌ Don't rely on `balanceOf` for price calculation (susceptible to flash loan attacks)
- ❌ Don't ignore the risk of "Governance Attacks"
- ❌ Don't hardcode sensitive constant variables
- ❌ Don't skip audit for new economic models

## Related Skills

- `@expert-web3-blockchain` - Foundation
- `@web3-smart-contract-auditor` - Security focus
- `@trading-app-developer` - Financial UX
