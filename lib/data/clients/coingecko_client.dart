import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:projet_investissement_flutter/config/app_config.dart';
import 'package:projet_investissement_flutter/data/clients/api_exceptions.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/utils/price_series.dart';

/// Client HTTP CoinGecko : convertit les réponses et lève des [ApiException].
class CoinGeckoClient {
  CoinGeckoClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Top des cryptos par capitalisation (`/coins/markets`).
  Future<List<CryptoAsset>> fetchMarkets({
    required String vsCurrency,
    int perPage = AppConfig.catalogSize,
  }) async {
    final json = await _getJson('/coins/markets', {
      'vs_currency': vsCurrency,
      'order': 'market_cap_desc',
      'per_page': '$perPage',
      'page': '1',
      'sparkline': 'false',
    });
    return (json as List<dynamic>)
        .map((e) => CryptoAsset.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Historique quotidien sur [days] jours (`/coins/{id}/market_chart`).
  Future<List<PricePoint>> fetchMarketChart({
    required String assetId,
    required String vsCurrency,
    int days = AppConfig.maxHistoryDays,
  }) async {
    final json = await _getJson('/coins/$assetId/market_chart', {
      'vs_currency': vsCurrency,
      'days': '$days',
      'interval': 'daily',
    });
    return _parsePrices(json);
  }

  /// Historique entre deux dates, pour récupérer les jours manquants.
  Future<List<PricePoint>> fetchMarketChartRange({
    required String assetId,
    required String vsCurrency,
    required DateTime from,
    required DateTime to,
  }) async {
    final json = await _getJson('/coins/$assetId/market_chart/range', {
      'vs_currency': vsCurrency,
      'from': '${from.millisecondsSinceEpoch ~/ 1000}',
      'to': '${to.millisecondsSinceEpoch ~/ 1000}',
    });
    return _parsePrices(json);
  }

  Future<dynamic> _getJson(String path, Map<String, String> query) async {
    final uri = Uri.parse('${AppConfig.coinGeckoBaseUrl}$path')
        .replace(queryParameters: query);
    final headers = {
      'accept': 'application/json',
      if (AppConfig.coinGeckoApiKey.isNotEmpty)
        'x-cg-demo-api-key': AppConfig.coinGeckoApiKey,
    };

    final http.Response response;
    try {
      response = await _http
          .get(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on TimeoutException {
      throw const NetworkException('Délai de réponse dépassé.');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }

    if (response.statusCode == 429) throw const RateLimitException();
    if (response.statusCode != 200) {
      throw ApiException(
        'Erreur du serveur (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException('Réponse du serveur illisible.');
    }
  }

  List<PricePoint> _parsePrices(dynamic json) {
    final raw = (json as Map<String, dynamic>)['prices'] as List<dynamic>? ??
        const <dynamic>[];
    final points = <PricePoint>[];
    for (final item in raw) {
      final pair = item as List<dynamic>;
      if (pair.length < 2 || pair[1] == null) continue;
      points.add(PricePoint.fromApi(pair));
    }
    return toDailySeries(points);
  }
}
