import 'package:flutter_test/flutter_test.dart';
import 'package:projet_investissement_flutter/domain/models/dca.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/utils/dca_calculator.dart';

List<PricePoint> daily(DateTime start, List<double> prices) => [
      for (var i = 0; i < prices.length; i++)
        PricePoint(date: start.add(Duration(days: i)), price: prices[i]),
    ];

void main() {
  final jan1 = DateTime.utc(2024, 1, 1);

  test('prix constant : valeur finale = capital investi', () {
    final history = daily(jan1, List.filled(15, 100));
    final r = DcaCalculator.simulate(
      history: history,
      amountPerPeriod: 50,
      frequency: DcaFrequency.weekly,
    );
    expect(r.purchases.length, 3); // 1er, 8 et 15 janvier
    expect(r.totalInvested, 150);
    expect(r.finalValue, closeTo(150, 1e-9));
    expect(r.gain, closeTo(0, 1e-9));
  });

  test('achats à des cours différents : quantités additionnées puis valorisées',
      () {
    // J0-6 : 100 ; J7-13 : 50 ; J14 : 200
    final prices = [
      ...List.filled(7, 100.0),
      ...List.filled(7, 50.0),
      200.0,
    ];
    final r = DcaCalculator.simulate(
      history: daily(jan1, prices),
      amountPerPeriod: 50,
      frequency: DcaFrequency.weekly,
    );
    // 50/100 + 50/50 + 50/200 = 0,5 + 1 + 0,25 = 1,75
    expect(r.totalQuantity, closeTo(1.75, 1e-9));
    expect(r.totalInvested, 150);
    expect(r.finalValue, closeTo(350, 1e-9)); // 1,75 × 200
    expect(r.gain, closeTo(200, 1e-9));
    expect(r.performancePercent, closeTo(133.3333, 1e-3));
  });

  test('mensuel : le 31 janvier ne dérive pas (29 février, 31 mars)', () {
    final start = DateTime.utc(2024, 1, 31);
    final r = DcaCalculator.simulate(
      history: daily(start, List.filled(61, 10)), // jusqu'au 31 mars 2024
      amountPerPeriod: 10,
      frequency: DcaFrequency.monthly,
    );
    expect(r.purchases.map((p) => p.date).toList(), [
      DateTime.utc(2024, 1, 31),
      DateTime.utc(2024, 2, 29),
      DateTime.utc(2024, 3, 31),
    ]);
  });

  test('startDate / endDate restreignent la période simulée', () {
    final r = DcaCalculator.simulate(
      history: daily(jan1, List.filled(30, 100)),
      amountPerPeriod: 10,
      frequency: DcaFrequency.weekly,
      startDate: DateTime.utc(2024, 1, 8),
      endDate: DateTime.utc(2024, 1, 21),
    );
    expect(r.purchases.length, 2); // 8 et 15 janvier
  });

  group('cas limites', () {
    test('historique vide -> résultat vide', () {
      final r = DcaCalculator.simulate(
        history: const [],
        amountPerPeriod: 50,
        frequency: DcaFrequency.monthly,
      );
      expect(r.isEmpty, isTrue);
      expect(r.performancePercent, isNull);
    });

    test('montant nul ou négatif -> résultat vide', () {
      final history = daily(jan1, List.filled(10, 100));
      for (final amount in [0.0, -10.0]) {
        final r = DcaCalculator.simulate(
          history: history,
          amountPerPeriod: amount,
          frequency: DcaFrequency.weekly,
        );
        expect(r.isEmpty, isTrue);
      }
    });

    test('dates incohérentes (fin avant début) -> résultat vide', () {
      final r = DcaCalculator.simulate(
        history: daily(jan1, List.filled(10, 100)),
        amountPerPeriod: 50,
        frequency: DcaFrequency.weekly,
        startDate: DateTime.utc(2024, 1, 10),
        endDate: DateTime.utc(2024, 1, 2),
      );
      expect(r.isEmpty, isTrue);
    });

    test('cours à zéro ignoré (pas de division par zéro)', () {
      final r = DcaCalculator.simulate(
        history: daily(jan1, [0, 0, 0, 0, 0, 0, 0, 100]),
        amountPerPeriod: 50,
        frequency: DcaFrequency.weekly,
      );
      expect(r.totalQuantity.isFinite, isTrue);
    });
  });
}
