import 'package:flutter/foundation.dart';
import 'package:projet_investissement_flutter/data/clients/api_exceptions.dart';
import 'package:projet_investissement_flutter/data/repositories/market_repository.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/domain/models/saved_simulation.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:projet_investissement_flutter/utils/projection_calculator.dart';

/// État du simulateur : « pas encore de simulation » ou « résultat disponible ».
/// Le calcul est délégué à [ProjectionCalculator] : aucune formule ici.
class SimulatorViewModel extends ChangeNotifier {
  SimulatorViewModel({
    required MarketRepository repository,
    required SettingsViewModel settings,
  }) : _repository = repository,
       _settings = settings {
    _settings.addListener(_onSettingsChanged);
  }

  final MarketRepository _repository;
  final SettingsViewModel _settings;
  SimulationInput? _input;

  /// Dernière simulation demandée, même si elle est en cours ou a échoué.
  SimulationInput? _requested;
  String? _requestedCurrency;
  ProjectionResult _result = ProjectionResult.empty;
  ProjectionResult _lumpSum = ProjectionResult.empty;
  String? _resultCurrency;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isResultStale = false;
  bool _disposed = false;
  int _requestId = 0;

  SimulationInput? get input => _input;
  ProjectionResult get result => _result;

  /// Même somme investie en une fois au départ (comparaison pédagogique).
  ProjectionResult get lumpSum => _lumpSum;

  /// Devise dans laquelle le résultat affiché a été calculé.
  String get resultCurrency => _resultCurrency ?? _settings.vsCurrency;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isResultStale => _isResultStale;
  bool get hasResult => !_result.isEmpty;

  Future<void> simulate(SimulationInput input) async {
    final requestId = ++_requestId;
    final vsCurrency = _settings.vsCurrency;
    _requested = input;
    _requestedCurrency = vsCurrency;
    _errorMessage = null;
    _isResultStale = false;

    if (!input.isCrypto) {
      _input = input;
      _result = ProjectionCalculator.project(input);
      _lumpSum = ProjectionCalculator.lumpSum(input);
      _resultCurrency = vsCurrency;
      _isLoading = false;
      _notify();
      return;
    }

    _input = null;
    _result = _lumpSum = ProjectionResult.empty;
    _isLoading = true;
    _notify();

    try {
      final start = ProjectionCalculator.historyStartDate(input.years);
      final history = await _repository.getHistory(
        assetId: input.cryptoAsset!.id,
        vsCurrency: vsCurrency,
        from: start,
      );
      if (requestId != _requestId) return;

      final result = ProjectionCalculator.projectFromHistory(
        input,
        history.data,
      );
      if (result.isEmpty) {
        throw StateError(
          "L'historique de ${input.cryptoAsset!.name} ne couvre pas toute "
          "la période demandée. Réduis la durée de simulation.",
        );
      }
      _input = input;
      _result = result;
      _lumpSum = ProjectionCalculator.lumpSumFromHistory(input, history.data);
      _resultCurrency = vsCurrency;
      _isResultStale = history.isStale;
    } on ApiException catch (error) {
      if (requestId != _requestId) return;
      _errorMessage = error.message;
    } on Object catch (error) {
      if (requestId != _requestId) return;
      _errorMessage = error.toString().replaceFirst('Bad state: ', '');
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        _notify();
      }
    }
  }

  /// Prépare l'enregistrement du résultat affiché (null s'il n'y en a pas).
  SavedSimulation? toSaved(String name) {
    final input = _input;
    if (input == null || !hasResult) return null;
    return SavedSimulation(
      name: name,
      createdAt: DateTime.now().toUtc(),
      vsCurrency: resultCurrency,
      input: input,
      result: _result,
      lumpSum: _lumpSum,
    );
  }

  void reset() {
    _requestId++;
    _requested = null;
    _input = null;
    _result = _lumpSum = ProjectionResult.empty;
    _resultCurrency = null;
    _errorMessage = null;
    _isLoading = false;
    _isResultStale = false;
    _notify();
  }

  /// Un résultat calculé dans une autre devise n'est plus valable : on relance
  /// la même simulation (en mode crypto, les cours de la nouvelle devise sont
  /// rechargés).
  void _onSettingsChanged() {
    final input = _requested;
    if (input == null) return;
    // Ex. : seul le thème a changé.
    if (_requestedCurrency == _settings.vsCurrency) return;
    simulate(input); // annule aussi une requête lancée dans l'ancienne devise
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }
}
