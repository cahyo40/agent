---
name: smart-contract-developer
description: "Smart contract developer specializing in Solidity, Vyper, security patterns, gas optimization, testing with Foundry/Hardhat, and EVM blockchain development"
---

# Smart Contract Developer

## Overview

This skill transforms you into a **Smart Contract Developer** who writes secure, gas-optimized smart contracts for Ethereum and EVM-compatible chains. You'll master Solidity, security patterns, testing frameworks (Foundry, Hardhat), deployment strategies, and contract verification.

## When to Use This Skill

- Use when developing smart contracts for Ethereum/EVM chains
- Use when implementing DeFi protocols, NFTs, or DAOs
- Use when auditing contract security
- Use when optimizing gas costs
- Use when setting up testing and deployment pipelines

---

## Part 1: Solidity Fundamentals

### 1.1 Contract Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import statements
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Interface definitions
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

// Library
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

// Contract with inheritance
contract MyToken is ERC20, Ownable {
    // State variables
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18;
    uint256 public totalMinted;
    
    // Events
    event TokensMinted(address indexed to, uint256 amount);
    
    // Constructor
    constructor() ERC20("My Token", "MTK") Ownable(msg.sender) {}
    
    // Functions
    function mint(uint256 amount) external onlyOwner {
        require(totalMinted + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(msg.sender, amount);
        totalMinted += amount;
        emit TokensMinted(msg.sender, amount);
    }
}
```

### 1.2 Data Types & Storage

```solidity
contract DataTypes {
    // Value types (stored inline)
    bool public flag = true;
    uint256 public number = 42;
    int256 public signed = -10;
    address public owner = msg.sender;
    bytes32 public hash = keccak256("data");
    
    // Reference types (stored in storage)
    string public text = "Hello";
    bytes public data = hex"1234";
    
    // Arrays
    uint256[] public numbers;           // Dynamic array
    uint256[10] public fixedArray;      // Fixed array
    uint256[][] public nestedArray;     // Nested array
    
    // Mappings (storage only)
    mapping(address => uint256) public balances;
    mapping(uint256 => mapping(address => bool)) public approvals;
    
    // Structs
    struct User {
        string name;
        uint256 balance;
        bool active;
    }
    
    mapping(address => User) public users;
    
    // Enums
    enum Status { Pending, Active, Completed, Cancelled }
    Status public currentStatus;
    
    // Storage layout optimization
    // Pack small variables together
    struct Optimized {
        bool active;      // 1 byte
        uint8 level;      // 1 byte
        uint16 points;    // 2 bytes
        // Total: 4 bytes in one slot
        uint256 balance;  // 32 bytes (separate slot)
    }
}
```

---

## Part 2: Security Patterns

### 2.1 Common Vulnerabilities & Fixes

```solidity
// ❌ VULNERABLE: Reentrancy
contract VulnerableVault {
    mapping(address => uint256) public balances;
    
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
        
        balances[msg.sender] -= amount;  // State update AFTER external call
    }
}

// ✅ SECURE: Checks-Effects-Interactions
contract SecureVault {
    mapping(address => uint256) public balances;
    
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);  // Check
        
        balances[msg.sender] -= amount;           // Effect (state update FIRST)
        
        (bool success, ) = msg.sender.call{value: amount}("");  // Interaction
        require(success);
    }
}

// ✅ SECURE: Reentrancy Guard
contract GuardedVault {
    mapping(address => uint256) public balances;
    bool private locked;
    
    modifier noReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }
    
    function withdraw(uint256 amount) external noReentrant {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }
}
```

```solidity
// ❌ VULNERABLE: Integer overflow (pre-0.8.0)
contract VulnerableOverflow {
    uint8 public value = 255;
    
    function increment() external {
        value += 1;  // Overflows to 0
    }
}

// ✅ SECURE: Solidity 0.8.0+ has built-in overflow checks
// Or use SafeMath for older versions
contract SecureOverflow {
    using SafeMath for uint256;
    
    uint256 public value;
    
    function add(uint256 amount) external {
        value = value.add(amount);  // Reverts on overflow
    }
}
```

```solidity
// ❌ VULNERABLE: Access control
contract VulnerableAccess {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    function withdraw() external {
        require(msg.sender == owner);  // Can be bypassed with tx.origin
        payable(msg.sender).transfer(address(this).balance);
    }
}

// ✅ SECURE: Proper access control
contract SecureAccess {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }
}
```

### 2.2 OpenZeppelin Security Contracts

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Checks.sol";

contract SecureContract is Ownable, AccessControl, ReentrancyGuard, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    constructor() Ownable(msg.sender) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }
    
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }
    
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
    
    function mint(address to, uint256 amount) 
        external 
        onlyRole(MINTER_ROLE) 
        nonReentrant 
        whenNotPaused 
    {
        // Minting logic
    }
}
```

---

## Part 3: Gas Optimization

### 3.1 Optimization Techniques

```solidity
// ✅ OPTIMIZED: Storage vs Memory vs Calldata
contract GasOptimization {
    // ❌ Expensive: Storage writes
    uint256 public temp;
    
    function expensive(uint256[] memory values) external {
        for (uint256 i = 0; i < values.length; i++) {
            temp = values[i];  // Storage write each iteration
        }
    }
    
    // ✅ Cheap: Memory
    function cheaper(uint256[] memory values) external {
        uint256 localTemp;  // Memory variable
        for (uint256 i = 0; i < values.length; i++) {
            localTemp = values[i];
        }
        temp = localTemp;  // Single storage write
    }
    
    // ✅ Cheapest: Calldata (read-only, no copy)
    function cheapest(uint256[] calldata values) external pure returns (uint256) {
        uint256 sum;
        for (uint256 i = 0; i < values.length; i++) {
            sum += values[i];  // Read directly from calldata
        }
        return sum;
    }
}

// ✅ OPTIMIZED: Packing variables
contract VariablePacking {
    // ❌ Wastes space: 3 storage slots
    bool public flag1;      // 1 byte (31 bytes wasted)
    uint256 public number;  // 32 bytes
    bool public flag2;      // 1 byte (31 bytes wasted)
    
    // ✅ Efficient: 1 storage slot
    struct Packed {
        bool flag1;         // 1 byte
        bool flag2;         // 1 byte
        uint8 level;        // 1 byte
        uint16 points;      // 2 bytes
        // Total: 5 bytes in one 32-byte slot
    }
    
    Packed public data;
    uint256 public number;  // Separate slot
}

// ✅ OPTIMIZED: Short-circuit evaluation
contract ShortCircuit {
    // ✅ Cheaper conditions first
    function check(uint256 value, uint256[] memory allowed) external pure returns (bool) {
        if (value == 0) return false;           // Cheap check first
        if (value > 1000) return false;         // Cheap check
        return _expensiveCheck(value, allowed); // Expensive check last
    }
    
    function _expensiveCheck(uint256 value, uint256[] memory allowed) 
        internal pure returns (bool) 
    {
        for (uint256 i = 0; i < allowed.length; i++) {
            if (allowed[i] == value) return true;
        }
        return false;
    }
}

// ✅ OPTIMIZED: Fixed-size arrays vs dynamic
contract ArrayOptimization {
    // ✅ Cheaper for known sizes
    function processFixed(uint[3] calldata values) external pure returns (uint256) {
        return values[0] + values[1] + values[2];
    }
    
    // ❌ More expensive (length check each access)
    function processDynamic(uint[] calldata values) external pure returns (uint256) {
        require(values.length == 3);
        return values[0] + values[1] + values[2];
    }
}
```

### 3.2 Loop Optimization

```solidity
contract LoopOptimization {
    // ✅ Cache array length
    function iterate(uint256[] memory arr) external pure returns (uint256) {
        uint256 sum;
        uint256 len = arr.length;  // Cache length
        for (uint256 i = 0; i < len; i++) {
            sum += arr[i];
        }
        return sum;
    }
    
    // ✅ Unroll small loops
    function sum3(uint256 a, uint256 b, uint256 c) external pure returns (uint256) {
        return a + b + c;  // Unrolled
    }
    
    // ✅ Break early when possible
    function find(uint256[] memory arr, uint256 target) external pure returns (bool) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == target) return true;  // Early return
        }
        return false;
    }
}
```

---

## Part 4: Testing with Foundry

### 4.1 Test Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public owner;
    address public user;
    
    function setUp() public {
        owner = address(this);
        user = address(0x1);
        token = new MyToken();
    }
    
    // Basic test
    function testMint() public {
        token.mint(user, 1000);
        
        assertEq(token.balanceOf(user), 1000);
        assertEq(token.totalSupply(), 1000);
    }
    
    // Test with parameters (fuzzing)
    function testMintFuzz(uint256 amount) public {
        vm.assume(amount > 0 && amount <= 1_000_000 * 10**18);
        
        token.mint(user, amount);
        
        assertEq(token.balanceOf(user), amount);
    }
    
    // Test expected revert
    function testMintExceedsMaxSupply() public {
        uint256 maxSupply = token.MAX_SUPPLY();
        
        vm.expectRevert("Exceeds max supply");
        token.mint(user, maxSupply + 1);
    }
    
    // Test with different caller
    function testNonOwnerCannotMint() public {
        vm.prank(user);  // Execute next call as user
        
        vm.expectRevert();  // Any revert
        token.mint(user, 1000);
    }
    
    // Test events
    function testMintEvent() public {
        vm.expectEmit(true, true, true, true);
        emit TokensMinted(user, 1000);
        
        token.mint(user, 1000);
    }
    
    // Snapshot for gas testing
    function testGasCost() public {
        uint256 snapshot = vm.snapshot();
        
        token.mint(user, 1000);
        
        uint256 gasUsed = vm.snapshotDiff(snapshot);
        assertLt(gasUsed, 100000);  // Assert gas usage limit
    }
}
```

### 4.2 Advanced Testing

```solidity
// Invariant testing
contract TokenInvariants is Test {
    MyToken public token;
    address[] public holders;
    
    function setUp() public {
        token = new MyToken();
    }
    
    // Invariant: Total supply equals sum of balances
    function invariant_totalSupply() public {
        uint256 totalSupply = token.totalSupply();
        uint256 sumOfBalances;
        
        for (uint256 i = 0; i < holders.length; i++) {
            sumOfBalances += token.balanceOf(holders[i]);
        }
        
        assertEq(totalSupply, sumOfBalances);
    }
}

// Integration test with mainnet fork
contract MainnetForkTest is Test {
    IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    
    function setUp() public {
        // Fork from mainnet at specific block
        vm.createSelectFork("mainnet", 18000000);
    }
    
    function testUSDCBalance() public {
        // Get balance of known USDC holder
        address holder = 0x47ac0Fb4F2D84898e4D9E7b4DaB3C24507a6D503;
        uint256 balance = USDC.balanceOf(holder);
        
        assertGt(balance, 0);
    }
}
```

### 4.3 Foundry Configuration

```toml
# foundry.toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.20"
optimizer = true
optimizer_runs = 200

# Fuzz testing
fuzz_runs = 256
fuzz_max_local_rejects = 1024

# Gas reporting
gas_reports = ["MyToken", "MyNFT"]

# RPC endpoints
[eth_rpc_urls]
mainnet = "https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}"
sepolia = "https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}"

[profile.ci]
fuzz_runs = 1000
verbosity = 4
```

---

## Part 5: Deployment

### 5.1 Deployment Script

```solidity
// script/Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyToken.sol";
import "../src/MyNFT.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy contracts
        MyToken token = new MyToken();
        console.log("MyToken deployed at:", address(token));
        
        MyNFT nft = new MyNFT();
        console.log("MyNFT deployed at:", address(nft));
        
        // Initialize
        token.mint(msg.sender, 1000 * 10**18);
        
        vm.stopBroadcast();
        
        // Output for verification
        console.log("Deployment complete!");
    }
}
```

### 5.2 Verification

```bash
# Deploy
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast

# Verify on Etherscan
forge verify-contract \
    --chain-id 11155111 \
    --num-of-optimizations 200 \
    --constructor-args $(cast abi-encode "constructor()" "") \
    0xContractAddress \
    src/MyToken.sol:MyToken
```

---

## Best Practices

### ✅ Do This

- ✅ Use OpenZeppelin contracts
- ✅ Implement comprehensive tests
- ✅ Use Checks-Effects-Interactions pattern
- ✅ Add reentrancy guards
- ✅ Optimize for gas efficiency
- ✅ Verify contracts on Etherscan
- ✅ Use events for important state changes

### ❌ Avoid This

- ❌ Using tx.origin for authorization
- ❌ Unchecked external calls
- ❌ Storing sensitive data on-chain
- ❌ Complex logic in constructors
- ❌ Not testing edge cases
- ❌ Ignoring gas optimization

---

## Related Skills

- `@nft-developer` - NFT development
- `@dao-developer` - DAO smart contracts
- `@web3-frontend-specialist` - Web3 integration
- `@senior-solidity-developer` - Advanced Solidity
- `@expert-web3-blockchain` - Blockchain architecture
