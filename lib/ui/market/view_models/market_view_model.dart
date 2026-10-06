import 'package:flutter/foundation.dart';
import 'package:projet_investissement_flutter/data/repositories/market_repository.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:projet_investissement_flutter/utils/async_state.dart';

/// Gère le chargement, la recherche et l'état du marché.
class MarketViewModel extends ChangeNotifier {
  MarketViewModel({
    required MarketRepository repository,
    required SettingsViewModel settings,
  })  : _repository = repository,
        _settings = settings;

  final MarketRepository _repository;
  final SettingsViewModel _settings;

  AsyncState<List<CryptoAsset>> _state = const AsyncState.initial();
  String _query = '';
  int _requestId = 0;

  AsyncState<List<CryptoAsset>> get state => _state;
  String get vsCurrency => _settings.vsCurrency;

  /// Actifs filtrés par nom ou symbole.
  List<CryptoAsset> get assets {
    final all = _state.data ?? const <CryptoAsset>[];
    if (_query.isEmpty) return all;
    return all
        .where((a) =>
            a.name.toLowerCase().contains(_query) ||
            a.symbol.toLowerCase().contains(_query))
        .toList();
  }

  CryptoAsset? findById(String id) {
    final all = _state.data;
    if (all == null) return null;
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  void setQuery(String query) {
    _query = query.trim().toLowerCase();
    notifyListeners();
  }

  Future<void> load({bool forceRefresh = false}) async {
    final requestId = ++_requestId;
    _state = AsyncState.loading(
      data: _state.data,
      lastUpdated: _state.lastUpdated,
      isStale: _state.isStale,
    );
    notifyListeners();

    try {
      final result = await _repository.getAssets(
        vsCurrency: _settings.vsCurrency,
        forceRefresh: forceRefresh,
      );
      if (requestId != _requestId) return; // Une requête plus récente a démarré.
      _state = AsyncState.success(
        result.data,
        lastUpdated: result.lastUpdated,
        isStale: result.isStale,
      );
    } on Object catch (e) {
      if (requestId != _requestId) return;
      _state = AsyncState.error(
        e,
        data: _state.data,
        lastUpdated: _state.lastUpdated,
      );
    }
    notifyListeners();
  }

  Future<void> changeCurrency(String currency) async {
    if (currency == _settings.vsCurrency) return;
    await _settings.setVsCurrency(currency);
    _state = const AsyncState.initial();
    await load();
  }
}
