# NFT Display Template

Complete NFT fetching and display implementation.

## NFT Model

```dart
class NFT {
  final String tokenId;
  final String contractAddress;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? animationUrl;
  final Map<String, dynamic>? attributes;
  final String? collection;

  const NFT({
    required this.tokenId,
    required this.contractAddress,
    required this.name,
    this.description,
    this.imageUrl,
    this.animationUrl,
    this.attributes,
    this.collection,
  });

  factory NFT.fromOpenSeaJson(Map<String, dynamic> json) {
    return NFT(
      tokenId: json['identifier'] ?? '',
      contractAddress: json['contract'] ?? '',
      name: json['name'] ?? 'Unnamed',
      description: json['description'],
      imageUrl: _resolveIpfsUrl(json['image_url']),
      animationUrl: _resolveIpfsUrl(json['animation_url']),
      collection: json['collection'],
    );
  }

  factory NFT.fromAlchemyJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] ?? {};
    return NFT(
      tokenId: json['tokenId'] ?? '',
      contractAddress: json['contract']?['address'] ?? '',
      name: metadata['name'] ?? json['title'] ?? 'Unnamed',
      description: metadata['description'],
      imageUrl: _resolveIpfsUrl(metadata['image'] ?? json['media']?[0]?['gateway']),
      animationUrl: _resolveIpfsUrl(metadata['animation_url']),
      attributes: metadata['attributes'] != null
          ? Map.fromEntries(
              (metadata['attributes'] as List).map(
                (attr) => MapEntry(attr['trait_type'], attr['value']),
              ),
            )
          : null,
      collection: json['contract']?['name'],
    );
  }

  static String? _resolveIpfsUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('ipfs://')) {
      return url.replaceFirst('ipfs://', 'https://ipfs.io/ipfs/');
    }
    return url;
  }
}
```

## NFT Service

```dart
import 'package:dio/dio.dart';

class NFTService {
  final Dio _dio;
  final String _alchemyApiKey;

  NFTService({required String alchemyApiKey})
      : _alchemyApiKey = alchemyApiKey,
        _dio = Dio();

  /// Fetch NFTs for an address using Alchemy
  Future<List<NFT>> getNFTs({
    required String address,
    int chainId = 1,
    int pageSize = 20,
    String? pageKey,
  }) async {
    final baseUrl = _getAlchemyUrl(chainId);

    final response = await _dio.get(
      '$baseUrl/getNFTsForOwner',
      queryParameters: {
        'owner': address,
        'withMetadata': true,
        'pageSize': pageSize,
        if (pageKey != null) 'pageKey': pageKey,
      },
      options: Options(
        headers: {'accept': 'application/json'},
      ),
    );

    final ownedNfts = response.data['ownedNfts'] as List;
    return ownedNfts.map((nft) => NFT.fromAlchemyJson(nft)).toList();
  }

  /// Get single NFT metadata
  Future<NFT?> getNFTMetadata({
    required String contractAddress,
    required String tokenId,
    int chainId = 1,
  }) async {
    final baseUrl = _getAlchemyUrl(chainId);

    try {
      final response = await _dio.get(
        '$baseUrl/getNFTMetadata',
        queryParameters: {
          'contractAddress': contractAddress,
          'tokenId': tokenId,
        },
      );

      return NFT.fromAlchemyJson(response.data);
    } catch (e) {
      return null;
    }
  }

  String _getAlchemyUrl(int chainId) {
    switch (chainId) {
      case 1:
        return 'https://eth-mainnet.g.alchemy.com/nft/v3/$_alchemyApiKey';
      case 137:
        return 'https://polygon-mainnet.g.alchemy.com/nft/v3/$_alchemyApiKey';
      case 42161:
        return 'https://arb-mainnet.g.alchemy.com/nft/v3/$_alchemyApiKey';
      default:
        return 'https://eth-mainnet.g.alchemy.com/nft/v3/$_alchemyApiKey';
    }
  }
}
```

## NFT Grid Widget

```dart
import 'package:cached_network_image/cached_network_image.dart';

class NFTGridView extends StatelessWidget {
  final List<NFT> nfts;
  final void Function(NFT)? onTap;

  const NFTGridView({
    super.key,
    required this.nfts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: nfts.length,
      itemBuilder: (context, index) => NFTCard(
        nft: nfts[index],
        onTap: onTap,
      ),
    );
  }
}

class NFTCard extends StatelessWidget {
  final NFT nft;
  final void Function(NFT)? onTap;

  const NFTCard({
    super.key,
    required this.nft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(nft),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[900],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: nft.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: nft.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.image, size: 48),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nft.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (nft.collection != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      nft.collection!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Usage Example

```dart
class NFTScreen extends StatefulWidget {
  final String walletAddress;

  const NFTScreen({super.key, required this.walletAddress});

  @override
  State<NFTScreen> createState() => _NFTScreenState();
}

class _NFTScreenState extends State<NFTScreen> {
  final _nftService = NFTService(alchemyApiKey: 'YOUR_KEY');
  List<NFT> _nfts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNFTs();
  }

  Future<void> _loadNFTs() async {
    try {
      final nfts = await _nftService.getNFTs(address: widget.walletAddress);
      setState(() {
        _nfts = nfts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_nfts.isEmpty) {
      return const Center(child: Text('No NFTs found'));
    }

    return NFTGridView(
      nfts: _nfts,
      onTap: (nft) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NFTDetailScreen(nft: nft)),
      ),
    );
  }
}
```
