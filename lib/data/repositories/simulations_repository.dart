import 'package:projet_investissement_flutter/data/clients/local_database.dart';
import 'package:projet_investissement_flutter/domain/models/saved_simulation.dart';

/// Simulations sauvegardées (donnée métier persistée en SQLite).
/// Paramètres et résultats sont sérialisés en JSON dans la même ligne.
class SimulationsRepository {
  SimulationsRepository(this._db);

  final LocalDatabase _db;

  Future<List<SavedSimulation>> loadAll() async {
    final rows = await _db.getSimulationRows();
    return rows.map(SavedSimulation.fromRow).toList();
  }

  /// Enregistre la simulation et la renvoie avec son identifiant.
  Future<SavedSimulation> save(SavedSimulation simulation) async {
    final id = await _db.insertSimulationRow(simulation.toRow());
    return simulation.copyWith(id: id);
  }

  Future<void> delete(int id) => _db.deleteSimulation(id);
}
