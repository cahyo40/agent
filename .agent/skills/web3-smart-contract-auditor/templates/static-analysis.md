# Static Analysis Template

Setup and usage of Slither, Mythril, and other static analysis tools.

## Slither Setup

### Installation

```bash
# Using pip
pip install slither-analyzer

# Using Docker
docker pull trailofbits/slither
```

### Basic Usage

```bash
# Run all detectors
slither .

# Exclude dependencies
slither . --exclude-dependencies

# Specific detectors only
slither . --detect reentrancy-eth,reentrancy-no-eth,arbitrary-send-eth

# Generate reports
slither . --print human-summary
slither . --json output.json
```

### Detector Categories

```bash
# High impact
slither . --detect reentrancy-eth,arbitrary-send-eth,controlled-delegatecall,suicidal

# Medium impact
slither . --detect reentrancy-no-eth,uninitialized-state,locked-ether

# Low impact
slither . --detect naming-convention,solc-version,constable-states

# All informational
slither . --detect-info
```

### Custom Slither Config

```yaml
# slither.config.json
{
  "filter_paths": ["node_modules", "lib"],
  "exclude_dependencies": true,
  "exclude_informational": false,
  "exclude_low": false,
  "detectors_to_exclude": ["naming-convention"],
  "solc_remaps": [
    "@openzeppelin/=node_modules/@openzeppelin/"
  ]
}
```

### Printers (Analysis Output)

```bash
# Contract summary
slither . --print contract-summary

# Function summary
slither . --print function-summary

# Call graph (creates .dot file)
slither . --print call-graph

# Inheritance graph
slither . --print inheritance-graph

# Variable order (for storage layout)
slither . --print variable-order

# Data dependency
slither . --print data-dependency
```

---

## Mythril Setup

### Installation

```bash
# Using pip
pip install mythril

# Using Docker
docker pull mythril/myth
```

### Basic Usage

```bash
# Analyze single file
myth analyze contracts/Vault.sol

# With Foundry/Hardhat project
myth analyze --solc-json --execution-timeout 300 contracts/Vault.sol

# Specific address
myth analyze --address 0x... --rpc https://eth-mainnet.g.alchemy.com/v2/KEY

# JSON output
myth analyze contracts/Vault.sol -o json > report.json
```

### Configuration

```bash
# Increase analysis depth
myth analyze --execution-timeout 600 --max-depth 100 contracts/

# Specific vulnerabilities
myth analyze --modules integer,suicide,timestamp contracts/

# With dependencies
myth analyze --solc-remaps @openzeppelin=node_modules/@openzeppelin contracts/
```

---

## Foundry Integration

### Built-in Checks

```bash
# Run forge with verbosity for warnings
forge build --extra-output-files ir,metadata 2>&1 | grep -i warning

# Static analysis with forge
forge inspect Vault storage-layout
forge inspect Vault abi
```

### Custom Invariant Tests

```solidity
// test/invariants/Invariants.t.sol
contract InvariantTest is Test {
    Handler handler;
    Vault vault;

    function setUp() public {
        vault = new Vault();
        handler = new Handler(vault);
        
        // Configure invariant testing
        targetContract(address(handler));
    }

    function invariant_BalanceMatchesSupply() public {
        assertEq(
            address(vault).balance,
            vault.totalDeposits()
        );
    }
}
```

---

## Aderyn (Rust-based Analyzer)

### Installation

```bash
# Install
cargo install aderyn

# Or via GitHub releases
```

### Usage

```bash
# Analyze project
aderyn .

# Markdown report
aderyn . --output report.md

# JSON output
aderyn . --json report.json
```

---

## Automated Pipeline

### GitHub Actions

```yaml
name: Security

on: [push, pull_request]

jobs:
  slither:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1
        
      - name: Install Slither
        run: pip install slither-analyzer
        
      - name: Run Slither
        run: slither . --exclude-dependencies --fail-on high

  mythril:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        
      - name: Mythril analysis
        uses: docker://mythril/myth
        with:
          args: analyze --solc-json contracts/
```

---

## Common False Positives

| Detector | False Positive Case | Solution |
|----------|---------------------|----------|
| `reentrancy-eth` | Safe callback pattern | Add to `slither.config.json` ignore |
| `arbitrary-send-eth` | Owner-only withdraw | Check access control manually |
| `locked-ether` | Payable constructor | Verify intentional design |
| `uninitialized-state` | Set in initialize() | Check upgrade pattern |

### Ignoring False Positives

```solidity
// slither-disable-next-line reentrancy-eth
(bool success, ) = msg.sender.call{value: amount}("");
```
