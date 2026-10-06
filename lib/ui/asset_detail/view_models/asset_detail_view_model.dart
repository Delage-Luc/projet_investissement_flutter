import 'package:flutter/foundation.dart';
import 'package:projet_investissement_flutter/data/repositories/market_repository.dart';
import 'package:projet_investissement_flutter/domain/models/chart_period.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/utils/async_state.dart';
import 'package:projet_investissement_flutter/utils/finance_calculator.dart';

/// Historique et indicateurs de la fiche d'un actif.
class AssetDetailViewModel extends ChangeNotifier {
  AssetDetailViewModel({
    required MarketRepository repository,
    required this.assetId,
    required this.vsCurrency,
  }) : _repository = repository;

  final MarketRepository _repository;
  final String assetId;
  final String vsCurrency;

  AsyncState<List<PricePoint>> _state = const AsyncState.initial();
  ChartPeriod _period = ChartPeriod.quarter;
  bool _disposed = false;

  List<PricePoint> _visible = const [];
  double? _performance;
  double? _volatility;
  double? _maxDrawdown;

  AsyncState<List<PricePoint>> get state => _state;
  ChartPeriod get period => _period;
  List<PricePoint> get visiblePoints => _visible;
  double? get performance => _performance;
  double? get volatility => _volatility;
  double? get maxDrawdown => _maxDrawdown;

  Future<void> load({bool forceRefresh = false}) async {
    _state = AsyncState.loading(
      data: _state.data,
      lastUpdated: _state.lastUpdated,
      isStale: _state.isStale,
    );
    _notify();

    try {
      final result = await _repository.getHistory(
        assetId: assetId,
        vsCurrency: vsCurrency,
        forceRefresh: forceRefresh,
      );
      _state = AsyncState.success(
        result.data,
        lastUpdated: result.lastUpdated,
        isStale: result.isStale,
      );
      _recompute();
    } on Object catch (e) {
      _state = AsyncState.error(
        e,
        data: _state.data,
        lastUpdated: _state.lastUpdated,
      );
    }
    _notify();
  }

  void selectPeriod(ChartPeriod period) {
    if (period == _period) return;
    _period = period;
    _recompute();
    _notify();
  }

  /// Met à jour les indicateurs après un changement de données ou de période.
  void _recompute() {
    final all = _state.data;
    if (all == null || all.isEmpty) {
      _visible = const [];
      _performance = _volatility = _maxDrawdown = null;
      return;
    }
    final cutoff = all.last.date.subtract(Duration(days: _period.days));
    _visible = all.where((p) => !p.date.isBefore(cutoff)).toList();
    _performance = FinanceCalculator.seriesPerformance(_visible);
    _volatility = FinanceCalculator.volatility(_visible);
    _maxDrawdown = FinanceCalculator.maxDrawdown(_visible);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
