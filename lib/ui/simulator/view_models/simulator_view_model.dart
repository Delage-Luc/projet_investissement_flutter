import 'package:flutter/foundation.dart';
import 'package:projet_investissement_flutter/data/clients/api_exceptions.dart';
import 'package:projet_investissement_flutter/data/repositories/market_repository.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/utils/projection_calculator.dart';

/// État du simulateur : « pas encore de simulation » ou « résultat disponible ».
/// Le calcul est délégué à [ProjectionCalculator] : aucune formule ici.
class SimulatorViewModel extends ChangeNotifier {
  SimulatorViewModel({required MarketRepository repository})
      : _repository = repository;

  final MarketRepository _repository;
  SimulationInput? _input;
  ProjectionResult _result = ProjectionResult.empty;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isResultStale = false;
  int _requestId = 0;

  SimulationInput? get input => _input;
  ProjectionResult get result => _result;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isResultStale => _isResultStale;
  bool get hasResult => !_result.isEmpty;

  Future<void> simulate(SimulationInput input, {required String vsCurrency}) async {
    final requestId = ++_requestId;
    _errorMessage = null;
    _isResultStale = false;

    if (input.cryptoAsset == null) {
      _input = input;
      _result = ProjectionCalculator.project(input);
      _isLoading = false;
      notifyListeners();
      return;
    }

    _input = null;
    _result = ProjectionResult.empty;
    _isLoading = true;
    notifyListeners();

    try {
      final start = ProjectionCalculator.historyStartDate(input.years);
      final history = await _repository.getHistory(
        assetId: input.cryptoAsset!.id,
        vsCurrency: vsCurrency,
        from: start,
      );
      if (requestId != _requestId) return;

      final result = ProjectionCalculator.projectFromHistory(input, history.data);
      if (result.isEmpty) {
        throw StateError(
          "L'historique de ${input.cryptoAsset!.name} ne couvre pas toute "
          "la période demandée. Réduis la durée de simulation.",
        );
      }
      _input = input;
      _result = result;
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
        notifyListeners();
      }
    }
  }

  void reset() {
    _requestId++;
    _input = null;
    _result = ProjectionResult.empty;
    _errorMessage = null;
    _isLoading = false;
    _isResultStale = false;
    notifyListeners();
  }
}