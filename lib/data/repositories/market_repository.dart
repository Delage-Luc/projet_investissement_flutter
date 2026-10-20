import 'package:projet_investissement_flutter/config/app_config.dart';
import 'package:projet_investissement_flutter/data/clients/api_exceptions.dart';
import 'package:projet_investissement_flutter/data/clients/coingecko_client.dart';
import 'package:projet_investissement_flutter/data/clients/local_database.dart';
import 'package:projet_investissement_flutter/domain/models/cached_data.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';

/// Récupère les données du cache ou de l'API, et utilise le cache hors ligne.
class MarketRepository {
  MarketRepository({
    required CoinGeckoClient client,
    required LocalDatabase database,
    DateTime Function()? now,
  })  : _client = client,
        _db = database,
        _now = now ?? DateTime.now;

  final CoinGeckoClient _client;
  final LocalDatabase _db;
  final DateTime Function() _now;

  bool _isFresh(DateTime? updatedAt, Duration ttl) =>
      updatedAt != null && _now().difference(updatedAt) < ttl;

  // Liste

  Future<CachedData<List<CryptoAsset>>> getAssets({
    required String vsCurrency,
    bool forceRefresh = false,
  }) async {
    final metaKey = 'assets:$vsCurrency';
    final cached = await _db.getAssets(vsCurrency);
    final updatedAt = await _db.getMeta(metaKey);

    if (!forceRefresh &&
        cached.isNotEmpty &&
        _isFresh(updatedAt, AppConfig.assetsTtl)) {
      return CachedData(cached, updatedAt!);
    }

    try {
      final remote = await _client.fetchMarkets(vsCurrency: vsCurrency);
      await _db.replaceAssets(vsCurrency, remote);
      final now = _now().toUtc();
      await _db.setMeta(metaKey, now);
      return CachedData(remote, now);
    } on ApiException {
      if (cached.isNotEmpty && updatedAt != null) {
        return CachedData(cached, updatedAt, isStale: true);
      }
      rethrow;
    }
  }

  // Historique

  /// Charge l'historique quotidien et ne récupère que les jours manquants.
  Future<CachedData<List<PricePoint>>> getHistory({
    required String assetId,
    required String vsCurrency,
    DateTime? from,
    bool forceRefresh = false,
  }) async {
    final metaKey = 'history:$assetId:$vsCurrency';
    final rangeMetaKey = 'history-range:$assetId:$vsCurrency';
    final cached = await _db.getPricePoints(assetId, vsCurrency);
    final updatedAt = await _db.getMeta(metaKey);
    final checkedFrom = await _db.getMeta(rangeMetaKey);
    final requestedStart = from == null ? null : PricePoint.dayStart(from);
    final requestedRangeChecked = requestedStart == null ||
        (checkedFrom != null && !checkedFrom.isAfter(requestedStart));
    final hasRequestedHistory = cached.isNotEmpty ||
        (requestedStart != null && requestedRangeChecked);
    final coversRequestedStart = requestedStart == null ||
        (cached.isNotEmpty && !cached.first.date.isAfter(requestedStart)) ||
        requestedRangeChecked;

    if (!forceRefresh &&
        hasRequestedHistory &&
        coversRequestedStart &&
        _isFresh(updatedAt, AppConfig.historyTtl)) {
      return CachedData(cached, updatedAt!);
    }

    try {
      if (cached.isEmpty) {
        final initial = requestedStart == null
            ? await _client.fetchMarketChart(
                assetId: assetId,
                vsCurrency: vsCurrency,
              )
            : await _client.fetchMarketChartRange(
                assetId: assetId,
                vsCurrency: vsCurrency,
                from: requestedStart,
                to: _now().toUtc(),
              );
        await _db.upsertPricePoints(assetId, vsCurrency, initial);
        if (requestedStart != null) {
          await _db.setMeta(rangeMetaKey, requestedStart);
        }
      } else {
        if (requestedStart != null &&
            cached.first.date.isAfter(requestedStart) &&
            !requestedRangeChecked) {
          final older = await _client.fetchMarketChartRange(
            assetId: assetId,
            vsCurrency: vsCurrency,
            from: requestedStart,
            to: cached.first.date,
          );
          await _db.upsertPricePoints(assetId, vsCurrency, older);
          await _db.setMeta(rangeMetaKey, requestedStart);
        }
        if (forceRefresh || !_isFresh(updatedAt, AppConfig.historyTtl)) {
          final newer = await _client.fetchMarketChartRange(
            assetId: assetId,
            vsCurrency: vsCurrency,
            from: cached.last.date,
            to: _now().toUtc(),
          );
          await _db.upsertPricePoints(assetId, vsCurrency, newer);
        }
      }
      final now = _now().toUtc();
      await _db.setMeta(metaKey, now);
      final merged = await _db.getPricePoints(assetId, vsCurrency);
      return CachedData(merged, now);
    } on ApiException {
      final fallback = await _db.getPricePoints(assetId, vsCurrency);
      if (fallback.isNotEmpty && updatedAt != null) {
        return CachedData(fallback, updatedAt, isStale: true);
      }
      rethrow;
    }
  }
}
