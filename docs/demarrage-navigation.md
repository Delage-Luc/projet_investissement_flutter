# Démarrage, configuration et navigation

## [`lib/main.dart`](../lib/main.dart)
Point d'entrée `main()`. Initialise Flutter et le formatage français, ouvre SQLite, charge les préférences, puis construit les dépôts et lance `App`.

## [`lib/app.dart`](../lib/app.dart)
`App` est le widget racine : il reçoit les dépôts et les préférences, expose les ViewModels avec Provider et configure le thème et le routeur. `_AppState` conserve une instance stable du routeur et construit `MaterialApp.router`.

## [`lib/config/app_config.dart`](../lib/config/app_config.dart)
`AppConfig` centralise les paramètres : URL CoinGecko et clé éventuelle, taille du catalogue, devises prises en charge, délais, durées de cache, limite d'historique et nom de la base.

## [`lib/routing/routes.dart`](../lib/routing/routes.dart)
`Routes` définit les chemins du marché, des favoris, du simulateur, de la fiche d'actif, des simulations sauvegardées et du lexique. `asset(id)`, `savedSimulation(id)` et `glossary(term:)` construisent les chemins paramétrés.

## [`lib/routing/app_router.dart`](../lib/routing/app_router.dart)
`createRouter()` configure GoRouter : navigation à onglets conservant l'état de chaque branche, simulations sauvegardées imbriquées dans l'onglet Simulateur, puis fiche d'actif et lexique affichés au-dessus des onglets.
