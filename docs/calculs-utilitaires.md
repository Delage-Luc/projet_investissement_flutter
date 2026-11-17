# Calculs et utilitaires

## [`lib/utils/async_state.dart`](../lib/utils/async_state.dart)
`AsyncStatus` énumère les états initial, chargement, réussite et erreur. `AsyncState<T>` transporte l'état, les données éventuelles, l'erreur, la date et l'indicateur de cache périmé ; `hasData` et `isLoading` sont des raccourcis.

## [`lib/utils/finance_calculator.dart`](../lib/utils/finance_calculator.dart)
`FinanceCalculator` regroupe des fonctions pures : `variationPercent()` et `performancePercent()` calculent une variation ; `gain()` calcule gain/perte ; `seriesPerformance()` mesure l'évolution d'une série ; `dailyReturns()` calcule ses rendements journaliers ; `volatility()` calcule la volatilité, éventuellement annualisée ; `maxDrawdown()` mesure la plus forte baisse depuis un sommet et `maxDrawdownDetails()` renvoie en plus le sommet et le creux (`DrawdownInfo`) ; `whatIfInvested()` calcule ce que serait devenue une somme investie au début de la série ; `upDownDays()` compte les jours de hausse et de baisse ; `compoundValue()` applique un rendement composé.

## [`lib/utils/projection_calculator.dart`](../lib/utils/projection_calculator.dart)
`ProjectionCalculator` simule un investissement programmé (DCA). `project()` utilise un rendement annuel fixe ; `projectFromHistory()` rejoue les achats mensuels sur les cours historiques d'une crypto. `lumpSum()` et `lumpSumFromHistory()` calculent la stratégie de comparaison : la même somme totale investie en une fois au départ. `_monthlyPrices()` retient le cours de chaque échéance mensuelle.

## [`lib/utils/score_calculator.dart`](../lib/utils/score_calculator.dart)
`ScoreCalculator.score()` calcule un score pédagogique sur 100 à partir de trois critères observés sur la période : performance (−50 % → 0, +50 % → 100, poids 40 %), stabilité (volatilité annuelle 120 % → 0, 20 % → 100, poids 30 %) et résistance aux baisses (−80 % → 0, 0 % → 100, poids 30 %). `linearScore()` réalise la normalisation linéaire bornée. Le score décrit le passé et n'est pas une prédiction.

## [`lib/utils/simulation_validators.dart`](../lib/utils/simulation_validators.dart)
`SimulationValidators` lit les nombres saisis (virgule et espaces acceptés) et valide les champs du formulaire de simulation.

## [`lib/utils/formatters.dart`](../lib/utils/formatters.dart)
`Formatters` formate les valeurs selon la locale française. `currencySymbol()` choisit le symbole ; `price()` formate un prix ; `percent()` formate une variation ; `unsignedPercent()` formate un pourcentage sans signe pour les phrases explicatives ; `date()` et `dateTime()` formattent les dates.

## [`lib/utils/price_series.dart`](../lib/utils/price_series.dart)
`toDailySeries()` trie les points de prix et ne conserve que le dernier cours de chaque journée UTC.
