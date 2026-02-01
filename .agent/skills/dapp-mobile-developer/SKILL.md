---
name: dapp-mobile-developer
description: "Expert dApp mobile development combining Flutter with Web3 including WalletConnect, Web3Dart, token/NFT display, and secure key management"
---

# dApp Mobile Developer

## Overview

Build mobile decentralized applications combining Flutter with Web3 technologies including WalletConnect, smart contract interaction, and secure key management.

## When to Use This Skill

- Use when building mobile dApps
- Use when integrating WalletConnect
- Use when displaying tokens/NFTs
- Use when implementing wallet features

## How It Works

### Step 1: Web3 Flutter Setup

```yaml
# pubspec.yaml
dependencies:
  web3dart: ^2.7.1
  walletconnect_flutter_v2: ^2.1.0
  http: ^1.1.0
  bip39: ^1.0.6
  ed25519_hd_key: ^2.2.0
  hex: ^0.2.0
```

```dart
// Web3 Service
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class Web3Service {
  late Web3Client _client;
  final String rpcUrl = 'https://mainnet.infura.io/v3/YOUR_KEY';
  
  Web3Service() {
    _client = Web3Client(rpcUrl, Client());
  }
  
  Future<EtherAmount> getBalance(String address) async {
    final addr = EthereumAddress.fromHex(address);
    return await _client.getBalance(addr);
  }
  
  Future<String> sendTransaction({
    required Credentials credentials,
    required String to,
    required BigInt value,
  }) async {
    final tx = await _client.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(to),
        value: EtherAmount.inWei(value),
      ),
      chainId: 1,
    );
    return tx;
  }
}
```

### Step 2: WalletConnect Integration

```dart
// WalletConnect V2 Setup
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectService {
  late Web3App _web3App;
  SessionData? _session;
  
  Future<void> init() async {
    _web3App = await Web3App.createInstance(
      projectId: 'YOUR_PROJECT_ID',
      metadata: const PairingMetadata(
        name: 'My dApp',
        description: 'My mobile dApp',
        url: 'https://myapp.com',
        icons: ['https://myapp.com/icon.png'],
      ),
    );
  }
  
  Future<String> connect() async {
    final connectResponse = await _web3App.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          chains: ['eip155:1', 'eip155:137'],
          methods: ['eth_sendTransaction', 'personal_sign'],
          events: ['chainChanged', 'accountsChanged'],
        ),
      },
    );
    
    // Return URI for QR code
    return connectResponse.uri.toString();
  }
}
```

### Step 3: NFT Display

```dart
// NFT Model & Fetching
class NFT {
  final String tokenId;
  final String name;
  final String imageUrl;
  final String contractAddress;
  
  NFT({...});
  
  factory NFT.fromMetadata(Map<String, dynamic> json) {...}
}

Future<List<NFT>> fetchNFTs(String address) async {
  final response = await http.get(Uri.parse(
    'https://api.opensea.io/v2/chain/ethereum/account/$address/nfts'
  ));
  // Parse and return NFTs
}

// NFT Grid Widget
class NFTGridView extends StatelessWidget {
  final List<NFT> nfts;
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
      ),
      itemCount: nfts.length,
      itemBuilder: (context, index) => NFTCard(nft: nfts[index]),
    );
  }
}
```

### Step 4: Secure Key Management

```dart
// Secure Storage for Keys
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WalletStorage {
  final _storage = FlutterSecureStorage();
  
  Future<void> saveMnemonic(String mnemonic) async {
    await _storage.write(
      key: 'mnemonic',
      value: mnemonic,
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
  }
  
  Future<Credentials> getCredentials() async {
    final mnemonic = await _storage.read(key: 'mnemonic');
    if (mnemonic == null) throw Exception('No wallet');
    
    final seed = bip39.mnemonicToSeed(mnemonic);
    final privateKey = _derivePrivateKey(seed);
    return EthPrivateKey.fromHex(privateKey);
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Use FlutterSecureStorage for keys
- ✅ Support WalletConnect for external wallets
- ✅ Cache blockchain data locally
- ✅ Handle network errors gracefully
- ✅ Show transaction confirmations

### ❌ Avoid This

- ❌ Don't store keys in plain text
- ❌ Don't hardcode RPC URLs
- ❌ Don't skip transaction confirmations
- ❌ Don't ignore gas estimation

## Related Skills

- `@senior-flutter-developer` - Flutter development
- `@senior-web3-developer` - Web3 development
