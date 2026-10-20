import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/data/repositories/market_repository.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/ui/market/view_models/market_view_model.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/custom_app_bar.dart';
import 'package:projet_investissement_flutter/ui/simulator/view_models/simulator_view_model.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/projection_chart.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/result_summary.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/simulation_form.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:provider/provider.dart';

/// Simulateur DCA : compare un rendement fixe ou des achats rejoués sur
/// l'historique d'une crypto. Aucune transaction réelle.
class SimulatorPage extends StatelessWidget {
  const SimulatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SimulatorViewModel(
        repository: context.read<MarketRepository>(),
      ),
      child: const _SimulatorView(),
    );
  }
}

class _SimulatorView extends StatelessWidget {
  const _SimulatorView();

  @override
  Widget build(BuildContext context) {
    final simulator = context.watch<SimulatorViewModel>();
    final vs = context.watch<SettingsViewModel>().vsCurrency;
    final assets =
        context.watch<MarketViewModel>().state.data ?? const [];

    return Scaffold(
      appBar: CustomAppBar(title: 'Simulateur DCA'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _DcaIntro(),
          const SizedBox(height: 16),
          SimulationForm(
            vsCurrency: vs,
            assets: assets,
            onSubmit: (input) =>
                simulator.simulate(input, vsCurrency: vs),
            onReset: simulator.reset,
            isLoading: simulator.isLoading,
          ),
          if (simulator.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              simulator.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (simulator.isResultStale) ...[
            const SizedBox(height: 12),
            Text(
              'Les cours utilisés proviennent du cache et peuvent ne pas être '
              'à jour.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          // AnimatedSize : la zone résultat se déploie en douceur.
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: simulator.hasResult
                ? _ResultSection(
                    input: simulator.input!,
                    result: simulator.result,
                    vsCurrency: vs,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _DcaIntro extends StatelessWidget {
  const _DcaIntro();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Le DCA (Dollar-Cost Averaging) consiste à investir la même somme "
          "à intervalles réguliers, quel que soit le cours. Tu peux choisir un "
          "rendement annuel fixe pour illustrer les intérêts composés, ou "
          "rejouer les cours historiques d'une crypto. Les "
          "performances passées ne préjugent pas des performances futures.",
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.input,
    required this.result,
    required this.vsCurrency,
  });

  final SimulationInput input;
  final ProjectionResult result;
  final String vsCurrency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final simulationDescription = input.cryptoAsset == null
        ? 'pendant ${input.years} ans à '
            '${Formatters.percent(input.annualRatePercent).replaceFirst('+', '')} par an'
        : 'en rejouant les cours historiques de '
            '${input.cryptoAsset!.name} (${input.cryptoAsset!.symbol.toUpperCase()}) '
            'sur ${input.years} ans';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Résultat', style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Avec ${Formatters.money(input.initialCapital, vsCurrency)} au départ '
          'et ${Formatters.money(input.monthlyContribution, vsCurrency)} par mois '
          '$simulationDescription :',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ResultSummary(result: result, vsCurrency: vsCurrency),
        const SizedBox(height: 16),
        ProjectionChart(result: result, vsCurrency: vsCurrency),
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