---
name: web3-defi-developer
description: "Expert DeFi development including AMM, lending protocols, yield farming, and liquidity mining smart contracts"
---

# Web3 DeFi Developer

## Overview

Build DeFi protocols including AMMs, lending platforms, yield aggregators, and liquidity mining systems on blockchain networks.

## When to Use This Skill

- Use when building DeFi protocols
- Use when implementing AMM logic
- Use when creating lending protocols
- Use when designing tokenomics

## How It Works

### Step 1: DeFi Building Blocks

```
DEFI PRIMITIVES
├── DEX (Decentralized Exchange)
│   ├── AMM: Uniswap, Curve
│   └── Order Book: dYdX, Serum
│
├── LENDING
│   ├── Over-collateralized: Aave, Compound
│   └── Flash Loans
│
├── STABLECOINS
│   ├── Algorithmic: DAI
│   └── Collateralized: USDC
│
├── DERIVATIVES
│   ├── Perpetuals
│   └── Options
│
└── YIELD AGGREGATORS
    ├── Auto-compounding
    └── Strategy vaults
```

### Step 2: AMM Implementation

```solidity
// Constant Product AMM (x * y = k)
contract SimpleAMM {
    IERC20 public tokenA;
    IERC20 public tokenB;
    
    uint public reserveA;
    uint public reserveB;
    
    // Swap tokenA for tokenB
    function swap(uint amountIn, uint minAmountOut) external {
        // Calculate output: dy = (y * dx) / (x + dx)
        uint amountOut = (reserveB * amountIn) / (reserveA + amountIn);
        require(amountOut >= minAmountOut, "Slippage");
        
        // Update reserves
        reserveA += amountIn;
        reserveB -= amountOut;
        
        // Transfer tokens
        tokenA.transferFrom(msg.sender, address(this), amountIn);
        tokenB.transfer(msg.sender, amountOut);
    }
    
    // Add liquidity
    function addLiquidity(uint amountA, uint amountB) external {
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);
        reserveA += amountA;
        reserveB += amountB;
        // Mint LP tokens...
    }
}
```

### Step 3: Yield Farming

```solidity
// Staking Rewards Contract
contract StakingRewards {
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    
    uint public rewardRate; // Tokens per second
    mapping(address => uint) public balances;
    mapping(address => uint) public rewards;
    
    function stake(uint amount) external {
        balances[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }
    
    function claim() external {
        uint reward = calculateReward(msg.sender);
        rewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
    }
}
```

### Step 4: Flash Loans

```solidity
// Flash Loan Provider
interface IFlashLoanReceiver {
    function executeOperation(
        address asset,
        uint amount,
        uint fee,
        bytes calldata params
    ) external returns (bool);
}

function flashLoan(uint amount, bytes calldata params) external {
    uint balanceBefore = token.balanceOf(address(this));
    
    // Transfer to borrower
    token.transfer(msg.sender, amount);
    
    // Execute borrower's logic
    IFlashLoanReceiver(msg.sender).executeOperation(
        address(token), amount, fee, params
    );
    
    // Ensure repayment + fee
    require(
        token.balanceOf(address(this)) >= balanceBefore + fee,
        "Not repaid"
    );
}
```

## Best Practices

### ✅ Do This

- ✅ Use price oracles (Chainlink)
- ✅ Implement slippage protection
- ✅ Add time-locks for governance
- ✅ Use battle-tested libraries
- ✅ Get multiple audits

### ❌ Avoid This

- ❌ Don't rely on spot prices
- ❌ Don't skip economic modeling
- ❌ Don't ignore flash loan vectors
- ❌ Don't launch without audits

## Related Skills

- `@web3-smart-contract-auditor` - Security audits
- `@senior-web3-developer` - Web3 development
