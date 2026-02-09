---
name: dapp-mobile-developer
description: "Expert dApp mobile development combining Flutter with Web3 including WalletConnect, Web3Dart, token/NFT display, and secure key management"
---

# dApp Mobile Developer

## Overview

Build production-ready mobile decentralized applications combining Flutter with Web3 technologies. This skill covers WalletConnect V2 integration, smart contract interaction, HD wallet creation, and secure key management for iOS and Android.

## When to Use This Skill

- Use when building mobile dApps with Flutter
- Use when integrating WalletConnect V2
- Use when displaying tokens and NFTs
- Use when implementing in-app wallet features
- Use when building DeFi mobile interfaces

## Templates Reference

| Template | Description |
| -------- | ----------- |
| [web3-service.md](templates/web3-service.md) | Web3Dart client and transaction signing |
| [walletconnect-v2.md](templates/walletconnect-v2.md) | WalletConnect V2 integration |
| [hd-wallet.md](templates/hd-wallet.md) | HD wallet creation and key derivation |
| [nft-display.md](templates/nft-display.md) | NFT fetching and display |

## How It Works

### Step 1: Project Setup

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Web3
  web3dart: ^2.7.3
  walletconnect_flutter_v2: ^2.3.0
  
  # Wallet
  bip39: ^1.0.6
  bip32: ^2.0.0
  hex: ^0.2.0
  
  # Security
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.1.6
  
  # Networking
  http: ^1.2.0
  dio: ^5.4.0
```

### Step 2: Architecture Overview

```text
lib/
├── core/
│   ├── services/
│   │   ├── web3_service.dart      # Blockchain interaction
│   │   ├── wallet_service.dart    # Key management
│   │   └── walletconnect_service.dart
│   └── models/
│       ├── wallet.dart
│       ├── token.dart
│       └── nft.dart
├── features/
│   ├── wallet/
│   ├── send/
│   ├── nft/
│   └── dapp_browser/
└── main.dart
```

### Step 3: Key Management

Always use secure storage with biometric protection:

```dart
class WalletStorage {
  final FlutterSecureStorage _storage;
  
  Future<void> saveMnemonic(String mnemonic) async {
    await _storage.write(
      key: 'mnemonic',
      value: mnemonic,
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }
}
```

See [templates/hd-wallet.md](templates/hd-wallet.md) for complete implementation.

### Step 4: WalletConnect V2

```dart
// Initialize WalletConnect
final web3App = await Web3App.createInstance(
  projectId: 'YOUR_PROJECT_ID',
  metadata: PairingMetadata(
    name: 'My dApp',
    description: 'Mobile dApp',
    url: 'https://myapp.com',
    icons: ['https://myapp.com/icon.png'],
  ),
);
```

See [templates/walletconnect-v2.md](templates/walletconnect-v2.md) for session management.

## Best Practices

### ✅ Do This

- ✅ Use `flutter_secure_storage` for private keys
- ✅ Require biometric auth before signing
- ✅ Support WalletConnect for external wallets
- ✅ Cache blockchain data with proper invalidation
- ✅ Show clear transaction confirmations
- ✅ Use EIP-1559 gas estimation

### ❌ Avoid This

- ❌ Don't store keys in SharedPreferences
- ❌ Don't hardcode RPC URLs in source
- ❌ Don't skip transaction simulation
- ❌ Don't ignore chain ID verification
- ❌ Don't auto-sign without user confirmation

## Common Pitfalls

**Problem:** Transaction fails with "insufficient funds"
**Solution:** Include gas cost in balance check, use proper gas estimation

**Problem:** WalletConnect session disconnects
**Solution:** Implement session persistence and reconnection logic

**Problem:** NFT images don't load
**Solution:** Handle IPFS URLs, convert to HTTP gateway

## Related Skills

- `@senior-flutter-developer` - Flutter architecture
- `@senior-web3-developer` - Smart contracts
- `@crypto-wallet-developer` - Wallet development
