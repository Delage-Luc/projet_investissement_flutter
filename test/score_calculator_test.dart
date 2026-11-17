import 'package:flutter_test/flutter_test.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/utils/score_calculator.dart';

List<PricePoint> series(List<double> prices) => [
  for (var i = 0; i < prices.length; i++)
    PricePoint(date: DateTime.utc(2024, 1, 1 + i), price: prices[i]),
];

void main() {
  group('linearScore', () {
    test('interpole entre les deux bornes', () {
      expect(ScoreCalculator.linearScore(0, zeroAt: -50, fullAt: 50), 50);
      expect(ScoreCalculator.linearScore(25, zeroAt: -50, fullAt: 50), 75);
    });

    test('borne à 0 et 100 en dehors de l\'intervalle', () {
      expect(ScoreCalculator.linearScore(-90, zeroAt: -50, fullAt: 50), 0);
      expect(ScoreCalculator.linearScore(400, zeroAt: -50, fullAt: 50), 100);
    });

    test('fonctionne quand une valeur plus petite est meilleure', () {
      expect(ScoreCalculator.linearScore(20, zeroAt: 120, fullAt: 20), 100);
      expect(ScoreCalculator.linearScore(70, zeroAt: 120, fullAt: 20), 50);
      expect(ScoreCalculator.linearScore(200, zeroAt: 120, fullAt: 20), 0);
    });

    test('bornes identiques ou valeur NaN -> 0 (pas de division par zéro)', () {
      expect(ScoreCalculator.linearScore(5, zeroAt: 1, fullAt: 1), 0);
      expect(ScoreCalculator.linearScore(double.nan, zeroAt: 0, fullAt: 1), 0);
    });
  });

  group('score', () {
    test('prix constant : performance 50, stabilité 100, résistance 100', () {
      final score = ScoreCalculator.score(series([10, 10, 10, 10]))!;
      expect(score.criteria.map((c) => c.score), [50, 100, 100]);
      // 50 × 0,4 + 100 × 0,3 + 100 × 0,3
      expect(score.total, closeTo(80, 1e-9));
    });

    test('les poids totalisent 1', () {
      final score = ScoreCalculator.score(series([10, 11, 9, 12]))!;
      final weights = score.criteria.fold<double>(0, (s, c) => s + c.weight);
      expect(weights, closeTo(1, 1e-9));
    });

    test('le total reste entre 0 et 100 même pour une chute brutale', () {
      final score = ScoreCalculator.score(series([100, 10, 5, 1]))!;
      expect(score.total, inInclusiveRange(0, 100));
      expect(score.criteria.last.score, 0); // chute de 99 %
    });

    test('historique trop court -> null', () {
      expect(ScoreCalculator.score(series([10, 11])), isNull);
      expect(ScoreCalculator.score(const []), isNull);
    });
  });
}
