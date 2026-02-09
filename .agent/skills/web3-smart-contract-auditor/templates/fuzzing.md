# Fuzzing Template

Foundry fuzz testing and invariant testing patterns.

## Fuzz Testing Basics

### Setup

```toml
# foundry.toml
[profile.default]
fuzz = { runs = 10000, max_test_rejects = 100000 }
invariant = { runs = 256, depth = 128 }

[profile.ci]
fuzz = { runs = 1000 }
invariant = { runs = 50, depth = 50 }

[profile.deep]
fuzz = { runs = 100000 }
invariant = { runs = 1000, depth = 256 }
```

### Basic Fuzz Test

```solidity
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultFuzzTest is Test {
    Vault vault;
    
    function setUp() public {
        vault = new Vault();
    }

    // Fuzz deposit and withdraw
    function testFuzz_DepositWithdraw(uint256 amount) public {
        // Bound inputs to reasonable range
        amount = bound(amount, 1 wei, 100 ether);
        
        // Give this contract enough ETH
        vm.deal(address(this), amount);
        
        // Deposit
        vault.deposit{value: amount}();
        assertEq(vault.balanceOf(address(this)), amount);
        
        // Withdraw
        uint256 balanceBefore = address(this).balance;
        vault.withdraw(amount);
        assertEq(address(this).balance, balanceBefore + amount);
        assertEq(vault.balanceOf(address(this)), 0);
    }

    // Fuzz with multiple actors
    function testFuzz_MultipleDepositors(
        address user1,
        address user2,
        uint256 amount1,
        uint256 amount2
    ) public {
        // Assumptions
        vm.assume(user1 != address(0) && user2 != address(0));
        vm.assume(user1 != user2);
        
        amount1 = bound(amount1, 1, 50 ether);
        amount2 = bound(amount2, 1, 50 ether);
        
        // User 1 deposits
        vm.deal(user1, amount1);
        vm.prank(user1);
        vault.deposit{value: amount1}();
        
        // User 2 deposits
        vm.deal(user2, amount2);
        vm.prank(user2);
        vault.deposit{value: amount2}();
        
        // Verify totals
        assertEq(vault.totalDeposits(), amount1 + amount2);
        assertEq(vault.balanceOf(user1), amount1);
        assertEq(vault.balanceOf(user2), amount2);
    }

    receive() external payable {}
}
```

---

## Invariant Testing

### Handler Pattern

```solidity
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Token.sol";

// Handler wraps target contract with bounded actions
contract TokenHandler is Test {
    Token token;
    address[] public actors;
    address currentActor;
    
    mapping(bytes32 => uint256) public calls;
    
    modifier countCall(bytes32 key) {
        calls[key]++;
        _;
    }
    
    constructor(Token _token) {
        token = _token;
        
        // Create pool of actors
        for (uint256 i; i < 10; i++) {
            actors.push(makeAddr(string(abi.encode("actor", i))));
        }
    }
    
    function transfer(uint256 actorSeed, uint256 toSeed, uint256 amount) 
        external 
        countCall("transfer") 
    {
        currentActor = actors[actorSeed % actors.length];
        address to = actors[toSeed % actors.length];
        
        amount = bound(amount, 0, token.balanceOf(currentActor));
        
        vm.prank(currentActor);
        token.transfer(to, amount);
    }
    
    function mint(uint256 actorSeed, uint256 amount) 
        external 
        countCall("mint") 
    {
        address to = actors[actorSeed % actors.length];
        amount = bound(amount, 1, 1000 ether);
        
        token.mint(to, amount);
    }
    
    function burn(uint256 actorSeed, uint256 amount) 
        external 
        countCall("burn") 
    {
        currentActor = actors[actorSeed % actors.length];
        amount = bound(amount, 0, token.balanceOf(currentActor));
        
        vm.prank(currentActor);
        token.burn(amount);
    }
    
    function forEachActor(function(address) external fn) public {
        for (uint256 i; i < actors.length; i++) {
            fn(actors[i]);
        }
    }
}
```

### Invariant Test Contract

```solidity
contract TokenInvariantTest is Test {
    Token token;
    TokenHandler handler;
    
    function setUp() public {
        token = new Token("Test", "TST");
        handler = new TokenHandler(token);
        
        // Seed initial balances
        for (uint256 i; i < 10; i++) {
            token.mint(handler.actors(i), 100 ether);
        }
        
        // Only call handler functions
        targetContract(address(handler));
    }
    
    // Total supply equals sum of all balances
    function invariant_SupplyEqualsBalances() public {
        uint256 totalBalance;
        
        for (uint256 i; i < 10; i++) {
            totalBalance += token.balanceOf(handler.actors(i));
        }
        
        assertEq(token.totalSupply(), totalBalance);
    }
    
    // No negative balances (implicit in uint256, but verify)
    function invariant_NoNegativeBalances() public {
        for (uint256 i; i < 10; i++) {
            assertTrue(token.balanceOf(handler.actors(i)) >= 0);
        }
    }
    
    // Log call distribution
    function invariant_CallSummary() public view {
        console.log("Transfer calls:", handler.calls("transfer"));
        console.log("Mint calls:", handler.calls("mint"));
        console.log("Burn calls:", handler.calls("burn"));
    }
}
```

---

## DeFi Invariants

### AMM Invariants

```solidity
contract AMMInvariantTest is Test {
    AMM amm;
    
    function invariant_ConstantProduct() public {
        (uint256 reserveA, uint256 reserveB, ) = amm.getReserves();
        uint256 k = reserveA * reserveB;
        
        // K should only increase (from fees) or stay same
        assertTrue(k >= lastK, "K decreased!");
        lastK = k;
    }
    
    function invariant_LPTokenBackedByReserves() public {
        uint256 totalSupply = amm.totalSupply();
        (uint256 reserveA, uint256 reserveB, ) = amm.getReserves();
        
        if (totalSupply > 0) {
            assertTrue(reserveA > 0 && reserveB > 0, "LP unbacked");
        }
    }
}
```

### Vault Invariants

```solidity
contract VaultInvariantTest is Test {
    function invariant_SolvencyCheck() public {
        uint256 totalAssets = vault.totalAssets();
        uint256 totalShares = vault.totalSupply();
        
        // Vault should never be underwater
        if (totalShares > 0) {
            assertTrue(
                vault.convertToAssets(totalShares) <= totalAssets + 1, // +1 for rounding
                "Vault underwater"
            );
        }
    }
    
    function invariant_BalanceMatchesVault() public {
        assertEq(
            address(vault).balance,
            vault.totalAssets()
        );
    }
}
```

---

## Running Fuzz Tests

```bash
# Default runs
forge test --match-contract Fuzz

# Deep fuzzing
forge test --match-contract Fuzz -vvv --fuzz-runs 100000

# Invariant testing
forge test --match-contract Invariant

# With gas reports
forge test --match-contract Fuzz --gas-report

# Continue failed fuzzing
FOUNDRY_FUZZ_SEED=12345 forge test --match-contract Fuzz
```

---

## Debugging Failed Fuzzes

```solidity
// Foundry will show the failing input
// Minimize with:
function testFuzz_Reproduce(uint256 amount) public {
    // Copy failing input from test output
    amount = 12345678901234567890;
    
    // Debug step by step
    console.log("Amount:", amount);
    // ...
}
```
