# Web3 Service Template

Complete Web3Dart service for blockchain interaction.

## Web3 Service Implementation

```dart
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class Web3Service {
  late Web3Client _client;
  final String _rpcUrl;
  final int _chainId;

  Web3Service({
    required String rpcUrl,
    required int chainId,
  })  : _rpcUrl = rpcUrl,
        _chainId = chainId {
    _client = Web3Client(_rpcUrl, Client());
  }

  /// Get native token balance
  Future<EtherAmount> getBalance(String address) async {
    final addr = EthereumAddress.fromHex(address);
    return await _client.getBalance(addr);
  }

  /// Get ERC-20 token balance
  Future<BigInt> getTokenBalance({
    required String tokenAddress,
    required String walletAddress,
  }) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(_erc20Abi, 'ERC20'),
      EthereumAddress.fromHex(tokenAddress),
    );

    final balanceOf = contract.function('balanceOf');
    final result = await _client.call(
      contract: contract,
      function: balanceOf,
      params: [EthereumAddress.fromHex(walletAddress)],
    );

    return result.first as BigInt;
  }

  /// Send native token transaction
  Future<String> sendTransaction({
    required Credentials credentials,
    required String to,
    required BigInt value,
    String? data,
  }) async {
    // Get current gas prices (EIP-1559)
    final gasPrice = await _client.getGasPrice();

    // Estimate gas
    final gasEstimate = await _client.estimateGas(
      sender: await credentials.extractAddress(),
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.inWei(value),
      data: data != null ? hexToBytes(data) : null,
    );

    // Build transaction
    final transaction = Transaction(
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.inWei(value),
      gasPrice: gasPrice,
      maxGas: gasEstimate.toInt() * 120 ~/ 100, // 20% buffer
      data: data != null ? hexToBytes(data) : null,
    );

    // Sign and send
    final txHash = await _client.sendTransaction(
      credentials,
      transaction,
      chainId: _chainId,
    );

    return txHash;
  }

  /// Send ERC-20 token transfer
  Future<String> sendTokenTransfer({
    required Credentials credentials,
    required String tokenAddress,
    required String to,
    required BigInt amount,
  }) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(_erc20Abi, 'ERC20'),
      EthereumAddress.fromHex(tokenAddress),
    );

    final transfer = contract.function('transfer');

    final txHash = await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: transfer,
        parameters: [EthereumAddress.fromHex(to), amount],
      ),
      chainId: _chainId,
    );

    return txHash;
  }

  /// Wait for transaction confirmation
  Future<TransactionReceipt?> waitForReceipt(
    String txHash, {
    Duration timeout = const Duration(minutes: 2),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      final receipt = await _client.getTransactionReceipt(txHash);
      if (receipt != null) {
        return receipt;
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    return null;
  }

  void dispose() {
    _client.dispose();
  }
}

const String _erc20Abi = '''
[
  {"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"},
  {"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"}
]
''';
```

## Usage Example

```dart
// Initialize
final web3 = Web3Service(
  rpcUrl: 'https://mainnet.infura.io/v3/YOUR_KEY',
  chainId: 1,
);

// Get balance
final balance = await web3.getBalance('0x...');
print('Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');

// Send transaction
final txHash = await web3.sendTransaction(
  credentials: credentials,
  to: '0xRecipient...',
  value: BigInt.from(1e18), // 1 ETH
);

// Wait for confirmation
final receipt = await web3.waitForReceipt(txHash);
if (receipt != null && receipt.status == true) {
  print('Transaction confirmed!');
}
```
