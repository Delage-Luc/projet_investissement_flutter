import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/routing/routes.dart';
import 'package:projet_investissement_flutter/ui/favorites/view_models/favorites_view_model.dart';
import 'package:projet_investissement_flutter/ui/market/view_models/market_view_model.dart';
import 'package:projet_investissement_flutter/ui/market/widgets/asset_tile.dart';
import 'package:projet_investissement_flutter/ui/market/widgets/ticker_tape.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/aurora.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/custom_app_bar.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/feedback.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/error_view.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/status_banner.dart';
import 'package:projet_investissement_flutter/utils/async_state.dart';
import 'package:provider/provider.dart';

/// Liste du marché avec recherche, favoris et actualisation.
class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketViewModel>();
    final favorites = context.watch<FavoritesViewModel>();
    final state = market.state;

    return Scaffold(
      appBar: CustomAppBar(title: 'Marché'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: market.setQuery,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Rechercher une crypto',
              ),
            ),
          ),
          // Bandeau décoratif : variations 24 h des actifs déjà chargés.
          if (state.hasData) TickerTape(assets: state.data!),
          if (state.isLoading) const LinearProgressIndicator(),
          if (state.hasData && state.lastUpdated != null)
            StatusBanner(
              lastUpdated: state.lastUpdated!,
              isStale: state.isStale,
            ),
          Expanded(child: _buildBody(context, market, favorites)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MarketViewModel market,
    FavoritesViewModel favorites,
  ) {
    final state = market.state;

    if (!state.hasData) {
      if (state.status == AsyncStatus.error) {
        return ErrorView(
          message: errorMessage(state.error),
          onRetry: () => market.load(),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final assets = market.assets;
    return RefreshIndicator(
      onRefresh: () => market.load(forceRefresh: true),
      child: assets.isEmpty
          ? ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Aucun résultat.')),
                ),
              ],
            )
          : ListView.builder(
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return FadeSlideIn(
                  // Conserve l'état de chaque ligne quand la liste est filtrée.
                  key: ValueKey(asset.id),
                  index: index,
                  child: AssetTile(
                    asset: asset,
                    vsCurrency: market.vsCurrency,
                    isFavorite: favorites.isFavorite(asset.id),
                    onTap: () => context.push(Routes.asset(asset.id)),
                    onToggleFavorite: () => toggleFavorite(context, asset.id),
                  ),
                );
              },
            ),
    );
  }
}
