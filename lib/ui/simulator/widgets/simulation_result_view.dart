import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/projection_chart.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/result_summary.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/strategy_comparison.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Contenu d'un résultat de simulation, partagé entre le simulateur et
/// l'écran d'une simulation sauvegardée.
class SimulationResultView extends StatelessWidget {
  const SimulationResultView({
    super.key,
    required this.input,
    required this.result,
    required this.lumpSum,
    required this.vsCurrency,
  });

  final SimulationInput input;
  final ProjectionResult result;
  final ProjectionResult lumpSum;
  final String vsCurrency;

  /// Phrase résumant les paramètres d'une simulation.
  static String describe(SimulationInput input, String vsCurrency) {
    final mode = input.cryptoAsset == null
        ? 'pendant ${input.years} an${input.years > 1 ? 's' : ''} à '
              '${Formatters.percent(input.annualRatePercent).replaceFirst('+', '')} par an'
        : 'en rejouant les cours historiques de '
              '${input.cryptoAsset!.name} (${input.cryptoAsset!.symbol.toUpperCase()}) '
              'sur ${input.years} an${input.years > 1 ? 's' : ''}';
    return 'Avec ${Formatters.money(input.initialCapital, vsCurrency)} au départ '
        'et ${Formatters.money(input.monthlyContribution, vsCurrency)} par mois '
        '$mode :';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(describe(input, vsCurrency), style: textTheme.bodyMedium),
        const SizedBox(height: 12),
        ResultSummary(result: result, vsCurrency: vsCurrency),
        const SizedBox(height: 16),
        ProjectionChart(
          result: result,
          comparison: input.monthlyContribution > 0 ? lumpSum : null,
          vsCurrency: vsCurrency,
        ),
        const SizedBox(height: 16),
        StrategyComparison(
          input: input,
          dca: result,
          lumpSum: lumpSum,
          vsCurrency: vsCurrency,
        ),
        const SizedBox(height: 16),
        Text(
          'Cette simulation ne prend pas en compte les frais ni la fiscalité. '
          'Les résultats historiques ne préjugent pas des performances futures.',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}
