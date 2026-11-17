import 'package:projet_investissement_flutter/domain/models/price_point.dart';

/// Plus forte baisse d'une série : le sommet, le creux qui suit et l'écart.
class DrawdownInfo {
  const DrawdownInfo({
    required this.peakIndex,
    required this.troughIndex,
    required this.peak,
    required this.trough,
    required this.percent,
  });

  /// Positions du sommet et du creux dans la série analysée.
  final int peakIndex;
  final int troughIndex;

  final PricePoint peak;
  final PricePoint trough;

  /// Baisse en % (négative, ou 0 si la série n'a jamais baissé).
  final double percent;

  /// Vrai si la série a effectivement connu une baisse.
  bool get hasDecline => percent < 0 && troughIndex > peakIndex;

  /// Nombre de jours entre le sommet et le creux.
  int get durationDays => trough.date.difference(peak.date).inDays;
}

/// Niveau de volatilité annualisée, traduit pour un débutant.
enum VolatilityLevel {
  low(
    'faible',
    'le prix bouge peu : c\'est l\'ordre de grandeur d\'un grand indice '
        'boursier (souvent 15 à 20 % par an).',
  ),
  moderate(
    'modérée',
    'le prix varie nettement : des hausses ou des baisses de 10 % en '
        'quelques semaines sont courantes.',
  ),
  high(
    'forte',
    'le prix peut gagner ou perdre beaucoup en peu de temps : un placement '
        'à n\'envisager qu\'avec une somme que l\'on accepte de voir baisser.',
  );

  const VolatilityLevel(this.label, this.meaning);

  final String label;
  final String meaning;

  /// Seuils (volatilité annualisée en %) : < 30 faible, < 70 modérée.
  static const double lowThreshold = 30;
  static const double highThreshold = 70;

  static VolatilityLevel fromAnnualized(double volatilityPercent) {
    if (volatilityPercent < lowThreshold) return VolatilityLevel.low;
    if (volatilityPercent < highThreshold) return VolatilityLevel.moderate;
    return VolatilityLevel.high;
  }
}
