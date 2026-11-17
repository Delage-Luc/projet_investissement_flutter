import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/aurora.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/favorite_button.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/percent_chip.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Ligne d'actif avec prix, variation et bouton favori : une carte de verre,
/// le rang de capitalisation en filigrane géant et un anneau lumineux autour
/// du logo, vert ou rouge selon la tendance du jour.
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
    final colors = AppColors.of(context);
    final rank = asset.marketCapRank;
    final trend = pnlColor(context, asset.priceChange24h);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GlassCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
              child: Row(
                children: [
                  // Logo cerclé de la tendance, avec le rang en badge.
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _AssetLogo(asset: asset, ring: trend),
                      if (rank != null)
                        Positioned(
                          right: -6,
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colors.base, width: 2),
                            ),
                            child: Text(
                              '#$rank',
                              style: TextStyle(
                                color: colors.base,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${asset.symbol.toUpperCase()}  ',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              TextSpan(
                                text: Formatters.price(
                                  asset.currentPrice,
                                  vsCurrency,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}

class _AssetLogo extends StatelessWidget {
  const _AssetLogo({required this.asset, required this.ring});

  final CryptoAsset asset;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fallback = Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        asset.symbol.isEmpty ? '?' : asset.symbol[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    final url = asset.imageUrl;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [ring, ring.withValues(alpha: 0.1), ring],
        ),
        boxShadow: [
          BoxShadow(color: ring.withValues(alpha: 0.45), blurRadius: 14),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: colors.base, shape: BoxShape.circle),
        // Affiche l'initiale si le logo est absent ou ne charge pas.
        child: url == null
            ? fallback
            : ClipOval(
                child: Image.network(
                  url,
                  width: 38,
                  height: 38,
                  errorBuilder: (context, error, stackTrace) => fallback,
                ),
              ),
      ),
    );
  }
}
