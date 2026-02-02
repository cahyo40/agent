---
name: crypto-wallet-developer
description: "Expert cryptocurrency wallet development including key management, multi-chain support, transaction signing, and secure storage"
---

# Crypto Wallet Developer

## Overview

This skill transforms you into a **Cryptocurrency Wallet Expert**. You will master **Key Management**, **Multi-Chain Support**, **Transaction Signing**, **HD Wallets**, and **Secure Storage** for building production-ready crypto wallets.

## When to Use This Skill

- Use when building cryptocurrency wallets
- Use when implementing key management
- Use when creating multi-chain support
- Use when handling transaction signing
- Use when building DeFi interfaces

---

## Part 1: Wallet Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                      Crypto Wallet                           │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Keys       │ Chains      │ Transactions│ DApps              │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Secure Enclave / Keychain                      │
├─────────────────────────────────────────────────────────────┤
│              Blockchain RPC / Indexers                       │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **HD Wallet** | Hierarchical Deterministic (BIP32) |
| **Mnemonic** | 12/24 word seed phrase |
| **Private Key** | Secret for signing |
| **Public Key** | Derived from private key |
| **Address** | Derived from public key |
| **Derivation Path** | Key hierarchy path |

---

## Part 2: Wallet Creation

### 2.1 Generate HD Wallet

```typescript
import { ethers } from 'ethers';
import * as bip39 from 'bip39';
import { HDNodeWallet } from 'ethers';

// Generate new mnemonic
function generateMnemonic(strength = 128): string {
  // 128 bits = 12 words, 256 bits = 24 words
  return bip39.generateMnemonic(strength);
}

// Create wallet from mnemonic
function createWalletFromMnemonic(mnemonic: string, path?: string): HDNodeWallet {
  const derivationPath = path || "m/44'/60'/0'/0/0";  // Ethereum default
  
  const wallet = ethers.HDNodeWallet.fromMnemonic(
    ethers.Mnemonic.fromPhrase(mnemonic),
    derivationPath
  );
  
  return wallet;
}

// Derive multiple accounts
function deriveAccounts(mnemonic: string, count = 5): Account[] {
  const accounts: Account[] = [];
  
  for (let i = 0; i < count; i++) {
    const path = `m/44'/60'/0'/0/${i}`;
    const wallet = createWalletFromMnemonic(mnemonic, path);
    
    accounts.push({
      index: i,
      path,
      address: wallet.address,
      privateKey: wallet.privateKey,  // Store securely!
    });
  }
  
  return accounts;
}
```

### 2.2 Multi-Chain Derivation Paths

```typescript
const DERIVATION_PATHS: Record<string, string> = {
  ethereum: "m/44'/60'/0'/0/0",
  bitcoin: "m/44'/0'/0'/0/0",
  bitcoin_testnet: "m/44'/1'/0'/0/0",
  solana: "m/44'/501'/0'/0'",
  cosmos: "m/44'/118'/0'/0/0",
  polygon: "m/44'/60'/0'/0/0",  // Same as ETH (EVM compatible)
};

function deriveAddressForChain(mnemonic: string, chain: string, index = 0): string {
  const basePath = DERIVATION_PATHS[chain];
  if (!basePath) throw new Error(`Unsupported chain: ${chain}`);
  
  // Replace last segment with index
  const path = basePath.replace(/\/0$/, `/${index}`);
  
  if (chain === 'solana') {
    return deriveSolanaAddress(mnemonic, path);
  } else if (chain.startsWith('bitcoin')) {
    return deriveBitcoinAddress(mnemonic, path, chain === 'bitcoin_testnet');
  } else {
    // EVM chains
    const wallet = createWalletFromMnemonic(mnemonic, path);
    return wallet.address;
  }
}
```

---

## Part 3: Secure Key Storage

### 3.1 Encrypt Private Key

```typescript
import * as crypto from 'crypto';

interface EncryptedWallet {
  ciphertext: string;
  iv: string;
  salt: string;
  tag: string;
}

function encryptPrivateKey(privateKey: string, password: string): EncryptedWallet {
  const salt = crypto.randomBytes(32);
  const iv = crypto.randomBytes(16);
  
  // Derive key from password using PBKDF2
  const key = crypto.pbkdf2Sync(password, salt, 100000, 32, 'sha256');
  
  const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
  
  let ciphertext = cipher.update(privateKey, 'utf8', 'hex');
  ciphertext += cipher.final('hex');
  
  const tag = cipher.getAuthTag();
  
  return {
    ciphertext,
    iv: iv.toString('hex'),
    salt: salt.toString('hex'),
    tag: tag.toString('hex'),
  };
}

function decryptPrivateKey(encrypted: EncryptedWallet, password: string): string {
  const salt = Buffer.from(encrypted.salt, 'hex');
  const iv = Buffer.from(encrypted.iv, 'hex');
  const tag = Buffer.from(encrypted.tag, 'hex');
  
  const key = crypto.pbkdf2Sync(password, salt, 100000, 32, 'sha256');
  
  const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
  decipher.setAuthTag(tag);
  
  let privateKey = decipher.update(encrypted.ciphertext, 'hex', 'utf8');
  privateKey += decipher.final('utf8');
  
  return privateKey;
}
```

### 3.2 Mobile Secure Storage

```typescript
// React Native with react-native-keychain
import * as Keychain from 'react-native-keychain';

async function storeSecurely(key: string, value: string): Promise<void> {
  await Keychain.setGenericPassword(key, value, {
    service: 'crypto-wallet',
    accessControl: Keychain.ACCESS_CONTROL.BIOMETRY_CURRENT_SET_OR_DEVICE_PASSCODE,
    accessible: Keychain.ACCESSIBLE.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
  });
}

async function retrieveSecurely(key: string): Promise<string | null> {
  const credentials = await Keychain.getGenericPassword({
    service: 'crypto-wallet',
  });
  
  if (credentials && credentials.username === key) {
    return credentials.password;
  }
  return null;
}
```

---

## Part 4: Transaction Signing

### 4.1 Sign Ethereum Transaction

```typescript
import { ethers, TransactionRequest } from 'ethers';

async function signAndSendTransaction(
  wallet: ethers.Wallet,
  to: string,
  amount: string,
  data?: string
): Promise<string> {
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const connectedWallet = wallet.connect(provider);
  
  // Build transaction
  const tx: TransactionRequest = {
    to,
    value: ethers.parseEther(amount),
    data: data || '0x',
  };
  
  // Estimate gas
  const gasEstimate = await provider.estimateGas(tx);
  const feeData = await provider.getFeeData();
  
  tx.gasLimit = gasEstimate * BigInt(12) / BigInt(10);  // 20% buffer
  tx.maxFeePerGas = feeData.maxFeePerGas;
  tx.maxPriorityFeePerGas = feeData.maxPriorityFeePerGas;
  tx.nonce = await provider.getTransactionCount(wallet.address);
  tx.chainId = (await provider.getNetwork()).chainId;
  
  // Sign and send
  const signedTx = await connectedWallet.signTransaction(tx);
  const txResponse = await provider.broadcastTransaction(signedTx);
  
  return txResponse.hash;
}
```

### 4.2 Sign ERC-20 Token Transfer

```typescript
async function sendToken(
  wallet: ethers.Wallet,
  tokenAddress: string,
  to: string,
  amount: string,
  decimals = 18
): Promise<string> {
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const connectedWallet = wallet.connect(provider);
  
  // ERC-20 interface
  const erc20Interface = new ethers.Interface([
    'function transfer(address to, uint256 amount) returns (bool)',
  ]);
  
  const amountWei = ethers.parseUnits(amount, decimals);
  const data = erc20Interface.encodeFunctionData('transfer', [to, amountWei]);
  
  const tx = await connectedWallet.sendTransaction({
    to: tokenAddress,
    data,
  });
  
  return tx.hash;
}
```

---

## Part 5: Balance & Transaction History

### 5.1 Fetch Balances

```typescript
interface TokenBalance {
  symbol: string;
  name: string;
  address: string;
  balance: string;
  decimals: number;
  usdValue?: number;
}

async function getBalances(address: string, chainId: number): Promise<TokenBalance[]> {
  const provider = new ethers.JsonRpcProvider(getRpcUrl(chainId));
  
  // Native balance
  const nativeBalance = await provider.getBalance(address);
  const balances: TokenBalance[] = [{
    symbol: 'ETH',
    name: 'Ethereum',
    address: '0x0000000000000000000000000000000000000000',
    balance: ethers.formatEther(nativeBalance),
    decimals: 18,
  }];
  
  // Token balances (using an indexer API like Alchemy)
  const tokenBalances = await fetchTokenBalances(address, chainId);
  balances.push(...tokenBalances);
  
  // Get USD prices
  const prices = await fetchPrices(balances.map(b => b.address));
  
  return balances.map(b => ({
    ...b,
    usdValue: parseFloat(b.balance) * (prices[b.address] || 0),
  }));
}
```

### 5.2 Transaction History

```typescript
interface TxHistoryItem {
  hash: string;
  from: string;
  to: string;
  value: string;
  timestamp: number;
  status: 'confirmed' | 'pending' | 'failed';
  type: 'send' | 'receive' | 'swap' | 'contract';
}

async function getTransactionHistory(
  address: string,
  chainId: number,
  page = 1
): Promise<TxHistoryItem[]> {
  // Use blockchain indexer (Etherscan, Alchemy, etc.)
  const response = await fetch(
    `https://api.etherscan.io/api?module=account&action=txlist&address=${address}&page=${page}&offset=20&sort=desc&apikey=${API_KEY}`
  );
  
  const data = await response.json();
  
  return data.result.map((tx: any) => ({
    hash: tx.hash,
    from: tx.from,
    to: tx.to,
    value: ethers.formatEther(tx.value),
    timestamp: parseInt(tx.timeStamp) * 1000,
    status: tx.isError === '0' ? 'confirmed' : 'failed',
    type: tx.from.toLowerCase() === address.toLowerCase() ? 'send' : 'receive',
  }));
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Never Log Private Keys**: Mask in logs.
- ✅ **Use Biometric Auth**: For signing.
- ✅ **Validate Addresses**: Before sending.

### ❌ Avoid This

- ❌ **Store Plain Text Keys**: Always encrypt.
- ❌ **Skip Gas Estimation**: Transactions may fail.
- ❌ **Ignore Chain ID**: Wrong chain = lost funds.

---

## Related Skills

- `@senior-web3-developer` - Web3 integration
- `@decentralized-finance-specialist` - DeFi
- `@react-native-developer` - Mobile wallet
