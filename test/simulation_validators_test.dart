import 'package:flutter_test/flutter_test.dart';
import 'package:projet_investissement_flutter/utils/simulation_validators.dart';

void main() {
  group('parseNumber', () {
    test('accepte point et virgule décimale', () {
      expect(SimulationValidators.parseNumber('12.5'), 12.5);
      expect(SimulationValidators.parseNumber('12,5'), 12.5);
    });

    test('ignore les espaces (séparateur de milliers)', () {
      expect(SimulationValidators.parseNumber(' 1 000,5 '), 1000.5);
      expect(SimulationValidators.parseNumber('1\u202F000'), 1000);
    });

    test('rejette le texte, le vide, NaN et Infinity', () {
      expect(SimulationValidators.parseNumber('abc'), isNull);
      expect(SimulationValidators.parseNumber(''), isNull);
      expect(SimulationValidators.parseNumber(null), isNull);
      expect(SimulationValidators.parseNumber('NaN'), isNull);
      expect(SimulationValidators.parseNumber('Infinity'), isNull);
    });
  });

  group('initialCapital', () {
    test('valeurs valides', () {
      expect(SimulationValidators.initialCapital('0'), isNull);
      expect(SimulationValidators.initialCapital('1500,50'), isNull);
    });

    test('vide, invalide, négatif ou trop grand', () {
      expect(SimulationValidators.initialCapital(''), isNotNull);
      expect(SimulationValidators.initialCapital('abc'), isNotNull);
      expect(SimulationValidators.initialCapital('-5'), isNotNull);
      expect(SimulationValidators.initialCapital('2000000000'), isNotNull);
    });
  });

  group('monthlyContribution', () {
    test('valide si le capital initial est renseigné, même avec versement nul', () {
      expect(
        SimulationValidators.monthlyContribution('0', initialValue: '1000'),
        isNull,
      );
    });

    test('invalide si capital et versement sont tous deux nuls', () {
      expect(
        SimulationValidators.monthlyContribution('0', initialValue: '0'),
        isNotNull,
      );
      expect(
        SimulationValidators.monthlyContribution('0', initialValue: ''),
        isNotNull,
      );
    });

    test('rejette un versement négatif ou invalide', () {
      expect(
        SimulationValidators.monthlyContribution('-10', initialValue: '100'),
        isNotNull,
      );
      expect(
        SimulationValidators.monthlyContribution('x', initialValue: '100'),
        isNotNull,
      );
    });
  });

  group('annualRate', () {
    test('valide dans les bornes, bornes incluses', () {
      expect(SimulationValidators.annualRate('7'), isNull);
      expect(SimulationValidators.annualRate('-50'), isNull);
      expect(SimulationValidators.annualRate('100'), isNull);
    });

    test('hors bornes ou invalide', () {
      expect(SimulationValidators.annualRate('-60'), isNotNull);
      expect(SimulationValidators.annualRate('101'), isNotNull);
      expect(SimulationValidators.annualRate(''), isNotNull);
    });
  });

  group('years', () {
    test('entier entre 1 et 50', () {
      expect(SimulationValidators.years('1'), isNull);
      expect(SimulationValidators.years('10'), isNull);
      expect(SimulationValidators.years('50'), isNull);
    });

    test('hors bornes, décimal ou invalide', () {
      expect(SimulationValidators.years('0'), isNotNull);
      expect(SimulationValidators.years('51'), isNotNull);
      expect(SimulationValidators.years('2,5'), isNotNull);
      expect(SimulationValidators.years('abc'), isNotNull);
      expect(SimulationValidators.years(''), isNotNull);
    });
  });
}