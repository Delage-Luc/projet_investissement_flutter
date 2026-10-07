import 'dart:math' as math;

import 'package:projet_investissement_flutter/domain/models/projection.dart';

/// Projection d'un investissement régulier à rendement annuel constant.
///
/// Hypothèses (à rappeler à l'utilisateur) :
///  - le taux annuel est converti en taux mensuel équivalent
///    (1 + taux)^(1/12) - 1, de sorte que 12 mois = exactement 1 an ;
///  - le versement du mois est ajouté en fin de mois, après les intérêts ;
///  - le rendement est constant : un vrai marché ne l'est jamais.
class ProjectionCalculator {
  const ProjectionCalculator._();

  /// Renvoie [ProjectionResult.empty] si les paramètres sont invalides.
  static ProjectionResult project(SimulationInput input) {
    if (!_isValid(input)) return ProjectionResult.empty;

    final months = input.years * 12;
    final monthlyRate =
        math.pow(1 + input.annualRatePercent / 100, 1 / 12).toDouble() - 1;

    var value = input.initialCapital;
    var invested = input.initialCapital;
    final points = <ProjectionPoint>[
      ProjectionPoint(month: 0, invested: invested, value: value),
    ];

    for (var month = 1; month <= months; month++) {
      value = value * (1 + monthlyRate) + input.monthlyContribution;
      invested += input.monthlyContribution;
      points.add(ProjectionPoint(month: month, invested: invested, value: value));
    }
    return ProjectionResult(points: points);
  }

  static bool _isValid(SimulationInput input) {
    final numbers = [
      input.initialCapital,
      input.monthlyContribution,
      input.annualRatePercent,
    ];
    if (numbers.any((n) => !n.isFinite)) return false;
    if (input.initialCapital < 0 || input.monthlyContribution < 0) return false;
    if (input.initialCapital + input.monthlyContribution <= 0) return false;
    if (input.years < 1) return false;
    if (input.annualRatePercent <= -100) return false;
    return true;
  }
}