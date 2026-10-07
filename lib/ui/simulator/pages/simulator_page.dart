import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/custom_app_bar.dart';
import 'package:projet_investissement_flutter/ui/simulator/view_models/simulator_view_model.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/projection_chart.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/result_summary.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/simulation_form.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:provider/provider.dart';

/// Simulateur DCA paramétrique : l'utilisateur fixe un capital, un versement
/// mensuel, un rendement supposé et une durée, puis découvre l'effet des
/// intérêts composés. Aucune transaction réelle.
class SimulatorPage extends StatelessWidget {
  const SimulatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SimulatorViewModel(),
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

    return Scaffold(
      appBar: CustomAppBar(title: 'Simulateur DCA'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _DcaIntro(),
          const SizedBox(height: 16),
          SimulationForm(
            vsCurrency: vs,
            onSubmit: simulator.simulate,
            onReset: simulator.reset,
          ),
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
          'Le DCA (Dollar-Cost Averaging) consiste à investir la même somme '
          'à intervalles réguliers, quel que soit le cours. Ce simulateur '
          'applique un rendement annuel constant que tu choisis : c\'est une '
          'hypothèse pour comprendre les intérêts composés, pas une prévision.',
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
    final rate = Formatters.percent(input.annualRatePercent).replaceFirst('+', '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Résultat', style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Avec ${Formatters.money(input.initialCapital, vsCurrency)} au départ '
          'et ${Formatters.money(input.monthlyContribution, vsCurrency)} par mois '
          'pendant ${input.years} ans à $rate par an :',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ResultSummary(result: result, vsCurrency: vsCurrency),
        const SizedBox(height: 16),
        ProjectionChart(result: result, vsCurrency: vsCurrency),
        const SizedBox(height: 16),
        Text(
          'Dans la réalité, un actif comme une crypto ne rapporte jamais un '
          'taux constant : son prix peut chuter fortement avant de remonter. '
          'Compare avec la volatilité et la baisse maximale affichées sur la '
          'fiche d\'un actif.',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}