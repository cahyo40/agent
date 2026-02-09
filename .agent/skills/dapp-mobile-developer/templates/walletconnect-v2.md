# WalletConnect V2 Template

Complete WalletConnect V2 integration for Flutter dApps.

## WalletConnect Service

```dart
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectService {
  Web3App? _web3App;
  SessionData? _activeSession;
  
  final String projectId;
  final PairingMetadata metadata;

  WalletConnectService({
    required this.projectId,
    required this.metadata,
  });

  /// Initialize WalletConnect
  Future<void> initialize() async {
    _web3App = await Web3App.createInstance(
      projectId: projectId,
      metadata: metadata,
    );

    // Listen for session events
    _web3App!.onSessionConnect.subscribe(_onSessionConnect);
    _web3App!.onSessionDelete.subscribe(_onSessionDelete);
    _web3App!.onSessionUpdate.subscribe(_onSessionUpdate);

    // Restore existing sessions
    final sessions = _web3App!.sessions.getAll();
    if (sessions.isNotEmpty) {
      _activeSession = sessions.first;
    }
  }

  /// Connect to a wallet - returns URI for QR code
  Future<String> connect({
    List<String> chains = const ['eip155:1', 'eip155:137'],
  }) async {
    final connectResponse = await _web3App!.connect(
      requiredNamespaces: {
        'eip155': RequiredNamespace(
          chains: chains,
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

    // Wait for session approval
    connectResponse.session.future.then((session) {
      _activeSession = session;
    });

    return connectResponse.uri.toString();
  }

  /// Get connected wallet address
  String? getConnectedAddress() {
    if (_activeSession == null) return null;

    final accounts = _activeSession!.namespaces['eip155']?.accounts;
    if (accounts == null || accounts.isEmpty) return null;

    // Format: eip155:1:0xAddress
    return accounts.first.split(':').last;
  }

  /// Get current chain ID
  int? getChainId() {
    if (_activeSession == null) return null;

    final accounts = _activeSession!.namespaces['eip155']?.accounts;
    if (accounts == null || accounts.isEmpty) return null;

    // Format: eip155:1:0xAddress
    return int.tryParse(accounts.first.split(':')[1]);
  }

  /// Send transaction via connected wallet
  Future<String> sendTransaction({
    required String to,
    required String value,
    String? data,
  }) async {
    if (_activeSession == null) {
      throw Exception('No active session');
    }

    final address = getConnectedAddress();
    final chainId = getChainId();

    if (address == null || chainId == null) {
      throw Exception('Invalid session state');
    }

    final result = await _web3App!.request(
      topic: _activeSession!.topic,
      chainId: 'eip155:$chainId',
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        params: [
          {
            'from': address,
            'to': to,
            'value': value,
            'data': data ?? '0x',
          }
        ],
      ),
    );

    return result as String;
  }

  /// Sign a message
  Future<String> personalSign(String message) async {
    if (_activeSession == null) {
      throw Exception('No active session');
    }

    final address = getConnectedAddress();
    final chainId = getChainId();

    final result = await _web3App!.request(
      topic: _activeSession!.topic,
      chainId: 'eip155:$chainId',
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [message, address],
      ),
    );

    return result as String;
  }

  /// Disconnect session
  Future<void> disconnect() async {
    if (_activeSession != null) {
      await _web3App!.disconnectSession(
        topic: _activeSession!.topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
      );
      _activeSession = null;
    }
  }

  /// Check if connected
  bool get isConnected => _activeSession != null;

  /// Event handlers
  void _onSessionConnect(SessionConnect? event) {
    if (event != null) {
      _activeSession = event.session;
    }
  }

  void _onSessionDelete(SessionDelete? event) {
    _activeSession = null;
  }

  void _onSessionUpdate(SessionUpdate? event) {
    // Handle session updates
  }

  void dispose() {
    _web3App?.onSessionConnect.unsubscribe(_onSessionConnect);
    _web3App?.onSessionDelete.unsubscribe(_onSessionDelete);
    _web3App?.onSessionUpdate.unsubscribe(_onSessionUpdate);
  }
}
```

## Usage with QR Code

```dart
import 'package:qr_flutter/qr_flutter.dart';

class ConnectWalletScreen extends StatefulWidget {
  @override
  State<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen> {
  final _walletConnect = WalletConnectService(
    projectId: 'YOUR_PROJECT_ID',
    metadata: const PairingMetadata(
      name: 'My dApp',
      description: 'Mobile dApp',
      url: 'https://myapp.com',
      icons: ['https://myapp.com/icon.png'],
    ),
  );

  String? _uri;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _walletConnect.initialize();
    
    if (_walletConnect.isConnected) {
      // Already connected, navigate to main screen
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _connect() async {
    setState(() => _isConnecting = true);
    
    try {
      final uri = await _walletConnect.connect();
      setState(() => _uri = uri);
      
      // Also open the URI in wallet apps
      await launchUrl(Uri.parse(uri));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: $e')),
      );
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Wallet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_uri != null) ...[
              QrImageView(
                data: _uri!,
                size: 250,
              ),
              const SizedBox(height: 16),
              const Text('Scan with your wallet app'),
            ] else ...[
              ElevatedButton(
                onPressed: _isConnecting ? null : _connect,
                child: _isConnecting
                    ? const CircularProgressIndicator()
                    : const Text('Connect Wallet'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _walletConnect.dispose();
    super.dispose();
  }
}
```
