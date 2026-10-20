# Écrans et logique de présentation

## Détail d'un actif

### [`lib/ui/asset_detail/pages/asset_detail_page.dart`](../lib/ui/asset_detail/pages/asset_detail_page.dart)
`AssetDetailPage` crée le ViewModel du détail ; `_AssetDetailView` compose l'écran (prix, favori, période, graphique et statistiques). `_buildChart()` choisit entre chargement, erreur et graphique.

### [`lib/ui/asset_detail/view_models/asset_detail_view_model.dart`](../lib/ui/asset_detail/view_models/asset_detail_view_model.dart)
`AssetDetailViewModel` charge l'historique et les statistiques de l'actif. `load()` rafraîchit les données ; `selectPeriod()` change la période ; `_recompute()` recalcule les points visibles, performance, volatilité et baisse maximale ; `_notify()` évite les notifications après destruction ; `dispose()` marque le ViewModel comme détruit.

### [`lib/ui/asset_detail/widgets/period_selector.dart`](../lib/ui/asset_detail/widgets/period_selector.dart)
`PeriodSelector` affiche les choix de période et transmet la sélection via `onChanged`.

### [`lib/ui/asset_detail/widgets/price_chart.dart`](../lib/ui/asset_detail/widgets/price_chart.dart)
`PriceChart` trace les cours avec `fl_chart`, affiche les dates et révèle date/prix au toucher.

### [`lib/ui/asset_detail/widgets/stats_grid.dart`](../lib/ui/asset_detail/widgets/stats_grid.dart)
`StatsGrid` présente performance, volatilité et baisse maximale. `_StatCard` affiche une statistique et son explication dans une boîte de dialogue.

## Marché

### [`lib/ui/market/pages/market_page.dart`](../lib/ui/market/pages/market_page.dart)
`MarketPage` affiche la recherche, le choix de devise, le thème et la liste du marché. `_buildBody()` gère chargement, erreur, liste vide et résultats filtrés.

### [`lib/ui/market/view_models/market_view_model.dart`](../lib/ui/market/view_models/market_view_model.dart)
`MarketViewModel` gère les données du marché et la recherche. `assets` retourne les actifs filtrés ; `findById()` retrouve un actif ; `setQuery()` met à jour la recherche ; `load()` charge ou actualise le catalogue et ignore les réponses obsolètes ; `changeCurrency()` change la devise puis recharge les données.

### [`lib/ui/market/widgets/asset_tile.dart`](../lib/ui/market/widgets/asset_tile.dart)
`AssetTile` affiche une crypto sous forme de ligne avec prix, variation et favori. `_AssetLogo` affiche son image ou une initiale de remplacement.

## Favoris

### [`lib/ui/favorites/pages/favorites_page.dart`](../lib/ui/favorites/pages/favorites_page.dart)
`FavoritesPage` affiche les favoris à partir du catalogue du marché. `_EmptyFavorites` présente l'état vide et permet de revenir au marché.

### [`lib/ui/favorites/view_models/favorites_view_model.dart`](../lib/ui/favorites/view_models/favorites_view_model.dart)
`FavoritesViewModel` expose les identifiants (`ids`), l'état vide (`isEmpty`) et `isFavorite()`. `load()` lit les favoris ; `toggle()` applique immédiatement l'ajout/suppression puis restaure l'état si l'écriture échoue.

## Réglages

### [`lib/ui/settings/view_models/settings_view_model.dart`](../lib/ui/settings/view_models/settings_view_model.dart)
`SettingsViewModel` conserve le thème et la devise sélectionnés. `load()` lit les préférences ; `setThemeMode()` et `setVsCurrency()` mettent à jour l'état puis le dépôt.

## Composants partagés

### [`lib/ui/shared/themes/app_theme.dart`](../lib/ui/shared/themes/app_theme.dart)
`AppTheme.light` et `AppTheme.dark` construisent les thèmes Material 3 via `_build()`. `pnlColor()` choisit une couleur selon le gain, la perte ou l'absence de valeur.

### [`lib/ui/shared/widgets/animated_number_text.dart`](../lib/ui/shared/widgets/animated_number_text.dart)
`AnimatedNumberText` anime la transition vers une valeur et la formate ; affiche un tiret si elle est absente.

### [`lib/ui/shared/widgets/app_shell.dart`](../lib/ui/shared/widgets/app_shell.dart)
`AppShell` affiche la barre de navigation et gère le changement entre les trois onglets avec leur navigation conservée.

### [`lib/ui/shared/widgets/error_view.dart`](../lib/ui/shared/widgets/error_view.dart)
`errorMessage()` transforme les erreurs API/réseau en texte compréhensible. `ErrorView` affiche le message et un bouton de nouvelle tentative.

### [`lib/ui/shared/widgets/favorite_button.dart`](../lib/ui/shared/widgets/favorite_button.dart)
`FavoriteButton` affiche l'état du favori et anime son ajout. `_FavoriteButtonState` configure l'animation, la déclenche dans `didUpdateWidget()`, libère le contrôleur dans `dispose()` et construit le bouton dans `build()`.

### [`lib/ui/shared/widgets/percent_chip.dart`](../lib/ui/shared/widgets/percent_chip.dart)
`PercentChip` affiche un pourcentage coloré avec une flèche de hausse ou de baisse.

### [`lib/ui/shared/widgets/status_banner.dart`](../lib/ui/shared/widgets/status_banner.dart)
`StatusBanner` affiche la date de mise à jour et indique si les données proviennent d'un cache obsolète.

## Simulateur

### [`lib/ui/simulator/pages/simulator_page.dart`](../lib/ui/simulator/pages/simulator_page.dart)
`SimulatorPage` affiche actuellement un écran provisoire annonçant le simulateur DCA et le simulateur historique à venir.
