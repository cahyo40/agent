---
name: senior-web3-developer
description: "Expert Web3 and blockchain development including smart contracts (Solidity, Rust), DeFi protocols, NFTs, security audits, and frontend integration with wagmi/viem"
---

# Senior Web3 Developer

## Overview

This skill transforms you into a Staff-level Web3 Developer who architects and builds secure decentralized applications. You write production-grade smart contracts, design robust tokenomics, and integrate Web3 functionality into modern frontends.

## When to Use This Skill

- Use when developing smart contracts (Solidity, Vyper, Rust)
- Use when building DeFi protocols or NFT projects
- Use when integrating Web3 into frontend applications
- Use when auditing smart contracts for security
- Use when designing tokenomics or protocol architecture
- Use when debugging blockchain-specific issues
- Use when explaining blockchain concepts

## How It Works

### Step 1: Understand the Blockchain Stack

```text
Blockchain Development Stack
├── Layer 1 (Base Layer)
│   ├── Ethereum, Solana, Polygon, BSC, Arbitrum
│   └── Consensus, Cryptography, Networking
├── Layer 2 (Scaling)
│   ├── Rollups (Arbitrum, Optimism, Base)
│   └── Sidechains, State Channels
├── Smart Contracts
│   ├── Solidity, Vyper (EVM)
│   └── Rust, Anchor (Solana)
├── Middleware
│   ├── Oracles (Chainlink, Pyth)
│   ├── Indexers (The Graph, Goldsky)
│   └── Storage (IPFS, Arweave, Filecoin)
└── Frontend
    ├── wagmi + viem (React/Next.js)
    └── ethers.js, web3.js (legacy)
```

### Step 2: Secure Smart Contract Development

Always follow the **Checks-Effects-Interactions (CEI)** pattern:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SecureVault is ReentrancyGuard {
    mapping(address => uint256) public balances;

    error InsufficientBalance();
    error TransferFailed();

    event Withdrawal(address indexed user, uint256 amount);

    function withdraw() external nonReentrant {
        // CHECKS - Validate first
        uint256 amount = balances[msg.sender];
        if (amount == 0) revert InsufficientBalance();

        // EFFECTS - Update state BEFORE external call
        balances[msg.sender] = 0;

        // INTERACTIONS - External call last
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit Withdrawal(msg.sender, amount);
    }
}
```

### Step 3: ERC-20 Token with Best Practices

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyToken is ERC20, ERC20Permit, Ownable2Step, ReentrancyGuard {
    
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18;
    uint256 public mintPrice = 0.01 ether;
    
    // ✅ Custom errors (gas efficient)
    error InsufficientPayment(uint256 required, uint256 provided);
    error ExceedsMaxSupply(uint256 requested, uint256 available);
    error ZeroAmount();
    
    // ✅ Events for transparency
    event TokensMinted(address indexed to, uint256 amount);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);
    
    constructor() 
        ERC20("MyToken", "MTK") 
        ERC20Permit("MyToken")
        Ownable(msg.sender) 
    {
        _mint(msg.sender, 100_000 * 10**18);
    }
    
    function mint(uint256 amount) external payable nonReentrant {
        if (amount == 0) revert ZeroAmount();
        
        uint256 cost = (amount * mintPrice) / 10**18;
        
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
        
        // ✅ Interactions (refund excess)
        if (msg.value > cost) {
            (bool success, ) = msg.sender.call{value: msg.value - cost}("");
            require(success, "Refund failed");
        }
    }
    
    function setMintPrice(uint256 newPrice) external onlyOwner {
        emit PriceUpdated(mintPrice, newPrice);
        mintPrice = newPrice;
    }
    
    function withdrawFunds() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
}
```

### Step 4: NFT with Royalties (ERC-721)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721, ERC721URIStorage, ERC2981, Ownable2Step {
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIdCounter;
    
    uint256 public constant MAX_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.08 ether;
    
    string private _baseTokenURI;
    bool public mintPaused;
    
    error SoldOut();
    error MintPaused();
    error InsufficientPayment();
    
    constructor(string memory baseURI, address royaltyReceiver) 
        ERC721("MyNFT", "MNFT") 
        Ownable(msg.sender)
    {
        _baseTokenURI = baseURI;
        _setDefaultRoyalty(royaltyReceiver, 500); // 5% royalty
    }
    
    function mint() external payable {
        if (mintPaused) revert MintPaused();
        if (msg.value < MINT_PRICE) revert InsufficientPayment();
        if (_tokenIdCounter.current() >= MAX_SUPPLY) revert SoldOut();
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }
    
    function toggleMint() external onlyOwner {
        mintPaused = !mintPaused;
    }
    
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
    
    // Required overrides
    function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, ERC721URIStorage, ERC2981) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
```

### Step 5: Foundry Testing

```solidity
// test/MyToken.t.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    
    function setUp() public {
        token = new MyToken();
        vm.deal(alice, 10 ether);
    }
    
    function test_InitialSupply() public view {
        assertEq(token.totalSupply(), 100_000 * 10**18);
        assertEq(token.balanceOf(address(this)), 100_000 * 10**18);
    }
    
    function test_Mint() public {
        uint256 amount = 1000 * 10**18;
        uint256 cost = (amount * token.mintPrice()) / 10**18;
        
        vm.prank(alice);
        token.mint{value: cost}(amount);
        
        assertEq(token.balanceOf(alice), amount);
    }
    
    function test_RevertWhen_InsufficientPayment() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(
                MyToken.InsufficientPayment.selector,
                0.01 ether,
                0
            )
        );
        token.mint{value: 0}(1000 * 10**18);
    }
    
    // Fuzz testing
    function testFuzz_Mint(uint256 amount) public {
        vm.assume(amount > 0 && amount <= 100_000 * 10**18);
        uint256 cost = (amount * token.mintPrice()) / 10**18;
        vm.deal(alice, cost);
        
        vm.prank(alice);
        token.mint{value: cost}(amount);
        
        assertEq(token.balanceOf(alice), amount);
    }
    
    // Invariant: Total supply never exceeds max
    function invariant_TotalSupplyNeverExceedsMax() public view {
        assertLe(token.totalSupply(), token.MAX_SUPPLY());
    }
}
```

### Step 6: Frontend Integration (wagmi + viem)

```typescript
// hooks/useContract.ts
import { 
  useReadContract, 
  useWriteContract, 
  useWaitForTransactionReceipt 
} from 'wagmi';
import { parseEther, formatEther } from 'viem';
import { myTokenABI } from '@/abi/MyToken';

const CONTRACT_ADDRESS = '0x...' as const;

export function useTokenBalance(address: `0x${string}` | undefined) {
  return useReadContract({
    address: CONTRACT_ADDRESS,
    abi: myTokenABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: { enabled: !!address },
  });
}

export function useMintToken() {
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });
  
  const mint = async (amount: bigint, mintPrice: bigint) => {
    const value = (amount * mintPrice) / BigInt(10 ** 18);
    
    writeContract({
      address: CONTRACT_ADDRESS,
      abi: myTokenABI,
      functionName: 'mint',
      args: [amount],
      value,
    });
  };
  
  return { 
    mint, 
    isPending, 
    isConfirming, 
    isSuccess, 
    hash,
    error 
  };
}

// components/MintButton.tsx
import { useAccount, useConnect, useDisconnect } from 'wagmi';
import { useMintToken, useTokenBalance } from '@/hooks/useContract';

export function MintButton() {
  const { address, isConnected } = useAccount();
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const { data: balance } = useTokenBalance(address);
  const { mint, isPending, isConfirming, isSuccess } = useMintToken();
  
  if (!isConnected) {
    return (
      <button onClick={() => connect({ connector: connectors[0] })}>
        Connect Wallet
      </button>
    );
  }
  
  return (
    <div>
      <p>Balance: {balance ? formatEther(balance) : '0'} MTK</p>
      <button 
        onClick={() => mint(BigInt(1000 * 10 ** 18), parseEther('0.01'))}
        disabled={isPending || isConfirming}
      >
        {isPending ? 'Confirm in wallet...' : 
         isConfirming ? 'Confirming...' : 
         isSuccess ? 'Minted!' :
         'Mint 1000 MTK'}
      </button>
    </div>
  );
}
```

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

## Best Practices

### ✅ Do This

- ✅ Always use OpenZeppelin contracts as base
- ✅ Lock pragma version (e.g., `pragma solidity 0.8.24;`)
- ✅ Emit events for all state changes
- ✅ Use custom errors for gas efficiency
- ✅ Implement emergency pause mechanism
- ✅ Use Ownable2Step instead of Ownable
- ✅ Get security audit before mainnet
- ✅ Run fuzz and invariant tests with Foundry
- ✅ Verify contracts on block explorer

### ❌ Avoid This

- ❌ Don't deploy without thorough testing
- ❌ Don't use `tx.origin` for authorization
- ❌ Don't hardcode addresses (use constructor)
- ❌ Don't ignore external call return values
- ❌ Don't skip front-running risk analysis
- ❌ Don't use single owner key (use multisig)
- ❌ Don't ignore gas optimization

## Pre-Deployment Checklist

```markdown
### Smart Contract
- [ ] All functions have explicit visibility modifiers
- [ ] Reentrancy guard on functions handling ETH/tokens
- [ ] Proper access control (Ownable2Step, roles)
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
```

## Recommended Tools

| Category | Tool | Purpose |
|----------|------|---------|
| Development | Foundry | Testing, deployment, scripting |
| Development | Hardhat | Popular, large plugin ecosystem |
| Security | Slither | Static analysis |
| Security | Mythril | Symbolic execution |
| Security | Aderyn | Rust-based static analyzer |
| Frontend | wagmi + viem | React Web3 hooks |
| Indexing | The Graph | Blockchain data querying |
| Infrastructure | Alchemy/Infura | Node providers |

## Related Skills

- `@dapp-mobile-developer` - Flutter + Web3 mobile apps
- `@senior-backend-developer` - Off-chain backend components
- `@senior-nextjs-developer` - Web3 frontend development
