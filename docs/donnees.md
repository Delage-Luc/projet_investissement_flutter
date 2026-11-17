# Accès aux données

## Clients

### [`lib/data/clients/api_exceptions.dart`](../lib/data/clients/api_exceptions.dart)
`ApiException` représente une erreur de l'API et son éventuel code HTTP ; `toString()` renvoie son message. `NetworkException` signale un problème réseau ou un délai dépassé. `RateLimitException` représente la limite de requêtes (HTTP 429).

### [`lib/data/clients/coingecko_client.dart`](../lib/data/clients/coingecko_client.dart)
`CoinGeckoClient` effectue les appels HTTP et convertit les réponses. `fetchMarkets()` charge les actifs ; `fetchMarketChart()` charge leur historique ; `fetchMarketChartRange()` charge une plage de dates. `_getJson()` gère requête, délai et erreurs HTTP/JSON ; `_parsePrices()` convertit les cours en série journalière.

### [`lib/data/clients/local_database.dart`](../lib/data/clients/local_database.dart)
`LocalDatabase` encapsule SQLite. `open()` ouvre ou crée la base ; `_onCreate()` crée les tables de cache, cours, métadonnées, favoris et simulations. `getMeta()`/`setMeta()` lisent et écrivent les dates de cache. `getAssets()`/`replaceAssets()` lisent et remplacent le catalogue. `getPricePoints()`/`upsertPricePoints()` lisent et mettent à jour l'historique. `getFavoriteIds()`/`addFavorite()`/`removeFavorite()` gèrent les favoris. `getSimulationRows()`/`insertSimulationRow()`/`deleteSimulation()` gèrent les simulations sauvegardées.

## Dépôts

### [`lib/data/repositories/market_repository.dart`](../lib/data/repositories/market_repository.dart)
`MarketRepository` coordonne API et cache, et restitue les données en cache si le réseau échoue. `_isFresh()` vérifie la durée de validité. `getAssets()` fournit le catalogue ; `getHistory()` charge l'historique initial ou seulement les jours manquants.

### [`lib/data/repositories/favorites_repository.dart`](../lib/data/repositories/favorites_repository.dart)
`FavoritesRepository` expose les opérations de persistance des favoris : `loadIds()`, `add()` et `remove()`.

### [`lib/data/repositories/simulations_repository.dart`](../lib/data/repositories/simulations_repository.dart)
`SimulationsRepository` persiste les simulations sauvegardées : `loadAll()`, `save()` (renvoie la simulation avec son identifiant) et `delete()`.

### [`lib/data/repositories/settings_repository.dart`](../lib/data/repositories/settings_repository.dart)
`SettingsRepository` lit et écrit les préférences avec SharedPreferences. `getThemeMode()`/`setThemeMode()` gèrent le thème ; `getVsCurrency()`/`setVsCurrency()` gèrent la devise, avec une devise par défaut si la préférence est invalide ou absente.
