import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:projet_investissement_flutter/config/app_config.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:sqflite/sqflite.dart';

/// Accès SQLite et gestion des tables de l'app.
class LocalDatabase {
  LocalDatabase._(this._db);

  final Database _db;

  static Future<LocalDatabase> open() async {
    final path = p.join(await getDatabasesPath(), AppConfig.databaseName);
    final db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return LocalDatabase._(db);
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE assets_cache(
        id TEXT NOT NULL,
        vs_currency TEXT NOT NULL,
        rank INTEGER,
        json TEXT NOT NULL,
        PRIMARY KEY (id, vs_currency)
      )
    ''');
    batch.execute('''
      CREATE TABLE price_points(
        asset_id TEXT NOT NULL,
        vs_currency TEXT NOT NULL,
        day_ms INTEGER NOT NULL,
        price REAL NOT NULL,
        PRIMARY KEY (asset_id, vs_currency, day_ms)
      )
    ''');
    batch.execute('''
      CREATE TABLE cache_meta(
        key TEXT PRIMARY KEY,
        updated_at_ms INTEGER NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE favorites(
        asset_id TEXT PRIMARY KEY,
        added_at_ms INTEGER NOT NULL
      )
    ''');
    // Utilisée pour enregistrer les simulations.
    batch.execute('''
      CREATE TABLE saved_simulations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        params_json TEXT NOT NULL,
        result_json TEXT NOT NULL,
        created_at_ms INTEGER NOT NULL
      )
    ''');
    await batch.commit(noResult: true);
  }

  // Métadonnées

  Future<DateTime?> getMeta(String key) async {
    final rows = await _db.query(
      'cache_meta',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      rows.first['updated_at_ms'] as int,
      isUtc: true,
    );
  }

  Future<void> setMeta(String key, DateTime updatedAt) {
    return _db.insert(
      'cache_meta',
      {'key': key, 'updated_at_ms': updatedAt.millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Actifs

  Future<List<CryptoAsset>> getAssets(String vsCurrency) async {
    final rows = await _db.query(
      'assets_cache',
      where: 'vs_currency = ?',
      whereArgs: [vsCurrency],
      orderBy: 'rank IS NULL, rank ASC',
    );
    return rows
        .map((r) => CryptoAsset.fromJson(
            jsonDecode(r['json'] as String) as Map<String, dynamic>))
        .toList();
  }

  Future<void> replaceAssets(String vsCurrency, List<CryptoAsset> assets) {
    return _db.transaction((txn) async {
      await txn.delete(
        'assets_cache',
        where: 'vs_currency = ?',
        whereArgs: [vsCurrency],
      );
      final batch = txn.batch();
      for (final a in assets) {
        batch.insert('assets_cache', {
          'id': a.id,
          'vs_currency': vsCurrency,
          'rank': a.marketCapRank,
          'json': jsonEncode(a.toJson()),
        });
      }
      await batch.commit(noResult: true);
    });
  }

  // Historique

  Future<List<PricePoint>> getPricePoints(
    String assetId,
    String vsCurrency,
  ) async {
    final rows = await _db.query(
      'price_points',
      columns: ['day_ms', 'price'],
      where: 'asset_id = ? AND vs_currency = ?',
      whereArgs: [assetId, vsCurrency],
      orderBy: 'day_ms ASC',
    );
    return rows
        .map((r) => PricePoint(
              date: DateTime.fromMillisecondsSinceEpoch(
                r['day_ms'] as int,
                isUtc: true,
              ),
              price: (r['price'] as num).toDouble(),
            ))
        .toList();
  }

  /// Ajoute ou met à jour les cours (y compris celui du jour).
  Future<void> upsertPricePoints(
    String assetId,
    String vsCurrency,
    List<PricePoint> points,
  ) async {
    if (points.isEmpty) return;
    final batch = _db.batch();
    for (final pt in points) {
      batch.insert(
        'price_points',
        {
          'asset_id': assetId,
          'vs_currency': vsCurrency,
          'day_ms': pt.date.millisecondsSinceEpoch,
          'price': pt.price,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Favoris

  /// Favoris du plus récent au plus ancien.
  Future<List<String>> getFavoriteIds() async {
    final rows = await _db.query('favorites', orderBy: 'added_at_ms DESC');
    return rows.map((r) => r['asset_id'] as String).toList();
  }

  Future<void> addFavorite(String assetId) {
    return _db.insert(
      'favorites',
      {
        'asset_id': assetId,
        'added_at_ms': DateTime.now().toUtc().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(String assetId) {
    return _db.delete('favorites', where: 'asset_id = ?', whereArgs: [assetId]);
  }
}
