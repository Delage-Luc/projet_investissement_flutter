# Modèles métier

## [`lib/domain/models/cached_data.dart`](../lib/domain/models/cached_data.dart)
`CachedData<T>` associe une donnée à sa date de mise à jour et à un indicateur `isStale` signalant un cache périmé.

## [`lib/domain/models/chart_period.dart`](../lib/domain/models/chart_period.dart)
`ChartPeriod` définit les périodes du graphique (`month`, `quarter`, `year`), chacune avec un nombre de jours et un libellé.

## [`lib/domain/models/crypto_asset.dart`](../lib/domain/models/crypto_asset.dart)
`CryptoAsset` représente une crypto-monnaie et ses informations de marché. `fromJson()` lit les données de l'API ; `toJson()` les prépare pour le cache SQLite.

## [`lib/domain/models/asset_score.dart`](../lib/domain/models/asset_score.dart)
`ScoreCriterion` décrit un critère du score : valeur mesurée, note sur 100, poids et règle de normalisation ; `contribution` donne les points apportés. `AssetScore` regroupe les critères ; `total` est leur somme pondérée.

## [`lib/domain/models/glossary.dart`](../lib/domain/models/glossary.dart)
`GlossaryEntry` représente une notion du lexique (définition et exemple chiffré). `GlossaryTerms` liste les identifiants utilisés dans les liens « Lexique » des écrans ; `glossary` contient les notions ; `glossaryEntry()` en retrouve une.

## [`lib/domain/models/projection.dart`](../lib/domain/models/projection.dart)
`SimulationInput` contient les paramètres du simulateur (capital, versement mensuel, taux, durée, crypto éventuelle). `ProjectionPoint` est l'état du portefeuille à la fin d'un mois ; `ProjectionResult` regroupe ces points et en dérive totaux, gain et performance. Les trois classes ont `fromJson()`/`toJson()` pour la persistance.

## [`lib/domain/models/risk.dart`](../lib/domain/models/risk.dart)
`DrawdownInfo` décrit la pire baisse d'une série : sommet, creux, positions, pourcentage et durée. `VolatilityLevel` traduit une volatilité annualisée en niveau faible (< 30 %), modéré (< 70 %) ou fort, avec une explication pour un débutant.

## [`lib/domain/models/saved_simulation.dart`](../lib/domain/models/saved_simulation.dart)
`SavedSimulation` est une simulation enregistrée : nom, date, devise, paramètres, résultat DCA et comparaison « tout au départ ». `toRow()`/`fromRow()` la convertissent en ligne de la table `saved_simulations` (paramètres et résultats en JSON).

## [`lib/domain/models/price_point.dart`](../lib/domain/models/price_point.dart)
`PricePoint` représente un cours daté en UTC. `fromApi()` convertit une paire timestamp/prix ; `dayStart()` ramène une date au début de sa journée UTC.
