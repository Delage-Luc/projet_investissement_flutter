import 'package:projet_investissement_flutter/data/clients/local_database.dart';

/// Favoris de l'utilisateur (donnée métier persistée en SQLite).
class FavoritesRepository {
  FavoritesRepository(this._db);

  final LocalDatabase _db;

  Future<List<String>> loadIds() => _db.getFavoriteIds();
  Future<void> add(String assetId) => _db.addFavorite(assetId);
  Future<void> remove(String assetId) => _db.removeFavorite(assetId);
}
