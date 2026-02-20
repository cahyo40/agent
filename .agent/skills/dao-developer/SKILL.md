---
name: dao-developer
description: "DAO developer specializing in governance contracts, voting mechanisms, treasury management, proposal systems, and decentralized organization architecture"
---

# DAO Developer

## Overview

This skill transforms you into a **DAO Developer** who builds decentralized autonomous organization infrastructure. You'll master governance contracts, voting mechanisms (token-weighted, quadratic, conviction), treasury management, proposal systems, and delegation patterns.

## When to Use This Skill

- Use when building DAO governance systems
- Use when implementing on-chain voting mechanisms
- Use when creating treasury management contracts
- Use when designing proposal and execution systems
- Use when implementing delegation and representation

---

## Part 1: DAO Architecture

### 1.1 Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                      DAO Architecture                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │   GOVERNANCE    │    │    TREASURY     │                 │
│  │     TOKEN       │───▶│     CONTRACT    │                 │
│  │  (ERC20/ERC721) │    │                 │                 │
│  └────────┬────────┘    └────────┬────────┘                 │
│           │                      │                          │
│           ▼                      ▼                          │
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │    VOTING       │    │   EXECUTION     │                 │
│  │   CONTRACT      │───▶│   CONTRACT      │                 │
│  │                 │    │                 │                 │
│  └────────┬────────┘    └─────────────────┘                 │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────┐                                        │
│  │    PROPOSAL     │                                        │
│  │    CONTRACT     │                                        │
│  │                 │                                        │
│  └─────────────────┘                                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Governance Token

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceToken is ERC20, ERC20Permit, ERC20Votes, ERC20Burnable, Ownable {
    uint256 public constant TOTAL_SUPPLY = 100_000_000 * 10**18;
    
    constructor() ERC20("Governance Token", "GOV") ERC20Permit("Governance Token") Ownable(msg.sender) {
        _mint(msg.sender, TOTAL_SUPPLY);
    }
    
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
    
    // Required overrides
    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }
    
    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
```

---

## Part 2: Voting Mechanisms

### 2.1 Token-Weighted Voting

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

contract DAOGovernor is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl {
    constructor(
        IVotes _token,
        TimelockController _timelock
    )
        Governor("DAO Governor")
        GovernorSettings(7200, 50400, 0)  // 1 day voting, 1 week delay, 0 threshold
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)    // 4% quorum
        GovernorTimelockControl(_timelock)
    {}
    
    // Required overrides
    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }
    
    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }
    
    function quorum(uint256 blockNumber) public view override(Governor, GovernorVotesQuorumFraction) returns (uint256) {
        return super.quorum(blockNumber);
    }
    
    function state(uint256 proposalId) public view override(Governor, GovernorTimelockControl) returns (ProposalState) {
        return super.state(proposalId);
    }
    
    function proposalNeedsQueuing(uint256 proposalId) public view override(Governor, GovernorTimelockControl) returns (bool) {
        return super.proposalNeedsQueuing(proposalId);
    }
    
    function _queueOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(Governor, GovernorTimelockControl) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }
    
    function _executeOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(Governor, GovernorTimelockControl) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }
    
    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }
    
    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }
}
```

### 2.2 Quadratic Voting

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract QuadraticVoting {
    struct Proposal {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        mapping(address => uint256) votes;  // Credits spent
        mapping(address => VoteChoice) choices;
        uint256 totalYes;
        uint256 totalNo;
    }
    
    enum VoteChoice { None, Yes, No }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public votingCredits;  // Per user
    uint256 public proposalCount;
    
    event ProposalCreated(uint256 indexed proposalId, string description);
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool support, uint256 votes);
    
    function createProposal(string memory description, uint256 votingPeriod) external returns (uint256) {
        proposalCount++;
        Proposal storage proposal = proposals[proposalCount];
        
        proposal.id = proposalCount;
        proposal.description = description;
        proposal.startTime = block.timestamp;
        proposal.endTime = block.timestamp + votingPeriod;
        
        emit ProposalCreated(proposalCount, description);
        return proposalCount;
    }
    
    /// @notice Calculate votes from credits (quadratic formula)
    /// @param credits Number of credits spent
    /// @return votes Number of votes (sqrt of credits)
    function _calculateVotes(uint256 credits) internal pure returns (uint256) {
        // votes = sqrt(credits)
        // credits = votes^2
        return sqrt(credits);
    }
    
    /// @notice Calculate credits needed for desired votes
    /// @param votes Desired number of votes
    /// @return credits Credits needed (votes squared)
    function _calculateCredits(uint256 votes) internal pure returns (uint256) {
        return votes * votes;
    }
    
    function vote(uint256 proposalId, bool support, uint256 credits) external {
        require(credits > 0, "Must spend credits");
        require(votingCredits[msg.sender] >= credits, "Insufficient credits");
        
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime, "Voting not started");
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(proposal.votes[msg.sender] == 0, "Already voted");
        
        // Deduct credits
        votingCredits[msg.sender] -= credits;
        proposal.votes[msg.sender] = credits;
        
        // Calculate votes (quadratic)
        uint256 votes = _calculateVotes(credits);
        
        // Record vote
        proposal.choices[msg.sender] = support ? VoteChoice.Yes : VoteChoice.No;
        
        if (support) {
            proposal.totalYes += votes;
        } else {
            proposal.totalNo += votes;
        }
        
        emit VoteCast(msg.sender, proposalId, support, votes);
    }
    
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(!proposal.executed, "Already executed");
        require(proposal.totalYes > proposal.totalNo, "Proposal rejected");
        
        proposal.executed = true;
        
        // Execute proposal logic here
        // ...
    }
    
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        if (x <= 3) return 1;
        
        y = x;
        uint256 z = (x / y + y) / 2;
        while (z < y) {
            y = z;
            z = (x / y + y) / 2;
        }
    }
}
```

### 2.3 Conviction Voting

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ConvictionVoting {
    struct Proposal {
        uint256 id;
        string description;
        uint256 requestedAmount;
        uint256 totalConviction;
        mapping(address => uint256) stakes;
        mapping(address => uint256) stakeTime;
        bool executed;
    }
    
    uint256 public constant CONViction_WEIGHT = 1e18;
    uint256 public constant HALF_LIFE = 7 days;
    
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;
    uint256 public treasuryBalance;
    
    /// @notice Calculate conviction based on stake amount and time
    /// @param stake Amount staked
    /// @param timeStaked Duration stake has been locked
    /// @return conviction Conviction score
    function calculateConviction(uint256 stake, uint256 timeStaked) public pure returns (uint256) {
        // Conviction = stake * (1 - e^(-ln(2) * timeStaked / HALF_LIFE))
        // Simplified: stake * timeStaked / (timeStaked + HALF_LIFE)
        if (timeStaked == 0) return 0;
        return (stake * timeStaked) / (timeStaked + HALF_LIFE);
    }
    
    function stake(uint256 proposalId, uint256 amount) external {
        require(amount > 0, "Must stake > 0");
        
        Proposal storage proposal = proposals[proposalId];
        
        // Update existing stake
        if (proposal.stakes[msg.sender] > 0) {
            // Remove old conviction
            uint256 oldTime = block.timestamp - proposal.stakeTime[msg.sender];
            uint256 oldConviction = calculateConviction(proposal.stakes[msg.sender], oldTime);
            proposal.totalConviction -= oldConviction;
        }
        
        // Add new stake
        proposal.stakes[msg.sender] += amount;
        proposal.stakeTime[msg.sender] = block.timestamp;
        
        // Add new conviction
        proposal.totalConviction += calculateConviction(amount, 0);
    }
    
    function withdraw(uint256 proposalId, uint256 amount) external {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.stakes[msg.sender] >= amount, "Insufficient stake");
        
        // Remove old conviction
        uint256 timeStaked = block.timestamp - proposal.stakeTime[msg.sender];
        uint256 oldConviction = calculateConviction(proposal.stakes[msg.sender], timeStaked);
        proposal.totalConviction -= oldConviction;
        
        // Update stake
        proposal.stakes[msg.sender] -= amount;
        proposal.stakeTime[msg.sender] = block.timestamp;
        
        // Add new conviction
        if (proposal.stakes[msg.sender] > 0) {
            proposal.totalConviction += calculateConviction(proposal.stakes[msg.sender], 0);
        }
        
        // Return tokens
        // _transfer(proposalId, msg.sender, amount);
    }
    
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(proposal.totalConviction > getThreshold(proposal.requestedAmount), "Insufficient conviction");
        
        proposal.executed = true;
        
        // Transfer requested amount
        // _transfer(treasury, proposal.beneficiary, proposal.requestedAmount);
    }
    
    function getThreshold(uint256 amount) public view returns (uint256) {
        // Threshold formula based on treasury size and request amount
        return (treasuryBalance * amount) / treasuryBalance;  // Simplified
    }
}
```

---

## Part 3: Treasury Management

### 3.1 Multi-Sig Treasury

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MultiSigTreasury {
    using ECDSA for bytes32;
    
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
        mapping(address => bool) confirmed;
    }
    
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;
    uint256 public transactionCount;
    
    mapping(uint256 => Transaction) public transactions;
    
    event Deposit(address indexed sender, uint256 amount);
    event SubmitTransaction(uint256 indexed txId, address indexed to, uint256 value, bytes data);
    event ConfirmTransaction(uint256 indexed txId, address indexed owner);
    event ExecuteTransaction(uint256 indexed txId);
    
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }
    
    modifier txExists(uint256 txId) {
        require(txId < transactionCount, "Transaction does not exist");
        _;
    }
    
    modifier notExecuted(uint256 txId) {
        require(!transactions[txId].executed, "Already executed");
        _;
    }
    
    modifier notConfirmed(uint256 txId) {
        require(!transactions[txId].confirmed[msg.sender], "Already confirmed");
        _;
    }
    
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required");
        
        for (uint256 i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]], "Owner not unique");
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        
        required = _required;
    }
    
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
    
    function submitTransaction(address to, uint256 value, bytes memory data) public onlyOwner returns (uint256) {
        uint256 txId = transactionCount++;
        
        Transaction storage tx = transactions[txId];
        tx.to = to;
        tx.value = value;
        tx.data = data;
        tx.executed = false;
        
        emit SubmitTransaction(txId, to, value, data);
        
        return txId;
    }
    
    function confirmTransaction(uint256 txId) public onlyOwner txExists(txId) notExecuted(txId) notConfirmed(txId) {
        Transaction storage tx = transactions[txId];
        tx.confirmed[msg.sender] = true;
        tx.confirmations++;
        
        emit ConfirmTransaction(txId, msg.sender);
    }
    
    function executeTransaction(uint256 txId) public onlyOwner txExists(txId) notExecuted(txId) {
        Transaction storage tx = transactions[txId];
        require(tx.confirmations >= required, "Not enough confirmations");
        
        tx.executed = true;
        
        (bool success, ) = tx.to.call{value: tx.value}(tx.data);
        require(success, "Transaction failed");
        
        emit ExecuteTransaction(txId);
    }
    
    function revokeConfirmation(uint256 txId) public onlyOwner txExists(txId) notExecuted(txId) {
        Transaction storage tx = transactions[txId];
        require(tx.confirmed[msg.sender], "Not confirmed");
        
        tx.confirmed[msg.sender] = false;
        tx.confirmations--;
    }
    
    function getOwners() public view returns (address[] memory) {
        return owners;
    }
    
    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }
    
    function getConfirmationCount(uint256 txId) public view returns (uint256) {
        return transactions[txId].confirmations;
    }
}
```

### 3.2 Streaming Payments

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StreamingPayment {
    using SafeERC20 for IERC20;
    
    struct Stream {
        address sender;
        address recipient;
        uint256 totalAmount;
        uint256 withdrawn;
        uint256 startTime;
        uint256 duration;
        IERC20 token;
        bool cancelled;
    }
    
    mapping(uint256 => Stream) public streams;
    uint256 public streamCount;
    
    event StreamCreated(uint256 indexed streamId, address sender, address recipient, uint256 amount, uint256 duration);
    event StreamWithdrawn(uint256 indexed streamId, address recipient, uint256 amount);
    event StreamCancelled(uint256 indexed streamId, uint256 refund, uint256 payment);
    
    function createStream(
        address recipient,
        uint256 totalAmount,
        uint256 startTime,
        uint256 duration,
        IERC20 token
    ) external returns (uint256) {
        require(recipient != address(0), "Invalid recipient");
        require(duration > 0, "Duration must be > 0");
        
        // Transfer tokens from sender
        token.safeTransferFrom(msg.sender, address(this), totalAmount);
        
        uint256 streamId = streamCount++;
        Stream storage stream = streams[streamId];
        
        stream.sender = msg.sender;
        stream.recipient = recipient;
        stream.totalAmount = totalAmount;
        stream.startTime = startTime;
        stream.duration = duration;
        stream.token = token;
        
        emit StreamCreated(streamId, msg.sender, recipient, totalAmount, duration);
        
        return streamId;
    }
    
    function withdrawFromStream(uint256 streamId) external returns (uint256) {
        Stream storage stream = streams[streamId];
        require(stream.recipient == msg.sender || stream.sender == msg.sender, "Not authorized");
        require(!stream.cancelled, "Stream cancelled");
        
        uint256 available = calculateAvailable(streamId);
        require(available > 0, "Nothing to withdraw");
        
        stream.withdrawn += available;
        stream.token.safeTransfer(msg.sender, available);
        
        emit StreamWithdrawn(streamId, msg.sender, available);
        
        return available;
    }
    
    function cancelStream(uint256 streamId) external {
        Stream storage stream = streams[streamId];
        require(stream.sender == msg.sender || stream.recipient == msg.sender, "Not authorized");
        require(!stream.cancelled, "Already cancelled");
        
        stream.cancelled = true;
        
        uint256 available = calculateAvailable(streamId);
        uint256 refund = stream.totalAmount - stream.withdrawn - available;
        
        // Transfer accrued to recipient
        if (available > 0) {
            stream.token.safeTransfer(stream.recipient, available);
        }
        
        // Refund remaining to sender
        if (refund > 0) {
            stream.token.safeTransfer(stream.sender, refund);
        }
        
        emit StreamCancelled(streamId, refund, available);
    }
    
    function calculateAvailable(uint256 streamId) public view returns (uint256) {
        Stream storage stream = streams[streamId];
        
        if (stream.cancelled) return 0;
        
        uint256 now = block.timestamp;
        
        if (now < stream.startTime) return 0;
        if (now >= stream.startTime + stream.duration) {
            return stream.totalAmount - stream.withdrawn;
        }
        
        uint256 timePassed = now - stream.startTime;
        uint256 totalWithdrawable = (stream.totalAmount * timePassed) / stream.duration;
        
        return totalWithdrawable - stream.withdrawn;
    }
    
    function getStream(uint256 streamId) external view returns (Stream memory) {
        return streams[streamId];
    }
}
```

---

## Part 4: Proposal System

### 4.1 Proposal Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProposalSystem {
    enum ProposalType { Text, Transfer, FunctionCall, Upgrade }
    enum ProposalStatus { Pending, Active, Passed, Rejected, Executed, Cancelled }
    
    struct Proposal {
        uint256 id;
        address proposer;
        string title;
        string description;
        ProposalType propType;
        ProposalStatus status;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        uint256 startTime;
        uint256 endTime;
        mapping(address => Vote) votes;
        // Execution data
        address target;
        uint256 value;
        bytes data;
    }
    
    struct Vote {
        bool hasVoted;
        uint8 support;  // 0=Against, 1=For, 2=Abstain
        uint256 weight;
    }
    
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;
    uint256 public votingPeriod = 7 days;
    uint256 public quorum = 1000 * 10**18;  // 1000 tokens
    
    event ProposalCreated(uint256 indexed id, address indexed proposer, string title);
    event VoteCast(uint256 indexed id, address indexed voter, uint8 support, uint256 weight);
    event ProposalExecuted(uint256 indexed id);
    event ProposalCancelled(uint256 indexed id);
    
    function createProposal(
        string memory title,
        string memory description,
        ProposalType propType,
        address target,
        uint256 value,
        bytes memory data
    ) external returns (uint256) {
        proposalCount++;
        Proposal storage proposal = proposals[proposalCount];
        
        proposal.id = proposalCount;
        proposal.proposer = msg.sender;
        proposal.title = title;
        proposal.description = description;
        proposal.propType = propType;
        proposal.status = ProposalStatus.Pending;
        proposal.startTime = block.timestamp + 1 days;  // Start after 1 day
        proposal.endTime = proposal.startTime + votingPeriod;
        proposal.target = target;
        proposal.value = value;
        proposal.data = data;
        
        emit ProposalCreated(proposalCount, msg.sender, title);
        
        return proposalCount;
    }
    
    function castVote(uint256 proposalId, uint8 support, uint256 weight) external {
        require(support <= 2, "Invalid vote");
        
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime, "Voting not started");
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(!proposal.votes[msg.sender].hasVoted, "Already voted");
        
        proposal.votes[msg.sender] = Vote({
            hasVoted: true,
            support: support,
            weight: weight
        });
        
        if (support == 0) {
            proposal.votesAgainst += weight;
        } else if (support == 1) {
            proposal.votesFor += weight;
        } else {
            proposal.votesAbstain += weight;
        }
        
        emit VoteCast(proposalId, msg.sender, support, weight);
    }
    
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(proposal.status == ProposalStatus.Active || proposal.status == ProposalStatus.Pending, "Invalid status");
        
        // Check quorum
        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst + proposal.votesAbstain;
        require(totalVotes >= quorum, "Quorum not met");
        
        // Check if passed
        if (proposal.votesFor > proposal.votesAgainst) {
            proposal.status = ProposalStatus.Passed;
            
            // Execute
            if (proposal.propType == ProposalType.Transfer) {
                (bool success, ) = proposal.target.call{value: proposal.value}("");
                require(success, "Transfer failed");
            } else if (proposal.propType == ProposalType.FunctionCall) {
                (bool success, ) = proposal.target.call{value: proposal.value}(proposal.data);
                require(success, "Call failed");
            }
            
            proposal.status = ProposalStatus.Executed;
            emit ProposalExecuted(proposalId);
        } else {
            proposal.status = ProposalStatus.Rejected;
        }
    }
    
    function cancelProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.proposer == msg.sender, "Not proposer");
        require(block.timestamp < proposal.startTime, "Voting started");
        
        proposal.status = ProposalStatus.Cancelled;
        emit ProposalCancelled(proposalId);
    }
}
```

---

## Best Practices

### ✅ Do This

- ✅ Use OpenZeppelin Governor contracts
- ✅ Implement timelock for security
- ✅ Set appropriate quorum thresholds
- ✅ Allow vote delegation
- ✅ Implement emergency cancellation
- ✅ Use multi-sig for treasury
- ✅ Add proposal thresholds to prevent spam

### ❌ Avoid This

- ❌ Low quorum requirements
- ❌ No timelock on execution
- ❌ Unlimited proposal creation
- ❌ No vote delegation mechanism
- ❌ Single-sig treasury control
- ❌ No emergency pause mechanism

---

## Related Skills

- `@smart-contract-developer` - Smart contract development
- `@web3-frontend-specialist` - Web3 integration
- `@expert-web3-blockchain` - Blockchain architecture
- `@nft-developer` - NFT governance
- `@dao-governance-specialist` - Advanced governance
