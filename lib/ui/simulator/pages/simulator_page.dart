import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/data/repositories/market_repository.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/routing/routes.dart';
import 'package:projet_investissement_flutter/ui/market/view_models/market_view_model.dart';
import 'package:projet_investissement_flutter/ui/saved_simulations/view_models/saved_simulations_view_model.dart';
import 'package:projet_investissement_flutter/ui/saved_simulations/widgets/save_simulation_dialog.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/custom_app_bar.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/feedback.dart';
import 'package:projet_investissement_flutter/ui/simulator/view_models/simulator_view_model.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/simulation_form.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/simulation_result_view.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:provider/provider.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/aurora.dart';

/// Tailles de la fiche résultat, en fraction de la hauteur disponible.
/// Partagées entre la fiche et l'espace réservé sous le formulaire.
class _SheetSizes {
  const _SheetSizes._();

  static const double min = 0.16;
  static const double initial = 0.42;
  static const double max = 0.92;
  static const List<double> snaps = [0.42, 0.72];
}

/// Simulateur DCA : compare un rendement fixe ou des achats rejoués sur
/// l'historique d'une crypto. Aucune transaction réelle.
class SimulatorPage extends StatelessWidget {
  const SimulatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SimulatorViewModel(
        repository: context.read<MarketRepository>(),
        settings: context.read<SettingsViewModel>(),
      ),
      child: const _SimulatorView(),
    );
  }
}

class _SimulatorView extends StatefulWidget {
  const _SimulatorView();

  @override
  State<_SimulatorView> createState() => _SimulatorViewState();
}

class _SimulatorViewState extends State<_SimulatorView> {
  /// Hauteur actuelle de la fiche résultat (fraction de la hauteur du corps
  /// de page). Seul l'espace réservé en bas de liste s'y abonne : le reste de
  /// la page n'est pas reconstruit pendant le glissement.
  final ValueNotifier<double> _sheetExtent = ValueNotifier(_SheetSizes.initial);

  late final SimulatorViewModel _simulator;

  @override
  void initState() {
    super.initState();
    _simulator = context.read<SimulatorViewModel>();
    _simulator.addListener(_resetExtentWithoutResult);
  }

  @override
  void dispose() {
    _simulator.removeListener(_resetExtentWithoutResult);
    _sheetExtent.dispose();
    super.dispose();
  }

  /// Sans résultat, la fiche est retirée ; à sa prochaine apparition elle
  /// repart à sa taille initiale, donc on remet la valeur suivie à zéro aussi.
  void _resetExtentWithoutResult() {
    if (!_simulator.hasResult) _sheetExtent.value = _SheetSizes.initial;
  }

  /// Appelé à chaque déplacement de la fiche. Si la notification arrive
  /// pendant une phase de construction/mise en page, on décale la mise à jour
  /// après le frame pour éviter un setState illégal.
  void _onSheetExtentChanged(double extent) {
    if (_sheetExtent.value == extent) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sheetExtent.value = extent;
      });
    } else {
      _sheetExtent.value = extent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final simulator = context.watch<SimulatorViewModel>();
    final vs = context.watch<SettingsViewModel>().vsCurrency;
    final assets = context.watch<MarketViewModel>().state.data ?? const [];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Simulateur DCA',
        actions: [
          IconButton(
            tooltip: 'Simulations sauvegardées',
            icon: const Icon(Icons.history),
            onPressed: () => context.push(Routes.savedSimulations),
          ),
        ],
      ),
      // LayoutBuilder : la fiche occupe une fraction de la hauteur du Stack,
      // il faut donc connaître cette hauteur pour convertir fraction -> pixels.
      body: LayoutBuilder(
        builder: (context, constraints) {
          return NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              _onSheetExtentChanged(notification.extent);
              return false; // laisse la notification poursuivre sa remontée
            },
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const _DcaIntro(),
                    const SizedBox(height: 16),
                    SimulationForm(
                      vsCurrency: vs,
                      assets: assets,
                      onSubmit: simulator.simulate,
                      onReset: simulator.reset,
                      isLoading: simulator.isLoading,
                    ),
                    if (simulator.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        simulator.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    if (simulator.isResultStale) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Les cours utilisés proviennent du cache et peuvent ne '
                        'pas être à jour.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    // Espace réservé = hauteur réelle de la fiche : on peut
                    // toujours faire défiler le formulaire jusqu'au-dessus d'elle.
                    if (simulator.hasResult)
                      ValueListenableBuilder<double>(
                        valueListenable: _sheetExtent,
                        builder: (context, extent, _) => SizedBox(
                          height: extent * constraints.maxHeight + 16,
                        ),
                      ),
                  ],
                ),
                if (simulator.hasResult)
                  _ResultSection(
                    input: simulator.input!,
                    result: simulator.result,
                    lumpSum: simulator.lumpSum,
                    vsCurrency: simulator.resultCurrency,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DcaIntro extends StatelessWidget {
  const _DcaIntro();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GlassCard(
      padding: EdgeInsets.zero,
      glow: colors.brand.first,
      child: ExpansionTile(
      initiallyExpanded: true,
      backgroundColor: colors.brand.first.withValues(alpha: 0.10),
      collapsedBackgroundColor: colors.brand.first.withValues(alpha: 0.10),
      shape: const RoundedRectangleBorder(),
      collapsedShape: const RoundedRectangleBorder(),
      leading: Icon(
        Icons.help_outline_rounded,
        size: 28,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        'Qu\'est-ce que le DCA ?',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      children: const [
        Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            "Le DCA (Dollar-Cost Averaging) consiste à investir la même somme "
            "à intervalles réguliers, quel que soit le cours. Tu peux choisir un "
            "rendement annuel fixe pour illustrer les intérêts composés, ou "
            "rejouer les cours historiques d'une crypto. Les "
            "performances passées ne préjugent pas des performances futures.",
          ),
        ),
      ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.input,
    required this.result,
    required this.lumpSum,
    required this.vsCurrency,
  });

  final SimulationInput input;
  final ProjectionResult result;
  final ProjectionResult lumpSum;
  final String vsCurrency;

  /// Nom proposé par défaut, modifiable dans la boîte de dialogue.
  String get _suggestedName => input.cryptoAsset == null
      ? '${Formatters.percent(input.annualRatePercent).replaceFirst('+', '')} '
            'sur ${input.years} an${input.years > 1 ? 's' : ''}'
      : '${input.cryptoAsset!.name} · '
            '${Formatters.money(input.monthlyContribution, vsCurrency)}/mois';

  Future<void> _save(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final simulator = context.read<SimulatorViewModel>();
    final saved = context.read<SavedSimulationsViewModel>();
    final router = GoRouter.of(context);

    final name = await showSaveSimulationDialog(
      context,
      suggestedName: _suggestedName,
    );
    if (name == null) return;
    final simulation = simulator.toSaved(name);
    if (simulation == null) return;
    final error = await saved.save(simulation);
    if (!messenger.mounted) return;
    if (error != null) {
      showMessage(messenger, error, isError: true);
    } else {
      showMessage(
        messenger,
        'Simulation « $name » sauvegardée.',
        action: SnackBarAction(
          label: 'Voir',
          onPressed: () => router.push(Routes.savedSimulations),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DraggableScrollableSheet(
      initialChildSize: _SheetSizes.initial,
      minChildSize: _SheetSizes.min,
      maxChildSize: _SheetSizes.max,
      snap: true,
      snapSizes: _SheetSizes.snaps,
      builder: (context, scrollController) => Material(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          side: BorderSide(color: AppColors.of(context).brand[1], width: 1.4),
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.of(context).floating.withValues(alpha: 0.82),
            ),
            child: ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Container(
                  width: 56,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.of(context).brand[1],
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Résultat',
                          style: textTheme.headlineMedium,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _save(context),
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: const Text('Sauvegarder'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SimulationResultView(
                    input: input,
                    result: result,
                    lumpSum: lumpSum,
                    vsCurrency: vsCurrency,
                  ),
                ],
              ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}
