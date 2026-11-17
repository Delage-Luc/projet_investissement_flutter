import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/domain/models/saved_simulation.dart';
import 'package:projet_investissement_flutter/routing/routes.dart';
import 'package:projet_investissement_flutter/ui/saved_simulations/view_models/saved_simulations_view_model.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/error_view.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/feedback.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/percent_chip.dart';
import 'package:projet_investissement_flutter/utils/async_state.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:provider/provider.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/aurora.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/custom_app_bar.dart';

/// Historique des simulations : glisser une ligne ou appuyer sur la
/// corbeille pour la supprimer.
class SavedSimulationsPage extends StatelessWidget {
  const SavedSimulationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavedSimulationsViewModel>();
    final state = vm.state;

    return Scaffold(
      appBar: AppBar(
        title: const PageTitle('Simulations sauvegardées'),
        actions: const [AppBarActions()],
      ),
      body: Builder(
        builder: (context) {
          if (!state.hasData) {
            if (state.status == AsyncStatus.error) {
              return ErrorView(
                message: 'Impossible de lire les simulations enregistrées.',
                onRetry: vm.load,
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          final list = vm.simulations;
          if (list.isEmpty) return const _EmptySimulations();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final sim = list[index];
              return Dismissible(
                // Identité métier stable : après une suppression, Flutter
                // associe chaque ligne restante à son propre élément.
                key: ValueKey(sim.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                onDismissed: (_) => deleteSavedSimulation(context, sim),
                child: _SimulationTile(
                  simulation: sim,
                  onTap: () => context.push(Routes.savedSimulation(sim.id!)),
                  onDelete: () => deleteSavedSimulation(context, sim),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Supprime une simulation et propose de l'annuler depuis le SnackBar.
/// Partagée par la liste (glisser ou bouton) et l'écran de détail.
Future<void> deleteSavedSimulation(
  BuildContext context,
  SavedSimulation sim,
) async {
  // Lus avant l'attente : l'écran appelant peut être fermé entre-temps.
  final messenger = ScaffoldMessenger.of(context);
  final vm = context.read<SavedSimulationsViewModel>();
  final error = await vm.delete(sim);
  if (!messenger.mounted) return;
  if (error != null) {
    showMessage(messenger, error, isError: true);
    return;
  }
  showMessage(
    messenger,
    '« ${sim.name} » supprimée.',
    action: SnackBarAction(
      label: 'Annuler',
      onPressed: () async {
        final restoreError = await vm.restore(sim);
        if (restoreError != null && messenger.mounted) {
          showMessage(messenger, restoreError, isError: true);
        }
      },
    ),
  );
}

class _SimulationTile extends StatelessWidget {
  const _SimulationTile({
    required this.simulation,
    required this.onTap,
    required this.onDelete,
  });

  final SavedSimulation simulation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final sim = simulation;
    final input = sim.input;
    final mode = input.cryptoAsset == null
        ? 'Taux fixe ${Formatters.percent(input.annualRatePercent).replaceFirst('+', '')}'
        : input.cryptoAsset!.name;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: Icon(input.isCrypto ? Icons.currency_bitcoin : Icons.percent),
      ),
      title: Text(sim.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '$mode · ${input.years} an${input.years > 1 ? 's' : ''} · '
        '${Formatters.date(sim.createdAt)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.money(sim.result.finalValue, sim.vsCurrency),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              PercentChip(value: sim.result.performancePercent),
            ],
          ),
          IconButton(
            tooltip: 'Supprimer',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _EmptySimulations extends StatelessWidget {
  const _EmptySimulations();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_border, size: 56),
            const SizedBox(height: 12),
            Text(
              'Aucune simulation sauvegardée',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Lance une simulation puis appuie sur « Sauvegarder » pour la '
              'retrouver ici, même hors connexion.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
