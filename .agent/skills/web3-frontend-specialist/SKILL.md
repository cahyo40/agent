---
name: web3-frontend-specialist
description: "Web3 frontend specialist building dApps with wagmi, viem, RainbowKit, ethers.js, connecting wallets, signing transactions, and integrating smart contracts"
---

# Web3 Frontend Specialist

## Overview

This skill transforms you into a **Web3 Frontend Specialist** who builds decentralized applications (dApps) using modern Web3 libraries. You'll master wallet connections, transaction signing, smart contract integration, and creating seamless Web3 user experiences with wagmi, viem, RainbowKit, and ethers.js.

## When to Use This Skill

- Use when building decentralized application frontends
- Use when integrating wallet connections (MetaMask, WalletConnect, etc.)
- Use when interacting with smart contracts from React/TypeScript
- Use when implementing Web3 authentication
- Use when building NFT marketplaces, DeFi interfaces, or DAO tools

---

## Part 1: Web3 Fundamentals

### 1.1 Web3 Stack Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Application                      │
│  (React, Next.js, Vue, Svelte)                              │
├─────────────────────────────────────────────────────────────┤
│                    Web3 Libraries                            │
│  (wagmi, viem, ethers.js, web3.js)                          │
├─────────────────────────────────────────────────────────────┤
│                    Wallet Connectors                         │
│  (RainbowKit, Web3Modal, ConnectKit)                        │
├─────────────────────────────────────────────────────────────┤
│                    Blockchain RPC                            │
│  (Alchemy, Infura, QuickNode, Public RPC)                   │
├─────────────────────────────────────────────────────────────┤
│                    Smart Contracts                           │
│  (Solidity, Vyper on Ethereum, EVM chains)                  │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Library Comparison

| Library | Purpose | Bundle Size | Best For |
|---------|---------|-------------|----------|
| **wagmi** | React Hooks for Ethereum | ~30KB | React applications |
| **viem** | TypeScript Ethereum client | ~25KB | Low-level Ethereum interaction |
| **ethers.js** | Complete Ethereum library | ~80KB | Full-featured dApps |
| **web3.js** | Original Ethereum library | ~150KB | Legacy projects |
| **RainbowKit** | Wallet connection UI | ~40KB | Beautiful wallet modal |

---

## Part 2: Setup & Configuration

### 2.1 wagmi + viem + RainbowKit Setup

```bash
# Install dependencies
npm install wagmi viem @rainbow-me/rainbowkit @tanstack/react-query
```

```typescript
// wagmi.config.ts
import { http, createConfig } from 'wagmi';
import { mainnet, sepolia, polygon } from 'wagmi/chains';
import { injected, walletConnect, metaMask } from 'wagmi/connectors';

export const config = createConfig({
  chains: [mainnet, sepolia, polygon],
  connectors: [
    injected(),
    walletConnect({ projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_ID }),
    metaMask(),
  ],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(),
    [polygon.id]: http(),
  ],
});
```

```typescript
// providers.tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { WagmiProvider } from 'wagmi';
import { RainbowKitProvider } from '@rainbow-me/rainbowkit';
import { config } from './wagmi';

const queryClient = new QueryClient();

export function Web3Provider({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          {children}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
```

### 2.2 App Layout

```typescript
// app/layout.tsx
import '@rainbow-me/rainbowkit/styles.css';
import { Web3Provider } from './providers';

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <Web3Provider>
          {children}
        </Web3Provider>
      </body>
    </html>
  );
}
```

---

## Part 3: Wallet Connection

### 3.1 Connect Button

```typescript
// components/ConnectButton.tsx
'use client';

import { ConnectButton } from '@rainbow-me/rainbowkit';

export function Header() {
  return (
    <header className="flex justify-between items-center p-4">
      <div className="logo">
        <h1>My dApp</h1>
      </div>
      
      <ConnectButton 
        showBalance={true}
        chainStatus="full"
        accountStatus="full"
      />
    </header>
  );
}
```

### 3.2 Custom Connect Modal

```typescript
// components/WalletModal.tsx
'use client';

import { useConnectModal } from '@rainbow-me/rainbowkit';
import { useAccount, useDisconnect } from 'wagmi';

export function WalletModal() {
  const { openConnectModal } = useConnectModal();
  const { address, isConnected } = useAccount();
  const { disconnect } = useDisconnect();

  if (!isConnected) {
    return (
      <button 
        onClick={openConnectModal}
        className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
      >
        Connect Wallet
      </button>
    );
  }

  return (
    <div className="flex items-center gap-4">
      <div className="text-sm">
        <span className="text-gray-500">Connected:</span>
        <span className="ml-2 font-mono">
          {address?.slice(0, 6)}...{address?.slice(-4)}
        </span>
      </div>
      <button 
        onClick={() => disconnect()}
        className="text-red-500 hover:text-red-700"
      >
        Disconnect
      </button>
    </div>
  );
}
```

### 3.3 Account Management

```typescript
// hooks/useAccountInfo.ts
import { useAccount, useBalance, useEnsName, useEnsAvatar } from 'wagmi';

export function useAccountInfo() {
  const { address, isConnected } = useAccount();
  
  // Get ETH balance
  const { data: balance } = useBalance({
    address,
    query: {
      enabled: isConnected,
    },
  });
  
  // Get ENS name
  const { data: ensName } = useEnsName({
    address,
    chainId: 1, // Mainnet only
  });
  
  // Get ENS avatar
  const { data: ensAvatar } = useEnsAvatar({
    name: ensName ?? undefined,
    chainId: 1,
  });
  
  return {
    address,
    isConnected,
    balance,
    ensName,
    ensAvatar,
    displayName: ensName ?? address?.slice(0, 6) + '...' + address?.slice(-4),
  };
}

// Usage
function UserProfile() {
  const { displayName, balance, ensAvatar } = useAccountInfo();
  
  return (
    <div className="flex items-center gap-3">
      {ensAvatar && (
        <img src={ensAvatar} alt="ENS Avatar" className="w-8 h-8 rounded-full" />
      )}
      <span>{displayName}</span>
      {balance && (
        <span className="text-sm text-gray-500">
          {balance.formatted.slice(0, 4)} {balance.symbol}
        </span>
      )}
    </div>
  );
}
```

---

## Part 4: Smart Contract Interaction

### 4.1 Contract Setup

```typescript
// contracts/abi/ERC20.ts
export const ERC20_ABI = [
  {
    inputs: [{ name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { name: 'to', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    name: 'transfer',
    outputs: [{ type: 'bool' }],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'decimals',
    outputs: [{ type: 'uint8' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

// contracts/index.ts
import { createContract } from 'wagmi';
import { ERC20_ABI } from './abi/ERC20';

export const erc20Contract = {
  address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // USDC
  abi: ERC20_ABI,
} as const;
```

### 4.2 Reading Contract Data

```typescript
// hooks/useTokenBalance.ts
import { useReadContract } from 'wagmi';
import { erc20Contract } from '@/contracts';
import { parseUnits } from 'viem';

export function useTokenBalance(address: `0x${string}` | undefined) {
  const { data: balance, isLoading, error } = useReadContract({
    ...erc20Contract,
    functionName: 'balanceOf',
    args: [address],
    query: {
      enabled: !!address,
      refetchInterval: 5000, // Refetch every 5 seconds
    },
  });
  
  // Get decimals for formatting
  const { data: decimals } = useReadContract({
    ...erc20Contract,
    functionName: 'decimals',
  });
  
  const formattedBalance = balance && decimals 
    ? Number(balance) / Math.pow(10, Number(decimals))
    : 0;
  
  return {
    balance: formattedBalance,
    rawBalance: balance,
    isLoading,
    error,
  };
}

// Usage
function TokenBalance() {
  const { address } = useAccount();
  const { balance, isLoading } = useTokenBalance(address);
  
  if (isLoading) return <span>Loading...</span>;
  
  return <span>{balance?.toFixed(2)} USDC</span>;
}
```

### 4.3 Writing Transactions

```typescript
// hooks/useTransferToken.ts
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { erc20Contract } from '@/contracts';
import { parseUnits } from 'viem';

export function useTransferToken() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });
  
  const transfer = async (to: string, amount: number) => {
    // Get decimals
    const decimals = 6; // USDC has 6 decimals
    
    writeContract({
      ...erc20Contract,
      functionName: 'transfer',
      args: [to as `0x${string}`, parseUnits(amount.toString(), decimals)],
    });
  };
  
  return {
    transfer,
    hash,
    isPending,
    isConfirming,
    isSuccess,
  };
}

// Usage
function TransferForm() {
  const [to, setTo] = useState('');
  const [amount, setAmount] = useState('');
  const { transfer, isPending, isConfirming, isSuccess } = useTransferToken();
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await transfer(to, parseFloat(amount));
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input 
        type="text" 
        value={to}
        onChange={(e) => setTo(e.target.value)}
        placeholder="Recipient address"
      />
      <input 
        type="number" 
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="Amount"
      />
      <button type="submit" disabled={isPending || isConfirming}>
        {isPending ? 'Sign in wallet...' : isConfirming ? 'Confirming...' : 'Transfer'}
      </button>
      
      {isSuccess && (
        <p className="text-green-500">Transfer successful!</p>
      )}
    </form>
  );
}
```

---

## Part 5: Advanced Patterns

### 5.1 Multicall (Batch Reads)

```typescript
// hooks/useTokenData.ts
import { useReadContracts } from 'wagmi';
import { erc20Contract } from '@/contracts';

export function useTokenData(tokenAddresses: `0x${string}`[]) {
  const { data, isLoading } = useReadContracts({
    contracts: tokenAddresses.flatMap(address => [
      {
        ...erc20Contract,
        address,
        functionName: 'name',
      },
      {
        ...erc20Contract,
        address,
        functionName: 'symbol',
      },
      {
        ...erc20Contract,
        address,
        functionName: 'decimals',
      },
      {
        ...erc20Contract,
        address,
        functionName: 'totalSupply',
      },
    ]),
  });
  
  // Group results by token
  const tokens = tokenAddresses.map((address, index) => ({
    address,
    name: data?.[index * 4]?.result,
    symbol: data?.[index * 4 + 1]?.result,
    decimals: data?.[index * 4 + 2]?.result,
    totalSupply: data?.[index * 4 + 3]?.result,
  }));
  
  return { tokens, isLoading };
}
```

### 5.2 Event Listening

```typescript
// hooks/useTransferEvents.ts
import { useWatchContractEvent } from 'wagmi';
import { erc20Contract } from '@/contracts';

export function useTransferEvents(onTransfer: (event: any) => void) {
  useWatchContractEvent({
    ...erc20Contract,
    eventName: 'Transfer',
    args: {
      from: undefined, // Listen to all transfers
      to: undefined,
    },
    onLogs: (logs) => {
      logs.forEach((log) => {
        onTransfer({
          from: log.args.from,
          to: log.args.to,
          value: log.args.value,
          blockNumber: log.blockNumber,
          transactionHash: log.transactionHash,
        });
      });
    },
  });
}

// Usage
function TransferMonitor() {
  const [transfers, setTransfers] = useState([]);
  
  useTransferEvents((event) => {
    setTransfers((prev) => [event, ...prev].slice(0, 10));
  });
  
  return (
    <div>
      <h3>Recent Transfers</h3>
      {transfers.map((tx, i) => (
        <div key={i}>
          {tx.from?.slice(0, 6)}... → {tx.to?.slice(0, 6)}... : {tx.value.toString()}
        </div>
      ))}
    </div>
  );
}
```

### 5.3 Switch Network

```typescript
// hooks/useSwitchNetwork.ts
import { useSwitchChain, useChainId } from 'wagmi';
import { mainnet, polygon, arbitrum } from 'wagmi/chains';

export function useSwitchNetwork() {
  const chainId = useChainId();
  const { switchChain } = useSwitchChain();
  
  const switchToMainnet = () => switchChain({ chainId: mainnet.id });
  const switchToPolygon = () => switchChain({ chainId: polygon.id });
  const switchToArbitrum = () => switchChain({ chainId: arbitrum.id });
  
  return {
    currentChainId: chainId,
    switchToMainnet,
    switchToPolygon,
    switchToArbitrum,
  };
}

// Usage
function NetworkSelector() {
  const { currentChainId, switchToMainnet, switchToPolygon } = useSwitchNetwork();
  
  return (
    <div className="flex gap-2">
      <button 
        onClick={switchToMainnet}
        className={currentChainId === 1 ? 'active' : ''}
      >
        Ethereum
      </button>
      <button 
        onClick={switchToPolygon}
        className={currentChainId === 137 ? 'active' : ''}
      >
        Polygon
      </button>
    </div>
  );
}
```

---

## Part 6: ethers.js Alternative

### 6.1 ethers.js Setup

```typescript
// lib/ethers.ts
import { ethers } from 'ethers';

// Connect to provider
export function getProvider() {
  if (typeof window !== 'undefined' && window.ethereum) {
    return new ethers.BrowserProvider(window.ethereum);
  }
  // Fallback to public RPC
  return new ethers.JsonRpcProvider(process.env.NEXT_PUBLIC_RPC_URL);
}

// Get signer
export async function getSigner() {
  const provider = getProvider();
  await provider.send('eth_requestAccounts', []);
  return provider.getSigner();
}

// Contract instance
export function getContract(address: string, abi: any[], signer?: any) {
  const provider = getProvider();
  return new ethers.Contract(address, abi, signer || provider);
}
```

### 6.2 Contract Interaction with ethers.js

```typescript
// hooks/useEthersTransfer.ts
import { useState } from 'react';
import { getSigner, getContract } from '@/lib/ethers';
import { ERC20_ABI } from '@/contracts/abi/ERC20';

export function useEthersTransfer() {
  const [isPending, setIsPending] = useState(false);
  const [isConfirming, setIsConfirming] = useState(false);
  const [txHash, setTxHash] = useState('');
  
  const transfer = async (to: string, amount: number) => {
    try {
      setIsPending(true);
      
      const signer = await getSigner();
      const contract = getContract(USDC_ADDRESS, ERC20_ABI, signer);
      
      const decimals = 6;
      const amountWei = ethers.parseUnits(amount.toString(), decimals);
      
      const tx = await contract.transfer(to, amountWei);
      setTxHash(tx.hash);
      setIsPending(false);
      setIsConfirming(true);
      
      await tx.wait();
      setIsConfirming(false);
      
      return { success: true, hash: tx.hash };
    } catch (error) {
      console.error('Transfer failed:', error);
      setIsPending(false);
      return { success: false, error };
    }
  };
  
  return { transfer, isPending, isConfirming, txHash };
}
```

---

## Best Practices

### ✅ Do This

- ✅ Use wagmi + viem for new React projects
- ✅ Implement proper error handling for failed transactions
- ✅ Show transaction status (pending, confirming, success)
- ✅ Use ENS names when available
- ✅ Support multiple chains with proper network switching
- ✅ Handle wallet connection states gracefully
- ✅ Use TypeScript for type safety

### ❌ Avoid This

- ❌ Hardcoding contract addresses without verification
- ❌ Not handling network switching
- ❌ Ignoring transaction failures
- ❌ Not showing loading states
- ❌ Storing private keys in frontend code
- ❌ Not validating user input before sending transactions

---

## Related Skills

- `@senior-web3-developer` - Full-stack Web3 development
- `@expert-web3-blockchain` - Blockchain architecture
- `@smart-contract-developer` - Smart contract development
- `@nft-developer` - NFT-specific patterns
- `@senior-react-developer` - React development
