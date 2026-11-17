import 'dart:math' as math;

import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/domain/models/risk.dart';

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
  static double? maxDrawdown(List<PricePoint> points) =>
      maxDrawdownDetails(points)?.percent;

  /// Baisse maximale avec le sommet et le creux correspondants.
  /// Sans aucune baisse, le sommet et le creux sont le premier point.
  /// Renvoie null si la série est vide.
  static DrawdownInfo? maxDrawdownDetails(List<PricePoint> points) {
    if (points.isEmpty) return null;
    var peakIndex = 0;
    var bestPeak = 0;
    var bestTrough = 0;
    var worst = 0.0;
    for (var i = 0; i < points.length; i++) {
      if (points[i].price > points[peakIndex].price) peakIndex = i;
      final peak = points[peakIndex].price;
      if (peak <= 0) continue;
      final drawdown = (points[i].price - peak) / peak * 100;
      if (drawdown < worst) {
        worst = drawdown;
        bestPeak = peakIndex;
        bestTrough = i;
      }
    }
    return DrawdownInfo(
      peakIndex: bestPeak,
      troughIndex: bestTrough,
      peak: points[bestPeak],
      trough: points[bestTrough],
      percent: worst,
    );
  }

  /// Valeur qu'aurait aujourd'hui [amount] investi au premier cours de la
  /// série et revendu au dernier. Renvoie null si le calcul est impossible.
  static double? whatIfInvested(double amount, List<PricePoint> points) {
    if (points.length < 2 || amount < 0 || !amount.isFinite) return null;
    final first = points.first.price;
    if (first <= 0) return null;
    return amount * points.last.price / first;
  }

  /// Nombre de jours de hausse et de baisse (jours stables exclus).
  static ({int up, int down}) upDownDays(List<PricePoint> points) {
    var up = 0;
    var down = 0;
    for (var i = 1; i < points.length; i++) {
      final delta = points[i].price - points[i - 1].price;
      if (delta > 0) up++;
      if (delta < 0) down++;
    }
    return (up: up, down: down);
  }

  /// Calcule la valeur après application du rendement composé.
  static double compoundValue(double capital, double annualRate, num years) =>
      capital * math.pow(1 + annualRate, years);
}
