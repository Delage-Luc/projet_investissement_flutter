import 'package:projet_investissement_flutter/utils/finance_calculator.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';

/// Paramètres saisis par l'utilisateur pour le simulateur DCA.
class SimulationInput {
  const SimulationInput({
    required this.initialCapital,
    required this.monthlyContribution,
    required this.annualRatePercent,
    required this.years,
    this.cryptoAsset,
  });

  /// Capital de départ.
  final double initialCapital;

  /// Somme investie chaque mois.
  final double monthlyContribution;

  /// Rendement annuel supposé, en % (hypothèse, pas une prédiction).
  final double annualRatePercent;

  /// Durée d'investissement, en années entières.
  final int years;

  /// Crypto dont les cours historiques sont rejoués, ou null pour un taux fixe.
  final CryptoAsset? cryptoAsset;

  bool get isCrypto => cryptoAsset != null;

  factory SimulationInput.fromJson(Map<String, dynamic> json) {
    final asset = json['asset'] as Map<String, dynamic>?;
    return SimulationInput(
      initialCapital: (json['initialCapital'] as num).toDouble(),
      monthlyContribution: (json['monthlyContribution'] as num).toDouble(),
      annualRatePercent: (json['annualRatePercent'] as num).toDouble(),
      years: (json['years'] as num).toInt(),
      cryptoAsset: asset == null ? null : CryptoAsset.fromJson(asset),
    );
  }

  Map<String, dynamic> toJson() => {
    'initialCapital': initialCapital,
    'monthlyContribution': monthlyContribution,
    'annualRatePercent': annualRatePercent,
    'years': years,
    'asset': cryptoAsset?.toJson(),
  };
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

  /// Forme compacte `[mois, investi, valeur]` pour la persistance.
  factory ProjectionPoint.fromJson(List<dynamic> json) => ProjectionPoint(
    month: (json[0] as num).toInt(),
    invested: (json[1] as num).toDouble(),
    value: (json[2] as num).toDouble(),
  );

  List<num> toJson() => [month, invested, value];
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

  factory ProjectionResult.fromJson(List<dynamic> json) => ProjectionResult(
    points: [
      for (final p in json) ProjectionPoint.fromJson(p as List<dynamic>),
    ],
  );

  List<List<num>> toJson() => [for (final p in points) p.toJson()];
}
