---
name: crypto-wallet-developer
description: "Expert cryptocurrency wallet development including key management, multi-chain support, transaction signing, and secure storage"
---

# Crypto Wallet Developer

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis pengembangan cryptocurrency wallet. Agent akan mampu membangun fitur key generation, secure storage, transaction signing, multi-chain support, dan integrasi dengan berbagai blockchain networks.

## When to Use This Skill

- Use when building cryptocurrency wallet applications
- Use when implementing secure key management
- Use when the user asks about wallet architecture
- Use when integrating with multiple blockchain networks
- Use when implementing transaction signing and broadcasting

## How It Works

### Step 1: Wallet Architecture

```text
┌─────────────────────────────────────────────────────────┐
│              CRYPTO WALLET ARCHITECTURE                 │
├─────────────────────────────────────────────────────────┤
│ 🔑 Key Management    - HD wallets, BIP39/44/84          │
│ 🔐 Secure Storage    - Keychain, Secure Enclave, HSM    │
│ ⛓️ Multi-Chain       - EVM, Bitcoin, Solana, etc.       │
│ ✍️ Tx Signing        - Sign transactions locally        │
│ 📡 Broadcasting      - Submit to blockchain network     │
│ 💱 Token Support     - ERC20, SPL, native tokens        │
│ 🔄 WalletConnect     - dApp integration                 │
└─────────────────────────────────────────────────────────┘
```

### Step 2: HD Wallet Generation (BIP39/44)

```dart
// Using web3dart + bip39 packages
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';

class HDWalletService {
  // Generate new mnemonic
  String generateMnemonic() {
    return bip39.generateMnemonic(strength: 256); // 24 words
  }
  
  // Validate mnemonic
  bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }
  
  // Derive Ethereum wallet from mnemonic
  EthereumWallet deriveEthereumWallet(String mnemonic, int index) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    
    // BIP44 path for Ethereum: m/44'/60'/0'/0/index
    final child = root.derivePath("m/44'/60'/0'/0/$index");
    
    final privateKey = EthPrivateKey.fromHex(
      child.privateKey!.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    );
    
    return EthereumWallet(
      address: privateKey.address.hex,
      privateKey: privateKey,
      path: "m/44'/60'/0'/0/$index",
      index: index,
    );
  }
  
  // Derive Bitcoin wallet
  BitcoinWallet deriveBitcoinWallet(String mnemonic, int index) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    
    // BIP84 path for Native SegWit: m/84'/0'/0'/0/index
    final child = root.derivePath("m/84'/0'/0'/0/$index");
    
    return BitcoinWallet(
      publicKey: child.publicKey,
      privateKey: child.privateKey!,
      path: "m/84'/0'/0'/0/$index",
      index: index,
    );
  }
}
```

### Step 3: Secure Key Storage

```dart
// Secure storage using flutter_secure_storage + encryption
class SecureKeyStorage {
  final FlutterSecureStorage _storage;
  final _encryptionKey = 'wallet_encryption_key';
  
  // Store encrypted mnemonic
  Future<void> storeMnemonic(String mnemonic, String password) async {
    // Derive encryption key from password
    final salt = _generateSalt();
    final key = await _deriveKey(password, salt);
    
    // Encrypt mnemonic with AES-256-GCM
    final encrypted = await _encrypt(mnemonic, key);
    
    await _storage.write(key: 'mnemonic_encrypted', value: encrypted);
    await _storage.write(key: 'mnemonic_salt', value: salt);
  }
  
  // Retrieve and decrypt mnemonic
  Future<String?> retrieveMnemonic(String password) async {
    final encrypted = await _storage.read(key: 'mnemonic_encrypted');
    final salt = await _storage.read(key: 'mnemonic_salt');
    
    if (encrypted == null || salt == null) return null;
    
    try {
      final key = await _deriveKey(password, salt);
      return await _decrypt(encrypted, key);
    } catch (e) {
      throw WrongPasswordException();
    }
  }
  
  // Use biometric for quick unlock
  Future<bool> authenticateWithBiometric() async {
    final localAuth = LocalAuthentication();
    return await localAuth.authenticate(
      localizedReason: 'Authenticate to access wallet',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }
  
  // Secure key derivation
  Future<Uint8List> _deriveKey(String password, String salt) async {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(
        utf8.encode(salt) as Uint8List,
        100000, // iterations
        32, // key length
      ));
    return pbkdf2.process(utf8.encode(password) as Uint8List);
  }
}
```

### Step 4: Transaction Signing

```dart
class TransactionService {
  final Web3Client _web3client;
  
  // Sign and send Ethereum transaction
  Future<String> sendTransaction({
    required EthPrivateKey privateKey,
    required String to,
    required BigInt value,
    BigInt? gasPrice,
    int? gasLimit,
    Uint8List? data,
  }) async {
    final credentials = privateKey;
    final chainId = await _web3client.getChainId();
    
    // Estimate gas if not provided
    gasLimit ??= (await _web3client.estimateGas(
      sender: credentials.address,
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.inWei(value),
      data: data,
    )).toInt();
    
    // Get current gas price if not provided
    gasPrice ??= (await _web3client.getGasPrice()).getInWei;
    
    // Build transaction
    final transaction = Transaction(
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.inWei(value),
      gasPrice: EtherAmount.inWei(gasPrice),
      maxGas: gasLimit,
      data: data,
    );
    
    // Sign and send
    final txHash = await _web3client.sendTransaction(
      credentials,
      transaction,
      chainId: chainId.toInt(),
    );
    
    return txHash;
  }
  
  // Sign ERC20 token transfer
  Future<String> sendERC20Token({
    required EthPrivateKey privateKey,
    required String tokenAddress,
    required String to,
    required BigInt amount,
  }) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(_erc20Abi, 'ERC20'),
      EthereumAddress.fromHex(tokenAddress),
    );
    
    final transferFunction = contract.function('transfer');
    final data = transferFunction.encodeCall([
      EthereumAddress.fromHex(to),
      amount,
    ]);
    
    return sendTransaction(
      privateKey: privateKey,
      to: tokenAddress,
      value: BigInt.zero,
      data: data,
    );
  }
  
  // Sign message (EIP-191)
  Uint8List signMessage(String message, EthPrivateKey privateKey) {
    final messageBytes = utf8.encode(message);
    final prefix = '\x19Ethereum Signed Message:\n${messageBytes.length}';
    final prefixedMessage = utf8.encode(prefix) + messageBytes;
    
    final hash = keccak256(Uint8List.fromList(prefixedMessage));
    return privateKey.signPersonalMessageToUint8List(
      Uint8List.fromList(messageBytes),
    );
  }
}
```

### Step 5: WalletConnect Integration

```dart
// WalletConnect v2 integration
class WalletConnectService {
  late Web3Wallet _web3wallet;
  
  Future<void> initialize() async {
    _web3wallet = await Web3Wallet.createInstance(
      projectId: 'YOUR_PROJECT_ID',
      metadata: const PairingMetadata(
        name: 'My Crypto Wallet',
        description: 'A secure cryptocurrency wallet',
        url: 'https://mywallet.app',
        icons: ['https://mywallet.app/icon.png'],
      ),
    );
    
    // Handle session proposals
    _web3wallet.onSessionProposal.subscribe((proposal) async {
      // Show approval dialog to user
      final approved = await _showApprovalDialog(proposal);
      
      if (approved) {
        await _web3wallet.approveSession(
          id: proposal.id,
          namespaces: _buildNamespaces(proposal),
        );
      } else {
        await _web3wallet.rejectSession(
          id: proposal.id,
          reason: Errors.getSdkError(Errors.USER_REJECTED),
        );
      }
    });
    
    // Handle sign requests
    _web3wallet.onSessionRequest.subscribe((request) async {
      switch (request.method) {
        case 'eth_sendTransaction':
          await _handleSendTransaction(request);
          break;
        case 'personal_sign':
          await _handlePersonalSign(request);
          break;
        case 'eth_signTypedData':
          await _handleSignTypedData(request);
          break;
      }
    });
  }
  
  // Pair with dApp
  Future<void> pair(String uri) async {
    await _web3wallet.pair(uri: Uri.parse(uri));
  }
  
  // Handle send transaction request
  Future<void> _handleSendTransaction(SessionRequest request) async {
    final params = request.params[0] as Map<String, dynamic>;
    
    // Show confirmation dialog
    final confirmed = await _showTransactionDialog(params);
    
    if (confirmed) {
      final txHash = await _transactionService.sendTransaction(
        privateKey: _wallet.privateKey,
        to: params['to'],
        value: BigInt.parse(params['value'] ?? '0'),
        data: params['data'] != null 
          ? hexToBytes(params['data']) 
          : null,
      );
      
      await _web3wallet.respondSessionRequest(
        topic: request.topic,
        response: JsonRpcResponse(id: request.id, result: txHash),
      );
    } else {
      await _web3wallet.respondSessionRequest(
        topic: request.topic,
        response: JsonRpcResponse(
          id: request.id,
          error: const JsonRpcError(code: 4001, message: 'User rejected'),
        ),
      );
    }
  }
}
```

### Step 6: Multi-Chain Support

```dart
// Chain configuration
class ChainConfig {
  static const chains = {
    'ethereum': ChainInfo(
      chainId: 1,
      name: 'Ethereum Mainnet',
      symbol: 'ETH',
      rpcUrl: 'https://mainnet.infura.io/v3/YOUR_KEY',
      explorerUrl: 'https://etherscan.io',
      derivationPath: "m/44'/60'/0'/0",
    ),
    'polygon': ChainInfo(
      chainId: 137,
      name: 'Polygon',
      symbol: 'MATIC',
      rpcUrl: 'https://polygon-rpc.com',
      explorerUrl: 'https://polygonscan.com',
      derivationPath: "m/44'/60'/0'/0",
    ),
    'bsc': ChainInfo(
      chainId: 56,
      name: 'BNB Smart Chain',
      symbol: 'BNB',
      rpcUrl: 'https://bsc-dataseed.binance.org',
      explorerUrl: 'https://bscscan.com',
      derivationPath: "m/44'/60'/0'/0",
    ),
    'bitcoin': ChainInfo(
      chainId: 0,
      name: 'Bitcoin',
      symbol: 'BTC',
      rpcUrl: 'https://blockstream.info/api',
      explorerUrl: 'https://blockstream.info',
      derivationPath: "m/84'/0'/0'/0",
    ),
  };
}

class MultiChainWallet {
  final Map<String, Web3Client> _evmClients = {};
  
  // Get balance for chain
  Future<BigInt> getBalance(String chain, String address) async {
    if (_isEvmChain(chain)) {
      final client = _getEvmClient(chain);
      final balance = await client.getBalance(
        EthereumAddress.fromHex(address),
      );
      return balance.getInWei;
    } else if (chain == 'bitcoin') {
      return await _getBitcoinBalance(address);
    }
    throw UnsupportedChainException(chain);
  }
  
  // Get token balances
  Future<List<TokenBalance>> getTokenBalances(
    String chain,
    String address,
  ) async {
    // Use token list API or on-chain calls
    final tokens = await _fetchTokenList(chain, address);
    return tokens;
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Never store private keys in plain text—always encrypt
- ✅ Use hardware security modules (Secure Enclave/TEE) when available
- ✅ Implement proper backup and recovery flows
- ✅ Show clear transaction details before signing
- ✅ Support hardware wallets (Ledger, Trezor) for enhanced security

### ❌ Avoid This

- ❌ Never transmit private keys over the network
- ❌ Don't log mnemonic phrases or private keys
- ❌ Don't skip transaction simulation before signing
- ❌ Never auto-sign transactions without user confirmation
- ❌ Don't store mnemonic in clipboard for extended periods

## Common Pitfalls

**Problem:** Transaction fails with "nonce too low"
**Solution:** Track nonces locally and sync with chain. Use pending nonce for queued transactions.

**Problem:** WalletConnect session disconnects
**Solution:** Implement session persistence and auto-reconnection on app restart.

## Related Skills

- `@senior-flutter-developer` - Mobile app development
- `@decentralized-finance-specialist` - DeFi integration
- `@senior-web3-developer` - Blockchain integration
- `@web3-smart-contract-auditor` - Security considerations
- `@senior-cybersecurity-engineer` - Security best practices
