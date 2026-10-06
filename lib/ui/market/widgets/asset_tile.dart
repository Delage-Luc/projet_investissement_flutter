import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/favorite_button.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/percent_chip.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Ligne d'actif avec prix, variation et bouton favori.
class AssetTile extends StatelessWidget {
  const AssetTile({
    super.key,
    required this.asset,
    required this.vsCurrency,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final CryptoAsset asset;
  final String vsCurrency;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _AssetLogo(asset: asset),
      title: Text(asset.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${asset.symbol.toUpperCase()} · ${Formatters.price(asset.currentPrice, vsCurrency)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PercentChip(value: asset.priceChange24h),
          FavoriteButton(isFavorite: isFavorite, onPressed: onToggleFavorite),
        ],
      ),
    );
  }
}

class _AssetLogo extends StatelessWidget {
  const _AssetLogo({required this.asset});

  final CryptoAsset asset;

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      child: Text(asset.symbol.isEmpty ? '?' : asset.symbol[0].toUpperCase()),
    );
    final url = asset.imageUrl;
    if (url == null) return fallback;
    // Affiche l'initiale si le logo ne charge pas.
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Image.network(
          url,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      ),
    );
  }
}
