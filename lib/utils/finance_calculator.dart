import 'dart:math' as math;

import 'package:projet_investissement_flutter/domain/models/price_point.dart';

/// Calculs financiers sans dépendance à Flutter ni aux entrées-sorties.
class FinanceCalculator {
  const FinanceCalculator._();

  /// Variation en pourcentage. Renvoie null si le départ est invalide.
  static double? variationPercent(double previous, double current) {
    if (previous <= 0 || previous.isNaN || current.isNaN) return null;
    return (current - previous) / previous * 100;
  }

  /// Performance d'un investissement en pourcentage.
  static double? performancePercent(double initialValue, double finalValue) =>
      variationPercent(initialValue, finalValue);

  /// Gain ou perte sur un investissement.
  static double gain(double invested, double currentValue) =>
      currentValue - invested;

  /// Performance entre le premier et le dernier cours.
  static double? seriesPerformance(List<PricePoint> points) {
    if (points.length < 2) return null;
    return variationPercent(points.first.price, points.last.price);
  }

  /// Rendements quotidiens sous forme de fractions.
  static List<double> dailyReturns(List<PricePoint> points) {
    final returns = <double>[];
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1].price;
      if (prev <= 0) continue;
      returns.add((points[i].price - prev) / prev);
    }
    return returns;
  }

  /// Volatilité quotidienne en %. Avec [annualized], annualisée sur 365 jours.
  /// Renvoie null s'il y a moins de deux rendements.
  static double? volatility(List<PricePoint> points, {bool annualized = false}) {
    final r = dailyReturns(points);
    if (r.length < 2) return null;
    final mean = r.reduce((a, b) => a + b) / r.length;
    final variance =
        r.fold<double>(0, (s, x) => s + math.pow(x - mean, 2)) / (r.length - 1);
    var vol = math.sqrt(variance) * 100;
    if (annualized) vol *= math.sqrt(365);
    return vol;
  }

  /// Baisse maximale depuis un sommet, en %. Renvoie null si la série est vide.
  static double? maxDrawdown(List<PricePoint> points) {
    if (points.isEmpty) return null;
    var peak = points.first.price;
    var worst = 0.0;
    for (final p in points) {
      if (p.price > peak) peak = p.price;
      if (peak <= 0) continue;
      final drawdown = (p.price - peak) / peak * 100;
      if (drawdown < worst) worst = drawdown;
    }
    return worst;
  }

  /// Calcule la valeur après application du rendement composé.
  static double compoundValue(double capital, double annualRate, num years) =>
      capital * math.pow(1 + annualRate, years);
}
