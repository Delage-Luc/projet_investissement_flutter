import 'package:flutter/foundation.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/utils/projection_calculator.dart';

/// État du simulateur : « pas encore de simulation » ou « résultat disponible ».
/// Le calcul est délégué à [ProjectionCalculator] : aucune formule ici.
class SimulatorViewModel extends ChangeNotifier {
  SimulationInput? _input;
  ProjectionResult _result = ProjectionResult.empty;

  SimulationInput? get input => _input;
  ProjectionResult get result => _result;
  bool get hasResult => !_result.isEmpty;

  void simulate(SimulationInput input) {
    _input = input;
    _result = ProjectionCalculator.project(input);
    notifyListeners();
  }

  void reset() {
    _input = null;
    _result = ProjectionResult.empty;
    notifyListeners();
  }
}