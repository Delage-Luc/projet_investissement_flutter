import 'package:flutter/foundation.dart';
import 'package:projet_investissement_flutter/data/repositories/simulations_repository.dart';
import 'package:projet_investissement_flutter/domain/models/saved_simulation.dart';
import 'package:projet_investissement_flutter/utils/async_state.dart';

/// Liste des simulations sauvegardées, partagée entre le simulateur (qui
/// enregistre) et l'écran d'historique (qui affiche et supprime).
class SavedSimulationsViewModel extends ChangeNotifier {
  SavedSimulationsViewModel(this._repository);

  final SimulationsRepository _repository;

  AsyncState<List<SavedSimulation>> _state = const AsyncState.initial();

  AsyncState<List<SavedSimulation>> get state => _state;
  List<SavedSimulation> get simulations => _state.data ?? const [];

  SavedSimulation? findById(int id) {
    for (final s in simulations) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> load() async {
    _state = AsyncState.loading(data: _state.data);
    notifyListeners();
    try {
      final list = await _repository.loadAll();
      _state = AsyncState.success(list, lastUpdated: DateTime.now());
    } on Object catch (e) {
      _state = AsyncState.error(e, data: _state.data);
    }
    notifyListeners();
  }

  /// Enregistre une simulation. Renvoie un message d'erreur, ou null.
  Future<String?> save(SavedSimulation simulation) async {
    try {
      final saved = await _repository.save(simulation);
      _setList([saved, ...simulations]);
      return null;
    } on Object {
      return 'La simulation n\'a pas pu être enregistrée.';
    }
  }

  /// Supprime avec mise à jour optimiste. Renvoie un message d'erreur, ou null.
  Future<String?> delete(SavedSimulation simulation) async {
    final id = simulation.id;
    if (id == null) return null;
    final before = simulations;
    _setList(before.where((s) => s.id != id).toList());
    try {
      await _repository.delete(id);
      return null;
    } on Object {
      _setList(before);
      return 'La simulation n\'a pas pu être supprimée.';
    }
  }

  /// Annule une suppression : la simulation retrouve son identifiant.
  Future<String?> restore(SavedSimulation simulation) async {
    try {
      final restored = await _repository.save(simulation);
      final list = [...simulations, restored]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _setList(list);
      return null;
    } on Object {
      return 'La simulation n\'a pas pu être restaurée.';
    }
  }

  void _setList(List<SavedSimulation> list) {
    _state = AsyncState.success(list, lastUpdated: DateTime.now());
    notifyListeners();
  }
}
