/// Crypto-monnaie renvoyée par `/coins/markets`.
class CryptoAsset {
  const CryptoAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    this.imageUrl,
    this.marketCap,
    this.marketCapRank,
    this.priceChange24h,
  });

  final String id;
  final String symbol;
  final String name;
  final String? imageUrl;
  final double currentPrice;
  final double? marketCap;
  final int? marketCapRank;

  /// Variation sur 24 h, en pourcentage.
  final double? priceChange24h;

  factory CryptoAsset.fromJson(Map<String, dynamic> json) => CryptoAsset(
        id: json['id'] as String,
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        imageUrl: json['image'] as String?,
        currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0,
        marketCap: (json['market_cap'] as num?)?.toDouble(),
        marketCapRank: (json['market_cap_rank'] as num?)?.toInt(),
        priceChange24h:
            (json['price_change_percentage_24h'] as num?)?.toDouble(),
      );

  /// Garde les clés de l'API pour stocker sa réponse dans le cache.
  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'name': name,
        'image': imageUrl,
        'current_price': currentPrice,
        'market_cap': marketCap,
        'market_cap_rank': marketCapRank,
        'price_change_percentage_24h': priceChange24h,
      };
}
