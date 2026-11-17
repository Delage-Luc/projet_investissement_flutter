import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/utils/projection_calculator.dart';

const bitcoin = CryptoAsset(
  id: 'bitcoin',
  symbol: 'btc',
  name: 'Bitcoin',
  currentPrice: 200,
);

void main() {
  group('lumpSum (taux fixe)', () {
    test('place tout le total au départ et le capitalise', () {
      final result = ProjectionCalculator.lumpSum(
        const SimulationInput(
          initialCapital: 1000,
          monthlyContribution: 100,
          annualRatePercent: 5,
          years: 2,
        ),
      );
      // 1000 + 24 × 100 = 3400 placés dès le mois 0.
      expect(result.points, hasLength(25));
      expect(result.points.first.invested, 3400);
      expect(result.totalInvested, 3400);
      expect(result.finalValue, closeTo(3400 * math.pow(1.05, 2), 1e-6));
    });

    test('avec un rendement positif, investir tout de suite rapporte plus', () {
      const input = SimulationInput(
        initialCapital: 0,
        monthlyContribution: 100,
        annualRatePercent: 7,
        years: 5,
      );
      expect(
        ProjectionCalculator.lumpSum(input).finalValue,
        greaterThan(ProjectionCalculator.project(input).finalValue),
      );
    });

    test('paramètres invalides -> résultat vide', () {
      expect(
        ProjectionCalculator.lumpSum(
          const SimulationInput(
            initialCapital: 0,
            monthlyContribution: 0,
            annualRatePercent: 5,
            years: 1,
          ),
        ).isEmpty,
        isTrue,
      );
    });
  });

  group('lumpSumFromHistory', () {
    test('achète tout au premier cours et valorise au dernier', () {
      final start = ProjectionCalculator.historyStartDate(1);
      final history = [
        PricePoint(date: start, price: 100),
        PricePoint(
          date: DateTime.utc(start.year + 1, start.month, start.day),
          price: 150,
        ),
      ];
      const input = SimulationInput(
        initialCapital: 1000,
        monthlyContribution: 100,
        annualRatePercent: 0,
        years: 1,
        cryptoAsset: bitcoin,
      );

      final lump = ProjectionCalculator.lumpSumFromHistory(input, history);
      expect(lump.points, hasLength(13));
      expect(lump.totalInvested, 2200);
      // 2200 / 100 = 22 unités, valorisées 150.
      expect(lump.finalValue, closeTo(3300, 1e-9));

      // Le DCA, lui, achète surtout au cours de 100 (gardé jusqu'à la fin) :
      // il a payé moins cher que le cours final mais investi plus tard.
      final dca = ProjectionCalculator.projectFromHistory(input, history);
      expect(dca.totalInvested, lump.totalInvested);
    });

    test('historique ne couvrant pas la période -> résultat vide', () {
      final lump = ProjectionCalculator.lumpSumFromHistory(
        const SimulationInput(
          initialCapital: 100,
          monthlyContribution: 0,
          annualRatePercent: 0,
          years: 1,
          cryptoAsset: bitcoin,
        ),
        [PricePoint(date: DateTime.now().toUtc(), price: 200)],
      );
      expect(lump.isEmpty, isTrue);
    });
  });
}
