import 'package:projet_investissement_flutter/utils/finance_calculator.dart';

/// Paramètres saisis par l'utilisateur pour le simulateur DCA.
class SimulationInput {
  const SimulationInput({
    required this.initialCapital,
    required this.monthlyContribution,
    required this.annualRatePercent,
    required this.years,
  });

  /// Capital de départ.
  final double initialCapital;

  /// Somme investie chaque mois.
  final double monthlyContribution;

  /// Rendement annuel supposé, en % (hypothèse, pas une prédiction).
  final double annualRatePercent;

  /// Durée d'investissement, en années entières.
  final int years;
}

/// État du portefeuille simulé à la fin d'un mois.
class ProjectionPoint {
  const ProjectionPoint({
    required this.month,
    required this.invested,
    required this.value,
  });

  final int month;

  /// Total versé depuis le début (capital + versements).
  final double invested;

  /// Valeur du portefeuille avec les intérêts composés.
  final double value;
}

/// Résultat d'une simulation : un point par mois, du mois 0 au dernier mois.
class ProjectionResult {
  const ProjectionResult({required this.points});

  static const ProjectionResult empty = ProjectionResult(points: []);

  final List<ProjectionPoint> points;

  bool get isEmpty => points.isEmpty;
  double get totalInvested => points.isEmpty ? 0 : points.last.invested;
  double get finalValue => points.isEmpty ? 0 : points.last.value;
  double get gain => finalValue - totalInvested;

  /// null si rien n'a été versé (évite la division par zéro).
  double? get performancePercent =>
      FinanceCalculator.variationPercent(totalInvested, finalValue);
}