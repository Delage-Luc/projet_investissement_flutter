import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/favorite_button.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/percent_chip.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Ligne d'actif avec prix, variation et bouton favori, présentée comme une
/// fiche de carnet : rang de capitalisation, logo, nom et prix.
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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final rank = asset.marketCapRank;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    rank == null ? '–' : '$rank',
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      fontFeatures: tabularFigures,
                    ),
                  ),
                ),
                _AssetLogo(asset: asset),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${asset.symbol.toUpperCase()} · '
                        '${Formatters.price(asset.currentPrice, vsCurrency)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                    ],
                  ),
                ),
                PercentChip(value: asset.priceChange24h),
                FavoriteButton(
                  isFavorite: isFavorite,
                  onPressed: onToggleFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetLogo extends StatelessWidget {
  const _AssetLogo({required this.asset});

  final CryptoAsset asset;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fallback = CircleAvatar(
      radius: 20,
      backgroundColor: colors.highlight,
      foregroundColor: colors.onHighlight,
      child: Text(
        asset.symbol.isEmpty ? '?' : asset.symbol[0].toUpperCase(),
        style: const TextStyle(
          fontFamily: AppTheme.displayFont,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = asset.imageUrl;
    if (url == null) return fallback;
    // Affiche l'initiale si le logo ne charge pas.
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.line),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          width: 36,
          height: 36,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      ),
    );
  }
}
