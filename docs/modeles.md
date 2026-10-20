# Modèles métier

## [`lib/domain/models/cached_data.dart`](../lib/domain/models/cached_data.dart)
`CachedData<T>` associe une donnée à sa date de mise à jour et à un indicateur `isStale` signalant un cache périmé.

## [`lib/domain/models/chart_period.dart`](../lib/domain/models/chart_period.dart)
`ChartPeriod` définit les périodes du graphique (`month`, `quarter`, `year`), chacune avec un nombre de jours et un libellé.

## [`lib/domain/models/crypto_asset.dart`](../lib/domain/models/crypto_asset.dart)
`CryptoAsset` représente une crypto-monnaie et ses informations de marché. `fromJson()` lit les données de l'API ; `toJson()` les prépare pour le cache SQLite.

## [`lib/domain/models/dca.dart`](../lib/domain/models/dca.dart)
`DcaFrequency` décrit les fréquences hebdomadaire et mensuelle. `DcaPurchase` représente un achat simulé. `DcaResult` regroupe achats, montants et valeur finale ; `isEmpty`, `gain` et `performancePercent` en dérivent des indicateurs.

## [`lib/domain/models/price_point.dart`](../lib/domain/models/price_point.dart)
`PricePoint` représente un cours daté en UTC. `fromApi()` convertit une paire timestamp/prix ; `dayStart()` ramène une date au début de sa journée UTC.
