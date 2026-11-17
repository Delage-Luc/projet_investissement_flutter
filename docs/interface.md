# Écrans et logique de présentation

## Détail d'un actif

### [`lib/ui/asset_detail/pages/asset_detail_page.dart`](../lib/ui/asset_detail/pages/asset_detail_page.dart)
`AssetDetailPage` crée le ViewModel du détail ; `_AssetDetailView` compose l'écran (prix, favori, période, graphique, statistiques, explications et score). `_buildChart()` choisit entre chargement, erreur et graphique.

### [`lib/ui/asset_detail/view_models/asset_detail_view_model.dart`](../lib/ui/asset_detail/view_models/asset_detail_view_model.dart)
`AssetDetailViewModel` charge l'historique et les statistiques de l'actif. `load()` rafraîchit les données ; `selectPeriod()` change la période ; `_recompute()` recalcule les points visibles, la performance, la volatilité annualisée et son niveau, la pire baisse (`DrawdownInfo`), la valeur d'un investissement fictif de 100, les jours de hausse/baisse et le score. `_loadReference()` charge l'historique du Bitcoin pour comparer la volatilité (facultatif : en cas d'échec la comparaison est omise) ; `_notify()` évite les notifications après destruction ; `dispose()` marque le ViewModel comme détruit.

### [`lib/ui/asset_detail/widgets/period_selector.dart`](../lib/ui/asset_detail/widgets/period_selector.dart)
`PeriodSelector` affiche les choix de période et transmet la sélection via `onChanged`.

### [`lib/ui/asset_detail/widgets/price_chart.dart`](../lib/ui/asset_detail/widgets/price_chart.dart)
`PriceChart` trace les cours avec `fl_chart`, affiche les dates et révèle date/prix au toucher. La pire baisse est surlignée en rouge du sommet au creux.

### [`lib/ui/asset_detail/widgets/insights_card.dart`](../lib/ui/asset_detail/widgets/insights_card.dart)
`InsightsCard` (« Ce que ça signifie ») traduit les indicateurs en phrases calculées sur la période : « et si j'avais investi 100 », pire moment, volatilité interprétée et comparée au Bitcoin, jours de hausse et de baisse. Chaque phrase renvoie vers le lexique.

### [`lib/ui/asset_detail/widgets/score_card.dart`](../lib/ui/asset_detail/widgets/score_card.dart)
`ScoreCard` affiche le score sur 100, la note de chaque critère (barre animée) et, en dépliant, les règles et le calcul complet.

### [`lib/ui/asset_detail/widgets/stats_grid.dart`](../lib/ui/asset_detail/widgets/stats_grid.dart)
`StatsGrid` présente performance, volatilité annualisée et baisse maximale. `_StatCard` affiche une statistique et son explication dans une boîte de dialogue.

## Marché

### [`lib/ui/market/pages/market_page.dart`](../lib/ui/market/pages/market_page.dart)
`MarketPage` affiche la recherche, le choix de devise, le thème et la liste du marché. `_buildBody()` gère chargement, erreur, liste vide et résultats filtrés.

### [`lib/ui/market/view_models/market_view_model.dart`](../lib/ui/market/view_models/market_view_model.dart)
`MarketViewModel` gère les données du marché et la recherche. `assets` retourne les actifs filtrés ; `findById()` retrouve un actif ; `setQuery()` met à jour la recherche ; `load()` charge ou actualise le catalogue et ignore les réponses obsolètes ; le ViewModel écoute `SettingsViewModel` et recharge le catalogue quand la devise change.

### [`lib/ui/market/widgets/asset_tile.dart`](../lib/ui/market/widgets/asset_tile.dart)
`AssetTile` affiche une crypto sous forme de ligne avec prix, variation et favori. `_AssetLogo` affiche son image ou une initiale de remplacement.

## Favoris

### [`lib/ui/favorites/pages/favorites_page.dart`](../lib/ui/favorites/pages/favorites_page.dart)
`FavoritesPage` affiche les favoris à partir du catalogue du marché. `_EmptyFavorites` présente l'état vide et permet de revenir au marché.

### [`lib/ui/favorites/view_models/favorites_view_model.dart`](../lib/ui/favorites/view_models/favorites_view_model.dart)
`FavoritesViewModel` expose les identifiants (`ids`), l'état vide (`isEmpty`) et `isFavorite()`. `load()` lit les favoris ; `toggle()` applique immédiatement l'ajout/suppression puis restaure l'état si l'écriture échoue, et renvoie alors un message d'erreur. `loadError` signale un échec de lecture, affiché par `FavoritesPage`.

## Lexique

### [`lib/ui/glossary/pages/glossary_page.dart`](../lib/ui/glossary/pages/glossary_page.dart)
`GlossaryPage` liste les notions avec une recherche. Ouverte avec `initialTermId`, elle déplie la notion demandée et la fait défiler à l'écran (`GlobalKey` + `Scrollable.ensureVisible`).

## Simulations sauvegardées

### [`lib/ui/saved_simulations/view_models/saved_simulations_view_model.dart`](../lib/ui/saved_simulations/view_models/saved_simulations_view_model.dart)
`SavedSimulationsViewModel` charge la liste (`AsyncState`), enregistre (`save()`), supprime avec mise à jour optimiste (`delete()`) et annule une suppression (`restore()`). Chaque opération renvoie un message d'erreur ou null.

### [`lib/ui/saved_simulations/pages/saved_simulations_page.dart`](../lib/ui/saved_simulations/pages/saved_simulations_page.dart)
`SavedSimulationsPage` affiche les simulations ; glisser une ligne (`Dismissible` avec `ValueKey(id)`) ou appuyer sur sa corbeille la supprime, avec annulation possible depuis le SnackBar. `deleteSavedSimulation()` regroupe cette suppression, partagée avec l'écran de détail.

### [`lib/ui/saved_simulations/pages/saved_simulation_detail_page.dart`](../lib/ui/saved_simulations/pages/saved_simulation_detail_page.dart)
`SavedSimulationDetailPage` réaffiche le résultat enregistré, consultable hors connexion, et permet de le supprimer depuis la barre d'application.

### [`lib/ui/saved_simulations/widgets/save_simulation_dialog.dart`](../lib/ui/saved_simulations/widgets/save_simulation_dialog.dart)
`showSaveSimulationDialog()` demande un nom via un formulaire validé par `validateSimulationName()`.

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

### [`lib/ui/shared/widgets/custom_app_bar.dart`](../lib/ui/shared/widgets/custom_app_bar.dart)
`CustomAppBar` est la barre des onglets : actions propres à l'écran, lexique, devise (écrite dans `SettingsViewModel`) et thème.

### [`lib/ui/shared/widgets/feedback.dart`](../lib/ui/shared/widgets/feedback.dart)
`showMessage()` affiche un SnackBar (coloré en cas d'erreur) qui se retire par un glissement horizontal et disparaît seul après sa durée, même s'il a une action (`persist: false`). `toggleFavorite()` bascule un favori et affiche l'erreur éventuelle.

### [`lib/ui/shared/widgets/learn_more_link.dart`](../lib/ui/shared/widgets/learn_more_link.dart)
`LearnMoreLink` ouvre le lexique sur une notion donnée.

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
`SimulatorPage` crée le `SimulatorViewModel` et affiche le formulaire. Le résultat apparaît dans une fiche déplaçable (`_ResultSection`) avec un bouton « Sauvegarder ».

### [`lib/ui/simulator/view_models/simulator_view_model.dart`](../lib/ui/simulator/view_models/simulator_view_model.dart)
`SimulatorViewModel` lance la simulation (taux fixe ou cours historiques), calcule aussi la comparaison « tout au départ » et prépare l'enregistrement (`toSaved()`). Il écoute `SettingsViewModel` : si la devise change, la dernière simulation est relancée dans la nouvelle devise.

### [`lib/ui/simulator/widgets/simulation_result_view.dart`](../lib/ui/simulator/widgets/simulation_result_view.dart)
`SimulationResultView` regroupe le résumé, le graphique, la comparaison et l'avertissement ; il est partagé avec l'écran d'une simulation sauvegardée.

### [`lib/ui/simulator/widgets/projection_chart.dart`](../lib/ui/simulator/widgets/projection_chart.dart)
`ProjectionChart` trace capital versé, valeur DCA et valeur « tout au départ ». Animation codée : un `AnimationController` (piloté dans `initState`, `didUpdateWidget` et le bouton « Rejouer ») et un `AnimatedBuilder` dessinent les courbes de gauche à droite.

### [`lib/ui/simulator/widgets/strategy_comparison.dart`](../lib/ui/simulator/widgets/strategy_comparison.dart)
`StrategyComparison` compare la valeur finale du DCA à celle d'un investissement unique, avec des barres animées et une explication adaptée au résultat.
