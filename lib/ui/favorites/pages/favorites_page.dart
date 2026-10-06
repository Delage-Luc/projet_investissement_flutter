import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/routing/routes.dart';
import 'package:projet_investissement_flutter/ui/favorites/view_models/favorites_view_model.dart';
import 'package:projet_investissement_flutter/ui/market/view_models/market_view_model.dart';
import 'package:projet_investissement_flutter/ui/market/widgets/asset_tile.dart';
import 'package:provider/provider.dart';

/// Liste des actifs favoris.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesViewModel>();
    final market = context.watch<MarketViewModel>();

    // Ignore les favoris dont les données ne sont pas chargées.
    final assets = favorites.ids
        .map(market.findById)
        .whereType<CryptoAsset>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favoris')),
      body: favorites.isEmpty
          ? _EmptyFavorites(onExplore: () => context.go(Routes.market))
          : assets.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: assets.length,
                  itemBuilder: (context, index) {
                    final asset = assets[index];
                    return AssetTile(
                      key: ValueKey(asset.id),
                      asset: asset,
                      vsCurrency: market.vsCurrency,
                      isFavorite: true,
                      onTap: () => context.push(Routes.asset(asset.id)),
                      onToggleFavorite: () => favorites.toggle(asset.id),
                    );
                  },
                ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_border, size: 56),
            const SizedBox(height: 12),
            Text(
              'Aucun favori pour l\'instant',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoute des cryptos avec l\'étoile pour suivre leur évolution ici.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onExplore,
              child: const Text('Explorer le marché'),
            ),
          ],
        ),
      ),
    );
  }
}
