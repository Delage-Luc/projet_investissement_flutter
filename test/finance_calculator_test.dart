import 'package:flutter_test/flutter_test.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/utils/finance_calculator.dart';

/// Série quotidienne à partir de prix successifs.
List<PricePoint> series(List<double> prices) => [
      for (var i = 0; i < prices.length; i++)
        PricePoint(date: DateTime.utc(2024, 1, 1 + i), price: prices[i]),
    ];

void main() {
  group('variationPercent / performancePercent', () {
    test('100 -> 120 donne +20 %', () {
      expect(FinanceCalculator.performancePercent(100, 120), closeTo(20, 1e-9));
    });

    test('une baisse donne un pourcentage négatif', () {
      expect(FinanceCalculator.variationPercent(200, 150), closeTo(-25, 1e-9));
    });

    test('valeur initiale nulle ou négative -> null (pas de division par zéro)',
        () {
      expect(FinanceCalculator.variationPercent(0, 10), isNull);
      expect(FinanceCalculator.variationPercent(-5, 10), isNull);
    });

    test('valeur NaN -> null', () {
      expect(FinanceCalculator.variationPercent(double.nan, 10), isNull);
      expect(FinanceCalculator.variationPercent(10, double.nan), isNull);
    });
  });

  group('gain', () {
    test('1000 investis, valeur 1180 -> +180', () {
      expect(FinanceCalculator.gain(1000, 1180), 180);
    });
  });

  group('seriesPerformance', () {
    test('compare le premier et le dernier point', () {
      expect(FinanceCalculator.seriesPerformance(series([50, 80, 75])),
          closeTo(50, 1e-9));
    });

    test('moins de 2 points -> null', () {
      expect(FinanceCalculator.seriesPerformance(series([])), isNull);
      expect(FinanceCalculator.seriesPerformance(series([10])), isNull);
    });
  });

  group('volatility', () {
    test('100, 110, 99 -> écart-type des rendements ≈ 14,142 %', () {
      expect(FinanceCalculator.volatility(series([100, 110, 99])),
          closeTo(14.1421, 1e-3));
    });

    test('prix constant -> volatilité nulle', () {
      expect(FinanceCalculator.volatility(series([10, 10, 10, 10])), 0);
    });

    test('annualisée = journalière × racine(365)', () {
      final s = series([100, 110, 99]);
      final daily = FinanceCalculator.volatility(s)!;
      final yearly = FinanceCalculator.volatility(s, annualized: true)!;
      expect(yearly, closeTo(daily * 19.1049731745, 1e-3));
    });

    test('historique trop court -> null', () {
      expect(FinanceCalculator.volatility(series([])), isNull);
      expect(FinanceCalculator.volatility(series([100, 110])), isNull);
    });
  });

  group('maxDrawdown', () {
    test('exemple du sujet : 100,110,125,115,90,105 -> -28 %', () {
      expect(
        FinanceCalculator.maxDrawdown(series([100, 110, 125, 115, 90, 105])),
        closeTo(-28, 1e-9),
      );
    });

    test('série toujours croissante -> 0', () {
      expect(FinanceCalculator.maxDrawdown(series([1, 2, 3, 4])), 0);
    });

    test('série vide -> null', () {
      expect(FinanceCalculator.maxDrawdown(series([])), isNull);
    });
  });

  group('compoundValue', () {
    test('1000 € à 5 % pendant 10 ans ≈ 1628,89 €', () {
      expect(FinanceCalculator.compoundValue(1000, 0.05, 10),
          closeTo(1628.89, 0.01));
    });
  });
}
