import 'package:flutter/foundation.dart';
import 'package:projet_investissement_flutter/data/repositories/favorites_repository.dart';

/// Gère les favoris avec mise à jour optimiste.
class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel(this._repository);

  final FavoritesRepository _repository;

  List<String> _ids = const [];
  String? _loadError;

  /// Identifiants du plus récent au plus ancien.
  List<String> get ids => _ids;
  bool get isEmpty => _ids.isEmpty;
  bool isFavorite(String assetId) => _ids.contains(assetId);

  /// Message à afficher si les favoris n'ont pas pu être lus.
  String? get loadError => _loadError;

  Future<void> load() async {
    try {
      _ids = await _repository.loadIds();
      _loadError = null;
    } catch (_) {
      _ids = const [];
      _loadError = 'Impossible de lire tes favoris enregistrés.';
    }
    notifyListeners();
  }

  /// Ajoute ou retire un favori. L'interface est mise à jour tout de suite ;
  /// si l'écriture échoue, le changement est annulé et un message d'erreur
  /// est renvoyé pour que l'écran puisse prévenir l'utilisateur.
  Future<String?> toggle(String assetId) async {
    final wasFavorite = isFavorite(assetId);
    _ids = wasFavorite
        ? _ids.where((id) => id != assetId).toList()
        : [assetId, ..._ids];
    notifyListeners();

    try {
      if (wasFavorite) {
        await _repository.remove(assetId);
      } else {
        await _repository.add(assetId);
      }
      return null;
    } catch (_) {
      _ids = wasFavorite
          ? [assetId, ..._ids]
          : _ids.where((id) => id != assetId).toList();
      notifyListeners();
      return wasFavorite
          ? 'Impossible de retirer ce favori. Réessaie.'
          : 'Impossible d\'ajouter ce favori. Réessaie.';
    }
  }
}
