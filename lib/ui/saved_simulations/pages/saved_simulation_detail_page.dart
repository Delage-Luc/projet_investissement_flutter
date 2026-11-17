import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/ui/saved_simulations/pages/saved_simulations_page.dart';
import 'package:projet_investissement_flutter/ui/saved_simulations/view_models/saved_simulations_view_model.dart';
import 'package:projet_investissement_flutter/ui/simulator/widgets/simulation_result_view.dart';
import 'package:projet_investissement_flutter/utils/async_state.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:provider/provider.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/aurora.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/custom_app_bar.dart';

/// Résultat d'une simulation sauvegardée, relu depuis SQLite (hors connexion).
class SavedSimulationDetailPage extends StatelessWidget {
  const SavedSimulationDetailPage({super.key, required this.simulationId});

  final int simulationId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavedSimulationsViewModel>();
    final sim = vm.findById(simulationId);

    if (sim == null) {
      final loading = !vm.state.hasData && vm.state.status != AsyncStatus.error;
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: loading
              ? const CircularProgressIndicator()
              : const Text('Cette simulation n\'existe plus.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: PageTitle(sim.name),
        actions: [
          AppBarActions(
            children: [
              IconButton(
                tooltip: 'Supprimer',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline_rounded, size: 21),
                onPressed: () {
                  // La suppression lit ses dépendances tout de suite, puis
                  // on revient à la liste où le SnackBar « Annuler » s'affiche.
                  deleteSavedSimulation(context, sim);
                  context.pop();
                },
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Sauvegardée le ${Formatters.dateTime(sim.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          SimulationResultView(
            input: sim.input,
            result: sim.result,
            lumpSum: sim.lumpSum,
            vsCurrency: sim.vsCurrency,
          ),
        ],
      ),
    );
  }
}
