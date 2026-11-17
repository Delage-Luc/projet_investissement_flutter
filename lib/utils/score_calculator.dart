import 'package:projet_investissement_flutter/domain/models/asset_score.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/utils/finance_calculator.dart';

/// Score pédagogique sur 100, calculé à partir de trois critères
/// observés sur la période. Chaque critère est ramené entre 0 et 100 par une
/// règle linéaire bornée, puis pondéré :
///
/// | Critère                 | 0 point       | 100 points  | Poids |
/// |-------------------------|---------------|-------------|-------|
/// | Performance             | ≤ −50 %       | ≥ +50 %     | 40 %  |
/// | Stabilité (vol. annuelle)| ≥ 120 %      | ≤ 20 %      | 30 %  |
/// | Résistance aux baisses  | ≤ −80 %       | 0 %         | 30 %  |
///
/// Le score décrit le passé : il ne prédit pas les performances futures.
class ScoreCalculator {
  const ScoreCalculator._();

  static const double performanceWeight = 0.4;
  static const double stabilityWeight = 0.3;
  static const double resilienceWeight = 0.3;

  /// Renvoie null si l'historique est trop court pour les trois critères.
  static AssetScore? score(List<PricePoint> points) {
    final performance = FinanceCalculator.seriesPerformance(points);
    final volatility = FinanceCalculator.volatility(points, annualized: true);
    final drawdown = FinanceCalculator.maxDrawdown(points);
    if (performance == null || volatility == null || drawdown == null) {
      return null;
    }

    return AssetScore(
      criteria: [
        ScoreCriterion(
          label: 'Performance',
          measured: performance,
          score: linearScore(performance, zeroAt: -50, fullAt: 50),
          weight: performanceWeight,
          rule: '−50 % ou moins = 0 point, +50 % ou plus = 100 points.',
        ),
        ScoreCriterion(
          label: 'Stabilité',
          measured: volatility,
          score: linearScore(volatility, zeroAt: 120, fullAt: 20),
          weight: stabilityWeight,
          rule:
              'Volatilité annuelle de 20 % ou moins = 100 points, '
              '120 % ou plus = 0 point.',
        ),
        ScoreCriterion(
          label: 'Résistance aux baisses',
          measured: drawdown,
          score: linearScore(drawdown, zeroAt: -80, fullAt: 0),
          weight: resilienceWeight,
          rule: 'Aucune baisse = 100 points, une chute de 80 % ou plus = 0 point.',
        ),
      ],
    );
  }

  /// Interpolation linéaire bornée : [zeroAt] → 0, [fullAt] → 100.
  /// Fonctionne aussi quand [fullAt] < [zeroAt] (plus petit = meilleur).
  static double linearScore(
    double value, {
    required double zeroAt,
    required double fullAt,
  }) {
    if (zeroAt == fullAt || value.isNaN) return 0;
    final ratio = (value - zeroAt) / (fullAt - zeroAt);
    return (ratio.clamp(0.0, 1.0)) * 100;
  }
}
