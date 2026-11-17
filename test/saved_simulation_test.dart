import 'package:flutter_test/flutter_test.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/domain/models/saved_simulation.dart';
import 'package:projet_investissement_flutter/ui/saved_simulations/widgets/save_simulation_dialog.dart';
import 'package:projet_investissement_flutter/utils/projection_calculator.dart';

void main() {
  group('SavedSimulation toRow / fromRow', () {
    test('taux fixe : paramètres, résultats et devise sont conservés', () {
      const input = SimulationInput(
        initialCapital: 1000,
        monthlyContribution: 100,
        annualRatePercent: 7,
        years: 3,
      );
      final original = SavedSimulation(
        id: 4,
        name: 'Mon test',
        createdAt: DateTime.utc(2026, 11, 17, 10, 30),
        vsCurrency: 'usd',
        input: input,
        result: ProjectionCalculator.project(input),
        lumpSum: ProjectionCalculator.lumpSum(input),
      );

      final row = original.toRow();
      expect(row['type'], SavedSimulation.typeFixedRate);
      final copy = SavedSimulation.fromRow(row);

      expect(copy.id, 4);
      expect(copy.name, 'Mon test');
      expect(copy.createdAt, original.createdAt);
      expect(copy.vsCurrency, 'usd');
      expect(copy.input.annualRatePercent, 7);
      expect(copy.input.years, 3);
      expect(copy.input.isCrypto, isFalse);
      expect(copy.result.points, hasLength(original.result.points.length));
      expect(copy.result.finalValue, closeTo(original.result.finalValue, 1e-9));
      expect(copy.lumpSum.finalValue, closeTo(original.lumpSum.finalValue, 1e-9));
    });

    test('mode crypto : l\'actif est restauré', () {
      const input = SimulationInput(
        initialCapital: 0,
        monthlyContribution: 50,
        annualRatePercent: 0,
        years: 1,
        cryptoAsset: CryptoAsset(
          id: 'ethereum',
          symbol: 'eth',
          name: 'Ethereum',
          currentPrice: 3000,
        ),
      );
      final row = SavedSimulation(
        name: 'ETH',
        createdAt: DateTime.utc(2026),
        vsCurrency: 'eur',
        input: input,
        result: const ProjectionResult(points: [
          ProjectionPoint(month: 0, invested: 0, value: 0),
          ProjectionPoint(month: 1, invested: 50, value: 55),
        ]),
        lumpSum: ProjectionResult.empty,
      ).toRow();

      // Pas d'id avant insertion : SQLite l'attribuera.
      expect(row.containsKey('id'), isFalse);
      expect(row['type'], SavedSimulation.typeCrypto);

      final copy = SavedSimulation.fromRow({...row, 'id': 1});
      expect(copy.input.cryptoAsset?.id, 'ethereum');
      expect(copy.result.finalValue, 55);
      expect(copy.lumpSum.isEmpty, isTrue);
    });
  });

  group('validateSimulationName', () {
    test('nom vide ou composé d\'espaces -> erreur', () {
      expect(validateSimulationName(null), isNotNull);
      expect(validateSimulationName('   '), isNotNull);
    });

    test('nom trop long -> erreur', () {
      expect(
        validateSimulationName('a' * (maxSimulationNameLength + 1)),
        isNotNull,
      );
    });

    test('nom correct -> null', () {
      expect(validateSimulationName('Bitcoin 100 €/mois'), isNull);
      expect(validateSimulationName('a' * maxSimulationNameLength), isNull);
    });
  });
}
