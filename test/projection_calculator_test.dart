import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/utils/projection_calculator.dart';

SimulationInput input({
  double initial = 0,
  double monthly = 0,
  double rate = 0,
  int years = 1,
}) =>
    SimulationInput(
      initialCapital: initial,
      monthlyContribution: monthly,
      annualRatePercent: rate,
      years: years,
    );

void main() {
  group('project', () {
    test('1000 € à 5 % pendant 10 ans sans versement ≈ 1628,89 €', () {
      final r = ProjectionCalculator.project(input(initial: 1000, rate: 5, years: 10));
      expect(r.finalValue, closeTo(1628.89, 0.01));
      expect(r.totalInvested, 1000);
    });

    test('un point par mois, du mois 0 au dernier mois', () {
      final r = ProjectionCalculator.project(input(initial: 100, years: 10));
      expect(r.points.length, 121);
      expect(r.points.first.month, 0);
      expect(r.points.last.month, 120);
    });

    test('rendement nul : la valeur est exactement le capital versé', () {
      final r = ProjectionCalculator.project(
        input(initial: 1000, monthly: 100, rate: 0, years: 1),
      );
      expect(r.totalInvested, 2200);
      expect(r.finalValue, closeTo(2200, 1e-9));
      expect(r.gain, closeTo(0, 1e-9));
      expect(r.performancePercent, closeTo(0, 1e-9));
    });

    test('versements mensuels seuls : formule de la rente à 12 % par an', () {
      final r = ProjectionCalculator.project(
        input(monthly: 100, rate: 12, years: 1),
      );
      final monthlyRate = math.pow(1.12, 1 / 12) - 1;
      final expected = 100 * (math.pow(1 + monthlyRate, 12) - 1) / monthlyRate;
      expect(r.finalValue, closeTo(expected, 1e-6));
      expect(r.totalInvested, 1200);
    });

    test('rendement négatif : la valeur finale est inférieure au capital versé',
        () {
      final r = ProjectionCalculator.project(
        input(initial: 1000, rate: -10, years: 2),
      );
      expect(r.finalValue, closeTo(810, 0.01)); // 1000 × 0,9²
      expect(r.gain, lessThan(0));
      expect(r.performancePercent, closeTo(-19, 0.01));
    });
  });

  group('paramètres invalides -> résultat vide', () {
    test('capital négatif', () {
      expect(ProjectionCalculator.project(input(initial: -1, monthly: 10)).isEmpty,
          isTrue);
    });

    test('versement négatif', () {
      expect(ProjectionCalculator.project(input(initial: 10, monthly: -5)).isEmpty,
          isTrue);
    });

    test('capital et versement tous deux nuls', () {
      expect(ProjectionCalculator.project(input()).isEmpty, isTrue);
    });

    test('durée nulle', () {
      expect(ProjectionCalculator.project(input(initial: 100, years: 0)).isEmpty,
          isTrue);
    });

    test('rendement de -100 % ou moins', () {
      expect(ProjectionCalculator.project(input(initial: 100, rate: -100)).isEmpty,
          isTrue);
    });

    test('valeur non finie', () {
      expect(
        ProjectionCalculator.project(input(initial: double.infinity)).isEmpty,
        isTrue,
      );
      expect(
        ProjectionCalculator.project(input(initial: 100, rate: double.nan)).isEmpty,
        isTrue,
      );
    });

    test('un résultat vide a des totaux nuls et pas de performance', () {
      expect(ProjectionResult.empty.finalValue, 0);
      expect(ProjectionResult.empty.gain, 0);
      expect(ProjectionResult.empty.performancePercent, isNull);
    });
  });
}