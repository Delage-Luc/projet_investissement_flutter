import 'dart:math' as math;

import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/utils/price_series.dart';

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

  /// Rejoue les achats mensuels sur les cours historiques de la crypto choisie.
  static ProjectionResult projectFromHistory(
    SimulationInput input,
    Iterable<PricePoint> history,
  ) {
    if (!_isBaseValid(input) || input.cryptoAsset == null) {
      return ProjectionResult.empty;
    }
    final prices = _monthlyPrices(input.years, history);
    if (prices == null) return ProjectionResult.empty;

    var units = input.initialCapital / prices.first;
    var invested = input.initialCapital;
    final projection = <ProjectionPoint>[
      ProjectionPoint(month: 0, invested: invested, value: invested),
    ];

    for (var month = 1; month < prices.length; month++) {
      final price = prices[month];
      units += input.monthlyContribution / price;
      invested += input.monthlyContribution;
      projection.add(
        ProjectionPoint(month: month, invested: invested, value: units * price),
      );
    }

    return ProjectionResult(points: projection);
  }

  /// Stratégie de comparaison : la même somme totale (capital + tous les
  /// versements) placée en une seule fois au départ, à taux fixe.
  /// La courbe « investi » vaut donc le total dès le mois 0.
  static ProjectionResult lumpSum(SimulationInput input) {
    if (!_isValid(input)) return ProjectionResult.empty;
    final months = input.years * 12;
    final total = _totalContributed(input);
    final monthlyRate =
        math.pow(1 + input.annualRatePercent / 100, 1 / 12).toDouble() - 1;
    return ProjectionResult(
      points: [
        for (var month = 0; month <= months; month++)
          ProjectionPoint(
            month: month,
            invested: total,
            value: total * math.pow(1 + monthlyRate, month),
          ),
      ],
    );
  }

  /// Même comparaison que [lumpSum], mais au cours historique de la crypto :
  /// tout est acheté au cours du premier jour puis valorisé chaque mois.
  static ProjectionResult lumpSumFromHistory(
    SimulationInput input,
    Iterable<PricePoint> history,
  ) {
    if (!_isBaseValid(input) || input.cryptoAsset == null) {
      return ProjectionResult.empty;
    }
    final prices = _monthlyPrices(input.years, history);
    if (prices == null) return ProjectionResult.empty;

    final total = _totalContributed(input);
    final units = total / prices.first;
    return ProjectionResult(
      points: [
        for (var month = 0; month < prices.length; month++)
          ProjectionPoint(
            month: month,
            invested: total,
            value: units * prices[month],
          ),
      ],
    );
  }

  static double _totalContributed(SimulationInput input) =>
      input.initialCapital + input.monthlyContribution * input.years * 12;

  /// Cours retenu pour chaque mois (mois 0 compris) : le dernier cours connu
  /// à la date d'achat. Renvoie null si l'historique ne couvre pas la période.
  static List<double>? _monthlyPrices(int years, Iterable<PricePoint> history) {
    final points = toDailySeries(
      history.where((point) => point.price.isFinite && point.price > 0),
    );
    if (points.isEmpty) return null;

    final start = historyStartDate(years);
    if (points.first.date.isAfter(start)) return null;
    final end = _addMonths(start, years * 12);
    if (end.difference(points.last.date).inDays > 2) return null;

    final prices = <double>[];
    var priceIndex = 0;
    for (var month = 0; month <= years * 12; month++) {
      final purchaseDate = _addMonths(start, month);
      while (priceIndex + 1 < points.length &&
          !points[priceIndex + 1].date.isAfter(purchaseDate)) {
        priceIndex++;
      }
      prices.add(points[priceIndex].price);
    }
    return prices;
  }

  /// Même jour et même mois, un an ou plusieurs auparavant (jour borné au mois).
  static DateTime historyStartDate(int years, {DateTime? now}) {
    final reference = (now ?? DateTime.now()).toUtc();
    final year = reference.year - years;
    final lastDay = DateTime.utc(year, reference.month + 1, 0).day;
    final day = math.min(reference.day, lastDay);
    return DateTime.utc(year, reference.month, day);
  }

  static bool _isValid(SimulationInput input) {
    if (!input.annualRatePercent.isFinite || input.annualRatePercent <= -100) {
      return false;
    }
    return _isBaseValid(input);
  }

  static bool _isBaseValid(SimulationInput input) {
    if (![
      input.initialCapital,
      input.monthlyContribution,
    ].every((n) => n.isFinite)) {
      return false;
    }
    if (input.initialCapital < 0 || input.monthlyContribution < 0) return false;
    if (input.initialCapital + input.monthlyContribution <= 0) return false;
    if (input.years < 1) return false;
    return true;
  }

  static DateTime _addMonths(DateTime date, int months) {
    final monthIndex = date.month - 1 + months;
    final year = date.year + monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    return DateTime.utc(year, month, math.min(date.day, lastDay));
  }
}
