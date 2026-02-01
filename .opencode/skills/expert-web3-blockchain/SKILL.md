---
name: expert-web3-blockchain
description: "Expert blockchain development including smart contracts, DeFi protocols, NFTs, and Web3 integration with security-first approach"
---

# Expert Web3 & Blockchain Developer

## Overview

This skill transforms you into an Expert Web3 & Blockchain Developer who masters decentralized application development, smart contracts, and the blockchain ecosystem. You write code with the highest security standards and follow Web3 industry best practices.

## When to Use This Skill

- Use when developing smart contracts (Solidity, Rust)
- Use when building DeFi protocols or NFT projects
- Use when integrating Web3 into frontend applications
- Use when auditing smart contracts for security
- Use when designing tokenomics or protocol architecture
- Use when debugging blockchain-specific issues
- Use when explaining blockchain concepts

## How It Works

### Step 1: Understand the Blockchain Stack

```
Blockchain Development Stack
├── Layer 1 (Base Layer)
│   ├── Ethereum, Solana, Polygon, etc.
│   └── Consensus, Cryptography, Networking
├── Layer 2 (Scaling)
│   ├── Rollups (Arbitrum, Optimism)
│   └── Sidechains, State Channels
├── Smart Contracts
│   ├── Solidity, Vyper (EVM)
│   └── Rust, Anchor (Solana)
├── Middleware
│   ├── Oracles (Chainlink)
│   ├── Indexers (The Graph)
│   └── Storage (IPFS, Arweave)
└── Frontend
    ├── wagmi + viem (React)
    └── ethers.js, web3.js
```

### Step 2: Write Secure Smart Contracts

Always follow the Checks-Effects-Interactions pattern:

```solidity
// ✅ CORRECT: CEI Pattern
function withdraw() external {
    // CHECKS - Validate first
    uint256 amount = balances[msg.sender];
    require(amount > 0, "No balance");
    
    // EFFECTS - Update state BEFORE external call
    balances[msg.sender] = 0;
    
    // INTERACTIONS - External call last
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

### Step 3: Use OpenZeppelin Standards

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract MyToken is ERC20, Ownable, ReentrancyGuard, Pausable {
    // Always inherit from battle-tested contracts
}
```

### Step 4: Test Thoroughly with Foundry

```solidity
// test/MyToken.t.sol
contract MyTokenTest is Test {
    MyToken public token;
    
    function setUp() public {
        token = new MyToken();
    }
    
    function test_Mint() public {
        // Arrange
        uint256 amount = 1000 * 10**18;
        
        // Act
        token.mint(amount);
        
        // Assert
        assertEq(token.balanceOf(address(this)), amount);
    }
    
    // Fuzz testing
    function testFuzz_Mint(uint256 amount) public {
        amount = bound(amount, 1, 10_000 * 10**18);
        token.mint(amount);
        assertEq(token.balanceOf(address(this)), amount);
    }
}
```

## Examples

### Example 1: ERC-20 Token with Best Practices

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyToken is ERC20, Ownable, ReentrancyGuard {
    
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18;
    uint256 public mintPrice = 0.01 ether;
    
    // ✅ Custom errors (gas efficient)
    error InsufficientPayment(uint256 required, uint256 provided);
    error ExceedsMaxSupply(uint256 requested, uint256 available);
    
    // ✅ Events for transparency
    event TokensMinted(address indexed to, uint256 amount);
    
    constructor() ERC20("MyToken", "MTK") Ownable(msg.sender) {
        _mint(msg.sender, 100_000 * 10**18);
    }
    
    function mint(uint256 amount) 
        external 
        payable 
        nonReentrant  // ✅ Reentrancy protection
    {
        uint256 cost = amount * mintPrice / 10**18;
        
        // ✅ Checks
        if (msg.value < cost) {
            revert InsufficientPayment(cost, msg.value);
        }
        if (totalSupply() + amount > MAX_SUPPLY) {
            revert ExceedsMaxSupply(amount, MAX_SUPPLY - totalSupply());
        }
        
        // ✅ Effects
        _mint(msg.sender, amount);
        emit TokensMinted(msg.sender, amount);
        
        // ✅ Interactions (refund)
        if (msg.value > cost) {
            (bool success, ) = msg.sender.call{value: msg.value - cost}("");
            require(success, "Refund failed");
        }
    }
}
```

### Example 2: NFT with Royalties

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721, ERC2981 {
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIdCounter;
    
    uint256 public constant MAX_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.08 ether;
    
    string private _baseTokenURI;
    
    constructor(string memory baseURI, address royaltyReceiver) 
        ERC721("MyNFT", "MNFT") 
    {
        _baseTokenURI = baseURI;
        _setDefaultRoyalty(royaltyReceiver, 500); // 5% royalty
    }
    
    function mint() external payable {
        require(msg.value >= MINT_PRICE, "Insufficient payment");
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Sold out");
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }
    
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
    
    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, ERC2981) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
```

### Example 3: React + wagmi Frontend Integration

```typescript
// hooks/useContract.ts
import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';
import { MyContractABI } from '@/abi/MyContract';

const CONTRACT_ADDRESS = '0x...' as const;

export function useMint() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });
  
  const mint = async (amount: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESS,
      abi: MyContractABI,
      functionName: 'mint',
      args: [amount],
      value: parseEther('0.08') * amount,
    });
  };
  
  return { mint, isPending, isConfirming, isSuccess, hash };
}

// components/MintButton.tsx
import { useAccount, useConnect, useDisconnect } from 'wagmi';
import { useMint } from '@/hooks/useContract';

export function MintButton() {
  const { address, isConnected } = useAccount();
  const { connect, connectors } = useConnect();
  const { mint, isPending, isConfirming, isSuccess } = useMint();
  
  if (!isConnected) {
    return (
      <button onClick={() => connect({ connector: connectors[0] })}>
        Connect Wallet
      </button>
    );
  }
  
  return (
    <button 
      onClick={() => mint(1n)}
      disabled={isPending || isConfirming}
    >
      {isPending ? 'Confirm in wallet...' : 
       isConfirming ? 'Confirming...' : 
       'Mint NFT'}
    </button>
  );
}
```

## Best Practices

### ✅ Do This

- ✅ Always use OpenZeppelin contracts as base
- ✅ Lock pragma version (e.g., `pragma solidity 0.8.20;`)
- ✅ Emit events for all state changes
- ✅ Use custom errors for gas efficiency
- ✅ Implement emergency pause mechanism
- ✅ Use multisig for ownership
- ✅ Get security audit before mainnet
- ✅ Run fuzz and invariant tests
- ✅ Verify contracts on block explorer

### ❌ Avoid This

- ❌ Don't deploy without thorough testing
- ❌ Don't use `tx.origin` for authorization
- ❌ Don't hardcode addresses (use constructor)
- ❌ Don't ignore external call return values
- ❌ Don't skip front-running risk analysis
- ❌ Don't use single owner key (use multisig)
- ❌ Don't ignore gas optimization

## Common Pitfalls

**Problem:** Reentrancy attack draining contract funds
**Solution:** Use `ReentrancyGuard` from OpenZeppelin and follow CEI pattern (Checks-Effects-Interactions).

**Problem:** Front-running exploiting transaction order
**Solution:** Implement commit-reveal schemes or use private mempools (Flashbots).

**Problem:** Oracle manipulation causing incorrect prices
**Solution:** Use TWAP (Time-Weighted Average Price), multiple oracle sources, and price deviation checks.

**Problem:** Integer overflow/underflow
**Solution:** Use Solidity 0.8+ which has built-in overflow checks.

**Problem:** Users losing funds due to incorrect addresses
**Solution:** Implement address validation, use ENS resolution, and show confirmation dialogs.

## Security Vulnerability Table

| Vulnerability | Impact | Prevention |
|--------------|--------|------------|
| **Reentrancy** | Fund theft | ReentrancyGuard, CEI pattern |
| **Integer Overflow** | Logic bypass | Solidity 0.8+ (built-in) |
| **Front-running** | MEV extraction | Commit-reveal, private mempools |
| **Flash Loan Attack** | Price manipulation | Oracle guards, TWAP |
| **Access Control** | Unauthorized actions | OpenZeppelin AccessControl |
| **Unchecked Return** | Silent failures | Always check call returns |
| **Signature Replay** | Double spending | Nonces, EIP-712 |

## Pre-Deployment Checklist

### Smart Contract

- [ ] All functions have explicit visibility modifiers
- [ ] Reentrancy guard on functions handling ETH/tokens
- [ ] Proper access control (onlyOwner, roles)
- [ ] Events for all important state changes
- [ ] Custom errors used (gas optimization)
- [ ] Input validation on every public function

### Testing

- [ ] Unit test coverage > 90%
- [ ] Integration tests
- [ ] Fuzz testing with Foundry
- [ ] Invariant testing
- [ ] Fork testing with mainnet data

### Deployment

- [ ] Third-party security audit
- [ ] Bug bounty program
- [ ] Multisig for owner/admin
- [ ] Timelock for critical changes
- [ ] Emergency pause mechanism
- [ ] Contract verified on Etherscan

## Recommended Tools

| Category | Tool | Purpose |
|----------|------|---------|
| Development | Foundry | Testing, deployment, scripting |
| Development | Hardhat | Popular, large plugin ecosystem |
| Security | Slither | Static analysis |
| Security | Mythril | Security analysis |
| Frontend | wagmi + viem | React Web3 hooks |
| Indexing | The Graph | Blockchain data querying |
| Infrastructure | Alchemy/Infura | Node providers |

## Related Skills

- `@senior-backend-developer` - For off-chain backend components
- `@expert-senior-software-engineer` - For system architecture
- `@senior-programming-mentor` - For Solidity/Rust learning
