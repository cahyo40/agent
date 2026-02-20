---
name: nft-developer
description: "NFT developer specializing in ERC-721, ERC-1155, NFT marketplaces, minting platforms, metadata standards, IPFS storage, and royalty implementations"
---

# NFT Developer

## Overview

This skill transforms you into an **NFT Developer** who builds NFT collections, marketplaces, and minting platforms. You'll master ERC-721 and ERC-1155 standards, metadata standards, IPFS storage, royalty implementations, and gas-optimized minting contracts.

## When to Use This Skill

- Use when creating NFT collections (ERC-721, ERC-1155)
- Use when building NFT marketplaces
- Use when implementing minting platforms
- Use when working with IPFS for NFT metadata
- Use when implementing royalties and secondary sales

---

## Part 1: NFT Standards

### 1.1 ERC-721 vs ERC-1155

| Feature | ERC-721 | ERC-1155 |
|---------|---------|----------|
| **Token Type** | Non-fungible (unique) | Fungible + Non-fungible |
| **Supply** | One per token ID | Multiple per token ID |
| **Gas Efficiency** | Higher gas per NFT | Batch transfers, lower gas |
| **Use Case** | Art, collectibles, unique items | Gaming items, editions, collections |
| **Royalties** | Per NFT | Per token type |

### 1.2 Standard Interfaces

```solidity
// ERC-721 Core Interface
interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// ERC-1155 Core Interface
interface IERC1155 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}
```

---

## Part 2: NFT Contract Implementation

### 2.1 ERC-721 NFT Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ArtCollection is ERC721, ERC721URIStorage, ERC721Royalty, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIdCounter;
    
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MINT_PRICE = 0.05 ether;
    bool public publicMintEnabled = false;
    
    // Metadata
    string private _baseTokenURI;
    
    constructor() ERC721("Art Collection", "ART") Ownable(msg.sender) {
        _baseTokenURI = "ipfs://";
    }
    
    // Minting
    function mint() public payable {
        require(publicMintEnabled, "Public mint not enabled");
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Max supply reached");
        require(msg.value >= MINT_PRICE, "Insufficient payment");
        
        _safeMint(msg.sender, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }
    
    function ownerMint(address to) public onlyOwner {
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Max supply reached");
        _safeMint(to, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }
    
    // Withdraw
    function withdraw() public onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
    
    // Metadata overrides
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
    
    function setBaseURI(string calldata newBaseURI) public onlyOwner {
        _baseTokenURI = newBaseURI;
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    // Royalty override
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }
    
    function deleteDefaultRoyalty() public onlyOwner {
        _deleteDefaultRoyalty();
    }
    
    // Required overrides
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    function burn(uint256 tokenId) public override(ERC721Burnable) {
        super.burn(tokenId);
    }
}
```

### 2.2 ERC-1155 Multi-Token Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameItems is ERC1155, ERC1155Supply, ERC1155Burnable, Ownable {
    // Token IDs
    uint256 public constant GOLD_TOKEN = 0;
    uint256 public constant SILVER_TOKEN = 1;
    uint256 public constant BRONZE_TOKEN = 2;
    uint256 public constant WEAPON_COMMON = 100;
    uint256 public constant WEAPON_RARE = 101;
    uint256 public constant WEAPON_LEGENDARY = 102;
    
    // Minting limits
    mapping(uint256 => uint256) public maxSupply;
    mapping(uint256 => uint256) public totalMinted;
    
    constructor() ERC1155("https://game.example/items/{id}.json") Ownable(msg.sender) {
        // Set max supplies
        maxSupply[GOLD_TOKEN] = 1000000;
        maxSupply[SILVER_TOKEN] = 500000;
        maxSupply[BRONZE_TOKEN] = 100000;
        maxSupply[WEAPON_COMMON] = 100000;
        maxSupply[WEAPON_RARE] = 10000;
        maxSupply[WEAPON_LEGENDARY] = 1000;
    }
    
    // Batch mint (only owner)
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts) public onlyOwner {
        require(ids.length == amounts.length, "Arrays length mismatch");
        
        for (uint256 i = 0; i < ids.length; i++) {
            require(totalMinted[ids[i]] + amounts[i] <= maxSupply[ids[i]], "Would exceed max supply");
            totalMinted[ids[i]] += amounts[i];
        }
        
        _mintBatch(to, ids, amounts, "");
    }
    
    // Single mint with payment
    function mint(uint256 id, uint256 amount) public payable {
        require(totalMinted[id] + amount <= maxSupply[id], "Would exceed max supply");
        
        uint256 price = getPrice(id);
        require(msg.value >= price * amount, "Insufficient payment");
        
        totalMinted[id] += amount;
        _mint(msg.sender, id, amount, "");
    }
    
    function getPrice(uint256 id) public pure returns (uint256) {
        if (id == GOLD_TOKEN) return 0.001 ether;
        if (id == SILVER_TOKEN) return 0.0005 ether;
        if (id == BRONZE_TOKEN) return 0.0001 ether;
        if (id == WEAPON_COMMON) return 0.01 ether;
        if (id == WEAPON_RARE) return 0.05 ether;
        if (id == WEAPON_LEGENDARY) return 0.1 ether;
        return 0;
    }
    
    // Withdraw
    function withdraw() public onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
    
    // Required overrides
    function uri(uint256 tokenId) public view override returns (string memory) {
        return super.uri(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, ERC1155Supply) returns (bool) {
        return super.supportesInterface(interfaceId);
    }
    
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }
}
```

---

## Part 3: NFT Metadata

### 3.1 Metadata Standard

```json
{
  "name": "Art Collection #1234",
  "description": "A unique piece from the Art Collection",
  "image": "ipfs://QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/1234.png",
  "external_url": "https://artcollection.io/token/1234",
  "attributes": [
    {
      "trait_type": "Background",
      "value": "Blue"
    },
    {
      "trait_type": "Body",
      "value": "Gold"
    },
    {
      "trait_type": "Eyes",
      "value": "Laser"
    },
    {
      "trait_type": "Rarity Score",
      "value": 87.5,
      "display_type": "number"
    },
    {
      "trait_type": "Generation Date",
      "value": 1704067200,
      "display_type": "date"
    }
  ],
  "animation_url": "ipfs://QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/1234.mp4",
  "youtube_url": "https://youtube.com/watch?v=..."
}
```

### 3.2 Metadata Generation Script

```javascript
// scripts/generate-metadata.js
const fs = require('fs');
const path = require('path');

const TRAITS = {
  Background: [
    { value: 'Blue', rarity: 30 },
    { value: 'Red', rarity: 25 },
    { value: 'Green', rarity: 20 },
    { value: 'Purple', rarity: 15 },
    { value: 'Gold', rarity: 10 },
  ],
  Body: [
    { value: 'Human', rarity: 40 },
    { value: 'Robot', rarity: 30 },
    { value: 'Alien', rarity: 20 },
    { value: 'Zombie', rarity: 10 },
  ],
  Eyes: [
    { value: 'Normal', rarity: 50 },
    { value: 'Sunglasses', rarity: 25 },
    { value: '3D Glasses', rarity: 15 },
    { value: 'Laser', rarity: 10 },
  ],
};

function getRandomTrait(traits) {
  const total = traits.reduce((sum, t) => sum + t.rarity, 0);
  let random = Math.random() * total;
  
  for (const trait of traits) {
    if (random < trait.rarity) return trait.value;
    random -= trait.rarity;
  }
  
  return traits[0].value;
}

function generateMetadata(tokenId) {
  const attributes = Object.entries(TRAITS).map(([trait_type, options]) => ({
    trait_type,
    value: getRandomTrait(options),
  }));
  
  return {
    name: `Art Collection #${tokenId}`,
    description: `A unique NFT from the Art Collection series.`,
    image: `ipfs://YOUR_IPFS_HASH/${tokenId}.png`,
    external_url: `https://artcollection.io/token/${tokenId}`,
    attributes,
  };
}

// Generate all metadata files
const outputDir = './metadata';
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

for (let i = 0; i < 10000; i++) {
  const metadata = generateMetadata(i);
  fs.writeFileSync(
    path.join(outputDir, `${i}.json`),
    JSON.stringify(metadata, null, 2)
  );
}

console.log('Generated 10000 metadata files');
```

---

## Part 4: IPFS Storage

### 4.1 Upload to IPFS (Pinata)

```javascript
// scripts/upload-to-ipfs.js
const FormData = require('form-data');
const fetch = require('node-fetch');
const fs = require('fs');
const path = require('path');

const PINATA_API_KEY = process.env.PINATA_API_KEY;
const PINATA_SECRET_KEY = process.env.PINATA_SECRET_KEY;

async function pinFileToIPFS(filePath) {
  const file = fs.createReadStream(filePath);
  const formData = new FormData();
  formData.append('file', file);
  
  const pinataMetadata = JSON.stringify({
    name: path.basename(filePath),
  });
  formData.append('pinataMetadata', pinataMetadata);
  
  try {
    const res = await fetch('https://api.pinata.cloud/pinning/pinFileToIPFS', {
      method: 'POST',
      headers: {
        'Content-Type': `multipart/form-data; boundary=${formData._boundary}`,
        pinata_api_key: PINATA_API_KEY,
        pinata_secret_api_key: PINATA_SECRET_KEY,
      },
      body: formData,
    });
    
    const data = await res.json();
    return data.IpfsHash;
  } catch (error) {
    console.error('Error uploading to IPFS:', error);
    throw error;
  }
}

async function pinJSONToIPFS(jsonData) {
  try {
    const res = await fetch('https://api.pinata.cloud/pinning/pinJSONToIPFS', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        pinata_api_key: PINATA_API_KEY,
        pinata_secret_api_key: PINATA_SECRET_KEY,
      },
      body: JSON.stringify({
        pinataContent: jsonData,
        pinataMetadata: {
          name: jsonData.name,
        },
      }),
    });
    
    const data = await res.json();
    return data.IpfsHash;
  } catch (error) {
    console.error('Error pinning JSON:', error);
    throw error;
  }
}

// Upload collection
async function uploadCollection() {
  const metadataDir = './metadata';
  const imagesDir = './images';
  
  const files = fs.readdirSync(metadataDir);
  
  for (const file of files) {
    const tokenId = path.basename(file, '.json');
    
    // Upload image
    const imageHash = await pinFileToIPFS(path.join(imagesDir, `${tokenId}.png`));
    
    // Update metadata with image hash
    const metadata = JSON.parse(fs.readFileSync(path.join(metadataDir, file)));
    metadata.image = `ipfs://${imageHash}`;
    
    // Upload metadata
    const metadataHash = await pinJSONToIPFS(metadata);
    console.log(`Token ${tokenId}: ipfs://${metadataHash}`);
  }
}

uploadCollection();
```

### 4.2 Arweave Alternative

```javascript
// scripts/upload-to-arweave.js
const Arweave = require('arweave');

const arweave = Arweave.init({
  host: 'arweave.net',
  port: 443,
  protocol: 'https',
});

async function uploadToArweave(data, contentType) {
  const transaction = await arweave.createTransaction({
    data: JSON.stringify(data),
  });
  
  transaction.addTag('Content-Type', contentType);
  
  await arweave.transactions.sign(transaction, WALLET_KEY);
  await arweave.transactions.post(transaction);
  
  return transaction.id;
}
```

---

## Part 5: NFT Marketplace

### 5.1 Marketplace Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard, IERC721Receiver {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }
    
    mapping(uint256 => Listing) public listings;
    uint256 private _listingIdCounter;
    
    uint256 public platformFee = 250; // 2.5%
    address public platformFeeRecipient;
    
    event Listed(uint256 indexed listingId, address indexed seller, address indexed nftContract, uint256 tokenId, uint256 price);
    event Sold(uint256 indexed listingId, address indexed buyer, uint256 price);
    event Cancelled(uint256 indexed listingId);
    
    constructor(address _platformFeeRecipient) {
        platformFeeRecipient = _platformFeeRecipient;
    }
    
    function createListing(address nftContract, uint256 tokenId, uint256 price) public returns (uint256) {
        require(price > 0, "Price must be > 0");
        
        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not token owner");
        require(nft.isApprovedForAll(msg.sender, address(this)) || nft.getApproved(tokenId) == address(this), "Not approved");
        
        uint256 listingId = _listingIdCounter++;
        
        listings[listingId] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            active: true
        });
        
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        
        emit Listed(listingId, msg.sender, nftContract, tokenId, price);
        
        return listingId;
    }
    
    function buyListing(uint256 listingId) public payable nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing not active");
        require(msg.value >= listing.price, "Insufficient payment");
        
        address seller = listing.seller;
        address nftContract = listing.nftContract;
        uint256 tokenId = listing.tokenId;
        uint256 price = listing.price;
        
        // Mark as inactive
        listing.active = false;
        
        // Calculate fees
        uint256 fee = (price * platformFee) / 10000;
        uint256 sellerProceeds = price - fee;
        
        // Transfer payment
        payable(seller).transfer(sellerProceeds);
        payable(platformFeeRecipient).transfer(fee);
        
        // Transfer NFT
        IERC721(nftContract).safeTransferFrom(address(this), msg.sender, tokenId);
        
        emit Sold(listingId, msg.sender, price);
        
        // Refund excess payment
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }
    
    function cancelListing(uint256 listingId) public {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing not active");
        require(listing.seller == msg.sender, "Not seller");
        
        listing.active = false;
        
        IERC721(listing.nftContract).safeTransferFrom(address(this), msg.sender, listing.tokenId);
        
        emit Cancelled(listingId);
    }
    
    function updatePrice(uint256 listingId, uint256 newPrice) public {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing not active");
        require(listing.seller == msg.sender, "Not seller");
        require(newPrice > 0, "Price must be > 0");
        
        listing.price = newPrice;
    }
    
    // Required for receiving NFTs
    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
```

### 5.2 Frontend Integration

```typescript
// hooks/useNFTMarketplace.ts
import { useWriteContract, useReadContract, useWaitForTransactionReceipt } from 'wagmi';

const MARKETPLACE_ABI = [/* ... */];
const MARKETPLACE_ADDRESS = '0x...';

export function useCreateListing() {
  const { writeContract, data: hash } = useWriteContract();
  
  const createListing = (nftContract: string, tokenId: number, price: bigint) => {
    // First approve marketplace
    writeContract({
      address: nftContract as `0x${string}`,
      abi: ERC721_ABI,
      functionName: 'setApprovalForAll',
      args: [MARKETPLACE_ADDRESS, true],
    });
    
    // Then create listing
    writeContract({
      address: MARKETPLACE_ADDRESS,
      abi: MARKETPLACE_ABI,
      functionName: 'createListing',
      args: [nftContract, tokenId, price],
    });
  };
  
  return { createListing, hash };
}

export function useBuyNFT(listingId: number, price: bigint) {
  const { writeContract, data: hash } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });
  
  const buy = () => {
    writeContract({
      address: MARKETPLACE_ADDRESS,
      abi: MARKETPLACE_ABI,
      functionName: 'buyListing',
      args: [listingId],
      value: price,
    });
  };
  
  return { buy, hash, isConfirming, isSuccess };
}
```

---

## Best Practices

### ✅ Do This

- ✅ Use OpenZeppelin contracts as base
- ✅ Implement royalty standards (EIP-2981)
- ✅ Store metadata on IPFS/Arweave (not centralized servers)
- ✅ Implement proper access control
- ✅ Add reentrancy guards for marketplace
- ✅ Test gas optimization
- ✅ Verify contracts on Etherscan

### ❌ Avoid This

- ❌ Storing metadata on centralized servers
- ❌ Not implementing royalties
- ❌ Missing access control
- ❌ No reentrancy protection
- ❌ Hardcoding metadata URIs without flexibility
- ❌ Not handling failed transactions

---

## Related Skills

- `@smart-contract-developer` - Smart contract development
- `@web3-frontend-specialist` - Web3 frontend
- `@expert-web3-blockchain` - Blockchain architecture
- `@senior-solidity-developer` - Solidity development
- `@dao-developer` - DAO implementations
