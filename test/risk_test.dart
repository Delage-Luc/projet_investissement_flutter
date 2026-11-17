import 'package:flutter_test/flutter_test.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/domain/models/risk.dart';
import 'package:projet_investissement_flutter/utils/finance_calculator.dart';

List<PricePoint> series(List<double> prices) => [
  for (var i = 0; i < prices.length; i++)
    PricePoint(date: DateTime.utc(2024, 1, 1 + i), price: prices[i]),
];

void main() {
  group('maxDrawdownDetails', () {
    test('exemple du sujet : sommet 125 (index 2), creux 90 (index 4)', () {
      final info = FinanceCalculator.maxDrawdownDetails(
        series([100, 110, 125, 115, 90, 105]),
      )!;
      expect(info.peakIndex, 2);
      expect(info.troughIndex, 4);
      expect(info.peak.price, 125);
      expect(info.trough.price, 90);
      expect(info.percent, closeTo(-28, 1e-9));
      expect(info.durationDays, 2);
      expect(info.hasDecline, isTrue);
    });

    test('garde la pire baisse, pas la dernière', () {
      // Baisse de 50 % (200 -> 100) puis baisse de 20 % (300 -> 240).
      final info = FinanceCalculator.maxDrawdownDetails(
        series([200, 100, 300, 240]),
      )!;
      expect(info.peakIndex, 0);
      expect(info.troughIndex, 1);
      expect(info.percent, closeTo(-50, 1e-9));
    });

    test('série croissante : aucune baisse', () {
      final info = FinanceCalculator.maxDrawdownDetails(series([1, 2, 3]))!;
      expect(info.percent, 0);
      expect(info.hasDecline, isFalse);
    });

    test('série vide -> null', () {
      expect(FinanceCalculator.maxDrawdownDetails(const []), isNull);
    });
  });

  group('whatIfInvested', () {
    test('100 € quand le prix passe de 50 à 75 -> 150 €', () {
      expect(FinanceCalculator.whatIfInvested(100, series([50, 60, 75])), 150);
    });

    test('montant nul -> 0', () {
      expect(FinanceCalculator.whatIfInvested(0, series([50, 75])), 0);
    });

    test(
      'moins de 2 points, prix de départ nul ou montant négatif -> null',
      () {
        expect(FinanceCalculator.whatIfInvested(100, series([50])), isNull);
        expect(FinanceCalculator.whatIfInvested(100, series([0, 10])), isNull);
        expect(FinanceCalculator.whatIfInvested(-1, series([5, 10])), isNull);
      },
    );
  });

  group('upDownDays', () {
    test('compte les hausses et les baisses, ignore les jours stables', () {
      final r = FinanceCalculator.upDownDays(series([1, 2, 2, 1, 3]));
      expect(r.up, 2);
      expect(r.down, 1);
    });

    test('série vide -> 0 / 0', () {
      final r = FinanceCalculator.upDownDays(const []);
      expect(r.up, 0);
      expect(r.down, 0);
    });
  });

  group('VolatilityLevel.fromAnnualized', () {
    test('seuils à 30 % et 70 %, bornes incluses dans le niveau supérieur', () {
      expect(VolatilityLevel.fromAnnualized(0), VolatilityLevel.low);
      expect(VolatilityLevel.fromAnnualized(29.9), VolatilityLevel.low);
      expect(VolatilityLevel.fromAnnualized(30), VolatilityLevel.moderate);
      expect(VolatilityLevel.fromAnnualized(69.9), VolatilityLevel.moderate);
      expect(VolatilityLevel.fromAnnualized(70), VolatilityLevel.high);
    });
  });
}
