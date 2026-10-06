import 'package:flutter/foundation.dart';
import 'package:projet_investissement_flutter/data/repositories/favorites_repository.dart';

/// Gère les favoris avec mise à jour optimiste.
class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel(this._repository);

  final FavoritesRepository _repository;

  List<String> _ids = const [];

  /// Identifiants du plus récent au plus ancien.
  List<String> get ids => _ids;
  bool get isEmpty => _ids.isEmpty;
  bool isFavorite(String assetId) => _ids.contains(assetId);

  Future<void> load() async {
    try {
      _ids = await _repository.loadIds();
    } catch (_) {
      _ids = const [];
    }
    notifyListeners();
  }

  Future<void> toggle(String assetId) async {
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
    } catch (_) {
      _ids = wasFavorite
          ? [assetId, ..._ids]
          : _ids.where((id) => id != assetId).toList();
      notifyListeners();
    }
  }
}
