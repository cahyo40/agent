# HD Wallet Template

Complete HD wallet implementation with secure key storage.

## Wallet Model

```dart
class Wallet {
  final String address;
  final String privateKey;
  final String publicKey;
  final int index;
  final String derivationPath;

  const Wallet({
    required this.address,
    required this.privateKey,
    required this.publicKey,
    required this.index,
    required this.derivationPath,
  });
}
```

## Wallet Service

```dart
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/credentials.dart';
import 'package:hex/hex.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class WalletService {
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  static const String _mnemonicKey = 'wallet_mnemonic';
  static const String _derivationPath = "m/44'/60'/0'/0";

  WalletService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        ),
        _localAuth = LocalAuthentication();

  /// Generate new wallet with mnemonic
  Future<String> createWallet() async {
    // Generate 12-word mnemonic
    final mnemonic = bip39.generateMnemonic(strength: 128);

    // Save securely
    await _storage.write(key: _mnemonicKey, value: mnemonic);

    return mnemonic;
  }

  /// Import wallet from mnemonic
  Future<void> importWallet(String mnemonic) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic phrase');
    }

    await _storage.write(key: _mnemonicKey, value: mnemonic);
  }

  /// Get wallet at specific index
  Future<Wallet> getWallet({int index = 0}) async {
    final mnemonic = await _storage.read(key: _mnemonicKey);
    if (mnemonic == null) {
      throw Exception('No wallet found');
    }

    return _deriveWallet(mnemonic, index);
  }

  /// Get multiple wallets
  Future<List<Wallet>> getWallets({int count = 5}) async {
    final mnemonic = await _storage.read(key: _mnemonicKey);
    if (mnemonic == null) {
      throw Exception('No wallet found');
    }

    return List.generate(
      count,
      (index) => _deriveWallet(mnemonic, index),
    );
  }

  /// Derive wallet from mnemonic
  Wallet _deriveWallet(String mnemonic, int index) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);

    final path = '$_derivationPath/$index';
    final child = root.derivePath(path);

    final privateKey = HEX.encode(child.privateKey!);
    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = credentials.address.hexEip55;

    return Wallet(
      address: address,
      privateKey: privateKey,
      publicKey: HEX.encode(child.publicKey),
      index: index,
      derivationPath: path,
    );
  }

  /// Get credentials with biometric auth
  Future<Credentials> getCredentials({int index = 0}) async {
    // Require biometric authentication
    final authenticated = await _localAuth.authenticate(
      localizedReason: 'Authenticate to sign transaction',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false,
      ),
    );

    if (!authenticated) {
      throw Exception('Authentication failed');
    }

    final wallet = await getWallet(index: index);
    return EthPrivateKey.fromHex(wallet.privateKey);
  }

  /// Check if wallet exists
  Future<bool> hasWallet() async {
    final mnemonic = await _storage.read(key: _mnemonicKey);
    return mnemonic != null;
  }

  /// Delete wallet (dangerous!)
  Future<void> deleteWallet() async {
    await _storage.delete(key: _mnemonicKey);
  }

  /// Export mnemonic (requires auth)
  Future<String?> exportMnemonic() async {
    final authenticated = await _localAuth.authenticate(
      localizedReason: 'Authenticate to export recovery phrase',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false,
      ),
    );

    if (!authenticated) {
      return null;
    }

    return await _storage.read(key: _mnemonicKey);
  }
}
```

## Usage Example

```dart
final walletService = WalletService();

// Create new wallet
final mnemonic = await walletService.createWallet();
print('Save this phrase: $mnemonic');

// Get wallet address
final wallet = await walletService.getWallet();
print('Address: ${wallet.address}');

// Sign transaction (requires biometric)
final credentials = await walletService.getCredentials();
final txHash = await web3.sendTransaction(
  credentials: credentials,
  to: '0x...',
  value: BigInt.from(1e18),
);
```

## Security Considerations

1. **Never log private keys** - Even in debug mode
2. **Always use biometric auth** - Before signing or exporting
3. **Use secure storage** - With encryption enabled
4. **Clear memory** - After using private keys
5. **Validate mnemonic** - Before importing
