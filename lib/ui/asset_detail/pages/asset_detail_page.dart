import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/data/repositories/market_repository.dart';
import 'package:projet_investissement_flutter/ui/asset_detail/view_models/asset_detail_view_model.dart';
import 'package:projet_investissement_flutter/ui/asset_detail/widgets/period_selector.dart';
import 'package:projet_investissement_flutter/ui/asset_detail/widgets/price_chart.dart';
import 'package:projet_investissement_flutter/ui/asset_detail/widgets/stats_grid.dart';
import 'package:projet_investissement_flutter/ui/favorites/view_models/favorites_view_model.dart';
import 'package:projet_investissement_flutter/ui/market/view_models/market_view_model.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/error_view.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/favorite_button.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/percent_chip.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/status_banner.dart';
import 'package:projet_investissement_flutter/utils/async_state.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:provider/provider.dart';

/// Fiche d'un actif, avec un ViewModel conservé pendant la navigation.
class AssetDetailPage extends StatelessWidget {
  const AssetDetailPage({super.key, required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AssetDetailViewModel(
        repository: context.read<MarketRepository>(),
        assetId: assetId,
        vsCurrency: context.read<SettingsViewModel>().vsCurrency,
      )..load(),
      child: _AssetDetailView(assetId: assetId),
    );
  }
}

class _AssetDetailView extends StatelessWidget {
  const _AssetDetailView({required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<AssetDetailViewModel>();
    final market = context.watch<MarketViewModel>();
    final favorites = context.watch<FavoritesViewModel>();
    final asset = market.findById(assetId);
    final state = detail.state;
    final vs = detail.vsCurrency;

    return Scaffold(
      appBar: AppBar(
        title: Text(asset?.name ?? assetId),
        actions: [
          FavoriteButton(
            isFavorite: favorites.isFavorite(assetId),
            onPressed: () => favorites.toggle(assetId),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.isLoading) const LinearProgressIndicator(),
          if (state.hasData && state.lastUpdated != null)
            StatusBanner(lastUpdated: state.lastUpdated!, isStale: state.isStale),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => detail.load(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (asset != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.price(asset.currentPrice, vs),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 8),
                        PercentChip(value: asset.priceChange24h),
                        const Text(' (24 h)'),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: PeriodSelector(
                      selected: detail.period,
                      onChanged: detail.selectPeriod,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChart(context, detail, vs),
                  const SizedBox(height: 16),
                  StatsGrid(
                    performance: detail.performance,
                    volatility: detail.volatility,
                    maxDrawdown: detail.maxDrawdown,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Outil pédagogique : aucune transaction réelle. '
                    'Les performances passées ne préjugent pas des '
                    'performances futures.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    AssetDetailViewModel detail,
    String vs,
  ) {
    final state = detail.state;
    if (!state.hasData) {
      if (state.status == AsyncStatus.error) {
        return SizedBox(
          height: 240,
          child: ErrorView(
            message: errorMessage(state.error),
            onRetry: () => detail.load(),
          ),
        );
      }
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return PriceChart(
      points: detail.visiblePoints,
      vsCurrency: vs,
      color: pnlColor(context, detail.performance),
    );
  }
}
