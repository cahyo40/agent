---
name: dapp-mobile-developer
description: "Expert dApp mobile development combining Flutter with Web3 including WalletConnect, Web3Dart, token/NFT display, and secure key management"
---

# dApp Mobile Developer

## Overview

This skill helps you build production-ready decentralized mobile applications using Flutter and Web3 technologies. You'll integrate wallet connections, interact with smart contracts, display tokens/NFTs, and implement secure key management.

## When to Use This Skill

- Use when building mobile crypto wallets
- Use when integrating WalletConnect into Flutter apps
- Use when displaying tokens, NFTs, or DeFi data
- Use when implementing Sign-In with Ethereum (SIWE)
- Use when managing secure key storage on mobile
- Use when building mobile trading or portfolio apps

## How It Works

### Step 1: dApp Mobile Architecture

```text
lib/
├── core/
│   ├── blockchain/
│   │   ├── chains.dart           # Chain configurations
│   │   ├── contracts/            # ABI & contract addresses
│   │   └── web3_client.dart      # Web3 client singleton
│   ├── wallet/
│   │   ├── wallet_connect.dart   # WalletConnect integration
│   │   ├── wallet_provider.dart  # Riverpod provider
│   │   └── secure_storage.dart   # Encrypted key storage
│   └── di/
│       └── injection.dart
├── features/
│   ├── auth/                     # SIWE authentication
│   ├── portfolio/                # Token balances
│   ├── nft_gallery/              # NFT display
│   └── swap/                     # DEX integration
└── shared/
    ├── utils/
    │   ├── formatters.dart       # Wei/Ether conversion
    │   └── address_utils.dart    # Address validation
    └── widgets/
        ├── connect_button.dart
        └── token_card.dart
```

### Step 2: Essential Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Web3
  web3dart: ^2.7.3
  walletconnect_flutter_v2: ^2.3.0
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # HTTP & Utils
  http: ^1.1.0
  convert: ^3.1.1
  intl: ^0.19.0
  
  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

dev_dependencies:
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

### Step 3: Chain Configuration

```dart
// lib/core/blockchain/chains.dart

enum ChainId {
  ethereum(1),
  polygon(137),
  arbitrum(42161),
  optimism(10),
  base(8453),
  sepolia(11155111);

  const ChainId(this.value);
  final int value;
}

class ChainConfig {
  final ChainId chainId;
  final String name;
  final String symbol;
  final String rpcUrl;
  final String explorerUrl;
  final String? iconUrl;

  const ChainConfig({
    required this.chainId,
    required this.name,
    required this.symbol,
    required this.rpcUrl,
    required this.explorerUrl,
    this.iconUrl,
  });

  static const ethereum = ChainConfig(
    chainId: ChainId.ethereum,
    name: 'Ethereum',
    symbol: 'ETH',
    rpcUrl: 'https://eth.llamarpc.com',
    explorerUrl: 'https://etherscan.io',
  );

  static const polygon = ChainConfig(
    chainId: ChainId.polygon,
    name: 'Polygon',
    symbol: 'MATIC',
    rpcUrl: 'https://polygon-rpc.com',
    explorerUrl: 'https://polygonscan.com',
  );

  static const base = ChainConfig(
    chainId: ChainId.base,
    name: 'Base',
    symbol: 'ETH',
    rpcUrl: 'https://mainnet.base.org',
    explorerUrl: 'https://basescan.org',
  );

  static const List<ChainConfig> supported = [ethereum, polygon, base];
}
```

### Step 4: Web3 Client

```dart
// lib/core/blockchain/web3_client.dart

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Web3ClientService {
  Web3ClientService._();
  static final instance = Web3ClientService._();

  final Map<ChainId, Web3Client> _clients = {};

  Web3Client getClient(ChainConfig chain) {
    return _clients.putIfAbsent(
      chain.chainId,
      () => Web3Client(chain.rpcUrl, Client()),
    );
  }

  Future<EtherAmount> getBalance(
    ChainConfig chain,
    EthereumAddress address,
  ) async {
    final client = getClient(chain);
    return client.getBalance(address);
  }

  Future<BigInt> getTokenBalance(
    ChainConfig chain,
    EthereumAddress tokenAddress,
    EthereumAddress walletAddress,
  ) async {
    final client = getClient(chain);
    final contract = DeployedContract(
      ContractAbi.fromJson(_erc20Abi, 'ERC20'),
      tokenAddress,
    );
    
    final balanceFunc = contract.function('balanceOf');
    final result = await client.call(
      contract: contract,
      function: balanceFunc,
      params: [walletAddress],
    );
    
    return result.first as BigInt;
  }

  static const _erc20Abi = '''
  [
    {
      "constant": true,
      "inputs": [{"name": "_owner", "type": "address"}],
      "name": "balanceOf",
      "outputs": [{"name": "balance", "type": "uint256"}],
      "type": "function"
    }
  ]
  ''';
}
```

### Step 5: WalletConnect Integration

```dart
// lib/core/wallet/wallet_connect.dart

import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectService {
  WalletConnectService._();
  static final instance = WalletConnectService._();

  Web3App? _web3App;
  SessionData? _session;

  String? get connectedAddress {
    if (_session == null) return null;
    final accounts = _session!.namespaces['eip155']?.accounts;
    if (accounts == null || accounts.isEmpty) return null;
    // Format: eip155:1:0x123...
    return accounts.first.split(':').last;
  }

  bool get isConnected => _session != null;

  Future<void> initialize({required String projectId}) async {
    _web3App = await Web3App.createInstance(
      projectId: projectId,
      metadata: const PairingMetadata(
        name: 'My dApp',
        description: 'A decentralized mobile application',
        url: 'https://mydapp.com',
        icons: ['https://mydapp.com/icon.png'],
      ),
    );

    // Listen for session events
    _web3App!.onSessionConnect.subscribe((args) {
      _session = args?.session;
    });

    _web3App!.onSessionDelete.subscribe((args) {
      _session = null;
    });

    // Restore existing session
    final sessions = _web3App!.sessions.getAll();
    if (sessions.isNotEmpty) {
      _session = sessions.first;
    }
  }

  Future<Uri> connect() async {
    final connectResponse = await _web3App!.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          chains: ['eip155:1', 'eip155:137', 'eip155:8453'],
          methods: [
            'eth_sendTransaction',
            'eth_signTransaction',
            'eth_sign',
            'personal_sign',
            'eth_signTypedData',
          ],
          events: ['chainChanged', 'accountsChanged'],
        ),
      },
    );

    return connectResponse.uri!;
  }

  Future<void> disconnect() async {
    if (_session != null) {
      await _web3App!.disconnectSession(
        topic: _session!.topic,
        reason: const WalletConnectError(
          code: 6000,
          message: 'User disconnected',
        ),
      );
      _session = null;
    }
  }

  Future<String> signMessage(String message) async {
    if (_session == null || connectedAddress == null) {
      throw Exception('Wallet not connected');
    }

    final result = await _web3App!.request(
      topic: _session!.topic,
      chainId: 'eip155:1',
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [message, connectedAddress],
      ),
    );

    return result as String;
  }

  Future<String> sendTransaction({
    required String to,
    required BigInt value,
    String? data,
  }) async {
    if (_session == null || connectedAddress == null) {
      throw Exception('Wallet not connected');
    }

    final tx = {
      'from': connectedAddress,
      'to': to,
      'value': '0x${value.toRadixString(16)}',
      if (data != null) 'data': data,
    };

    final result = await _web3App!.request(
      topic: _session!.topic,
      chainId: 'eip155:1',
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        params: [tx],
      ),
    );

    return result as String;
  }
}
```

### Step 6: Riverpod State Management

```dart
// lib/core/wallet/wallet_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_provider.g.dart';

@freezed
class WalletState with _$WalletState {
  const factory WalletState({
    @Default(false) bool isConnecting,
    @Default(false) bool isConnected,
    String? address,
    String? error,
    ChainConfig? activeChain,
  }) = _WalletState;
}

@riverpod
class WalletController extends _$WalletController {
  @override
  WalletState build() {
    _initialize();
    return const WalletState();
  }

  Future<void> _initialize() async {
    await WalletConnectService.instance.initialize(
      projectId: const String.fromEnvironment('WC_PROJECT_ID'),
    );
    
    if (WalletConnectService.instance.isConnected) {
      state = state.copyWith(
        isConnected: true,
        address: WalletConnectService.instance.connectedAddress,
        activeChain: ChainConfig.ethereum,
      );
    }
  }

  Future<Uri?> connect() async {
    state = state.copyWith(isConnecting: true, error: null);
    
    try {
      final uri = await WalletConnectService.instance.connect();
      return uri;
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void onConnected(String address) {
    state = state.copyWith(
      isConnecting: false,
      isConnected: true,
      address: address,
      activeChain: ChainConfig.ethereum,
    );
  }

  Future<void> disconnect() async {
    await WalletConnectService.instance.disconnect();
    state = const WalletState();
  }

  void switchChain(ChainConfig chain) {
    state = state.copyWith(activeChain: chain);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Token Balance Provider
// ════════════════════════════════════════════════════════════════════════════

@riverpod
Future<String> nativeBalance(NativeBalanceRef ref) async {
  final wallet = ref.watch(walletControllerProvider);
  
  if (!wallet.isConnected || wallet.address == null || wallet.activeChain == null) {
    return '0';
  }
  
  final balance = await Web3ClientService.instance.getBalance(
    wallet.activeChain!,
    EthereumAddress.fromHex(wallet.address!),
  );
  
  return balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
}
```

### Step 7: Connect Wallet UI

```dart
// lib/shared/widgets/connect_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectWalletButton extends ConsumerWidget {
  const ConnectWalletButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletControllerProvider);

    if (wallet.isConnected) {
      return _ConnectedButton(
        address: wallet.address!,
        onDisconnect: () => ref.read(walletControllerProvider.notifier).disconnect(),
      );
    }

    return ElevatedButton.icon(
      onPressed: wallet.isConnecting
          ? null
          : () => _connect(context, ref),
      icon: wallet.isConnecting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.account_balance_wallet),
      label: Text(wallet.isConnecting ? 'Connecting...' : 'Connect Wallet'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    final uri = await ref.read(walletControllerProvider.notifier).connect();
    
    if (uri != null) {
      // Open wallet app or show QR code
      final wcUri = 'wc:${uri.toString().split('wc:').last}';
      
      if (await canLaunchUrl(Uri.parse(wcUri))) {
        await launchUrl(Uri.parse(wcUri), mode: LaunchMode.externalApplication);
      } else {
        // Show QR code dialog
        if (context.mounted) {
          _showQRDialog(context, uri.toString());
        }
      }
    }
  }

  void _showQRDialog(BuildContext context, String uri) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan with Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Use qr_flutter or similar package
            Container(
              width: 250,
              height: 250,
              color: Colors.grey[200],
              child: const Center(child: Text('QR Code')),
            ),
            const SizedBox(height: 16),
            SelectableText(
              uri,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ConnectedButton extends StatelessWidget {
  const _ConnectedButton({
    required this.address,
    required this.onDisconnect,
  });

  final String address;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${address.substring(0, 6)}...${address.substring(address.length - 4)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout, size: 18),
            onPressed: onDisconnect,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
```

### Step 8: Sign-In with Ethereum (SIWE)

```dart
// lib/features/auth/siwe_service.dart

import 'dart:math';

class SIWEService {
  /// Generate SIWE message
  String generateMessage({
    required String address,
    required String domain,
    required String uri,
    required int chainId,
    String? statement,
  }) {
    final nonce = _generateNonce();
    final issuedAt = DateTime.now().toUtc().toIso8601String();
    
    return '''
$domain wants you to sign in with your Ethereum account:
$address

${statement ?? 'Sign in to $domain'}

URI: $uri
Version: 1
Chain ID: $chainId
Nonce: $nonce
Issued At: $issuedAt
''';
  }

  String _generateNonce() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Verify signature on backend
  Future<bool> verifySignature({
    required String message,
    required String signature,
    required String address,
  }) async {
    // Send to backend for verification
    // Backend should use viem/ethers.js to recover address
    // and validate message format/nonce
    
    // Example API call:
    // final response = await dio.post('/auth/verify', data: {
    //   'message': message,
    //   'signature': signature,
    //   'address': address,
    // });
    // return response.data['valid'] == true;
    
    return true; // Placeholder
  }
}

// Usage in auth flow
Future<void> signIn(WidgetRef ref) async {
  final walletService = WalletConnectService.instance;
  final address = walletService.connectedAddress;
  if (address == null) return;

  final siwe = SIWEService();
  final message = siwe.generateMessage(
    address: address,
    domain: 'mydapp.com',
    uri: 'https://mydapp.com',
    chainId: 1,
    statement: 'Sign in to access your portfolio',
  );

  final signature = await walletService.signMessage(message);
  
  final isValid = await siwe.verifySignature(
    message: message,
    signature: signature,
    address: address,
  );

  if (isValid) {
    // Proceed with authenticated session
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Use WalletConnect v2 for wallet connections
- ✅ Store sensitive data in flutter_secure_storage
- ✅ Validate addresses before transactions
- ✅ Show transaction previews before signing
- ✅ Handle network switching gracefully
- ✅ Cache token metadata and images
- ✅ Implement proper error handling for RPC calls
- ✅ Use environment variables for API keys

### ❌ Avoid This

- ❌ Don't store private keys in plain text
- ❌ Don't hardcode RPC URLs without fallbacks
- ❌ Don't skip transaction confirmation UI
- ❌ Don't ignore chain ID validation
- ❌ Don't make RPC calls on main thread
- ❌ Don't trust client-side signature verification alone

## Security Checklist

```markdown
### Key Management
- [ ] Private keys stored in secure enclave
- [ ] Biometric authentication for signing
- [ ] Session timeout implemented
- [ ] No keys logged or transmitted

### Transaction Safety
- [ ] Amount/recipient shown before signing
- [ ] Contract interaction decoded for user
- [ ] Simulation before actual transaction
- [ ] Slippage protection for swaps

### Network Security
- [ ] Certificate pinning enabled
- [ ] API keys stored securely
- [ ] Request signing implemented
- [ ] Rate limiting handled
```

## Related Skills

- `@senior-flutter-developer` - Core Flutter development
- `@senior-web3-developer` - Smart contract development
- `@senior-firebase-developer` - Backend for auth/data
