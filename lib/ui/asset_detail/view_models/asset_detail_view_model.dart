import 'package:flutter/foundation.dart';
import 'package:projet_investissement_flutter/data/repositories/market_repository.dart';
import 'package:projet_investissement_flutter/domain/models/asset_score.dart';
import 'package:projet_investissement_flutter/domain/models/chart_period.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/domain/models/risk.dart';
import 'package:projet_investissement_flutter/utils/async_state.dart';
import 'package:projet_investissement_flutter/utils/finance_calculator.dart';
import 'package:projet_investissement_flutter/utils/score_calculator.dart';

/// Historique et indicateurs de la fiche d'un actif.
class AssetDetailViewModel extends ChangeNotifier {
  AssetDetailViewModel({
    required MarketRepository repository,
    required this.assetId,
    required this.vsCurrency,
  }) : _repository = repository;

  /// Actif de référence pour comparer la volatilité.
  static const String referenceAssetId = 'bitcoin';
  static const String referenceAssetName = 'Bitcoin';

  /// Somme fictive des phrases « et si j'avais investi… ».
  static const double whatIfAmount = 100;

  final MarketRepository _repository;
  final String assetId;
  final String vsCurrency;

  AsyncState<List<PricePoint>> _state = const AsyncState.initial();
  ChartPeriod _period = ChartPeriod.quarter;
  bool _disposed = false;

  /// Historique du Bitcoin, facultatif : sans lui, la comparaison est omise.
  List<PricePoint> _reference = const [];

  List<PricePoint> _visible = const [];
  double? _performance;
  double? _volatility;
  DrawdownInfo? _drawdown;
  double? _whatIfValue;
  ({int up, int down}) _upDown = (up: 0, down: 0);
  AssetScore? _score;
  double? _referenceVolatility;

  AsyncState<List<PricePoint>> get state => _state;
  ChartPeriod get period => _period;
  List<PricePoint> get visiblePoints => _visible;
  double? get performance => _performance;

  /// Volatilité annualisée, en %.
  double? get volatility => _volatility;
  VolatilityLevel? get volatilityLevel =>
      _volatility == null ? null : VolatilityLevel.fromAnnualized(_volatility!);
  double? get maxDrawdown => _drawdown?.percent;
  DrawdownInfo? get drawdown => _drawdown;

  /// Valeur actuelle de [whatIfAmount] investi au début de la période.
  double? get whatIfValue => _whatIfValue;
  int get upDays => _upDown.up;
  int get downDays => _upDown.down;
  AssetScore? get score => _score;

  /// Volatilité annualisée du Bitcoin sur la même période (null si
  /// indisponible ou si l'actif affiché est le Bitcoin).
  double? get referenceVolatility => _referenceVolatility;

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
    if (_state.status == AsyncStatus.success) await _loadReference();
  }

  /// Charge l'historique de référence (souvent déjà en cache). Un échec n'est
  /// pas une erreur pour l'utilisateur : la phrase de comparaison est omise.
  Future<void> _loadReference() async {
    if (assetId == referenceAssetId || _reference.isNotEmpty) return;
    try {
      final result = await _repository.getHistory(
        assetId: referenceAssetId,
        vsCurrency: vsCurrency,
      );
      _reference = result.data;
      _recompute();
      _notify();
    } on Object {
      // Comparaison facultative.
    }
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
      _performance = _volatility = _whatIfValue = _referenceVolatility = null;
      _drawdown = null;
      _score = null;
      _upDown = (up: 0, down: 0);
      return;
    }
    _visible = _cut(all);
    _performance = FinanceCalculator.seriesPerformance(_visible);
    _volatility = FinanceCalculator.volatility(_visible, annualized: true);
    _drawdown = FinanceCalculator.maxDrawdownDetails(_visible);
    _whatIfValue = FinanceCalculator.whatIfInvested(whatIfAmount, _visible);
    _upDown = FinanceCalculator.upDownDays(_visible);
    _score = ScoreCalculator.score(_visible);
    _referenceVolatility = _reference.isEmpty
        ? null
        : FinanceCalculator.volatility(_cut(_reference), annualized: true);
  }

  /// Garde les points de la période choisie.
  List<PricePoint> _cut(List<PricePoint> points) {
    final cutoff = points.last.date.subtract(Duration(days: _period.days));
    return points.where((p) => !p.date.isBefore(cutoff)).toList();
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
