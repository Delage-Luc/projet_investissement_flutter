# Calculs et utilitaires

## [`lib/utils/async_state.dart`](../lib/utils/async_state.dart)
`AsyncStatus` énumère les états initial, chargement, réussite et erreur. `AsyncState<T>` transporte l'état, les données éventuelles, l'erreur, la date et l'indicateur de cache périmé ; `hasData` et `isLoading` sont des raccourcis.

## [`lib/utils/dca_calculator.dart`](../lib/utils/dca_calculator.dart)
`DcaCalculator.simulate()` simule des achats périodiques sur une série de prix et calcule investissement, quantité et valeur finale. `_scheduledDate()` génère les échéances hebdomadaires ou mensuelles.

## [`lib/utils/finance_calculator.dart`](../lib/utils/finance_calculator.dart)
`FinanceCalculator` regroupe des fonctions pures : `variationPercent()` et `performancePercent()` calculent une variation ; `gain()` calcule gain/perte ; `seriesPerformance()` mesure l'évolution d'une série ; `dailyReturns()` calcule ses rendements journaliers ; `volatility()` calcule la volatilité, éventuellement annualisée ; `maxDrawdown()` mesure la plus forte baisse depuis un sommet ; `compoundValue()` applique un rendement composé.

## [`lib/utils/formatters.dart`](../lib/utils/formatters.dart)
`Formatters` formate les valeurs selon la locale française. `currencySymbol()` choisit le symbole ; `price()` formate un prix ; `percent()` formate une variation ; `date()` et `dateTime()` formattent les dates.

## [`lib/utils/price_series.dart`](../lib/utils/price_series.dart)
`toDailySeries()` trie les points de prix et ne conserve que le dernier cours de chaque journée UTC.
