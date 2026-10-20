# Projet investissement Flutter

1. Problème et utilisateur cible

Un débutant ne sait pas comment interpréter la performance d'un actif ni ce que donnerait un investissement régulier. L'app cible un novice 20-35 ans qui veut comprendre l'investissement sans risquer de vrai argent.

2. Fonctionnalités principales

Liste de crypto avec cours et historique
Fiche détaillée par crypto (graphique, performance, volatilité)
Favoris
Simulateur DCA : 2 modes 
- Paramètres partagés :
    - Capital de départ
    - Quantité versée
- Pourcentage d'épargne (calcul d'intérêt composé) paramètres
    - Performance annuel
- Investissement sur crypto spécifique
    - durée
    - crypto
Petit lexique contextuel

3. Données externes / API

CoinGecko (crypto, market_chart)
Récupération : historique quotidien OHLCV ou prix/date
Pour simulateur calculer le nombre de récupération en fonction de la période choisie pour limiter le nombre d'appel

4. Données conservées localement

Favoris
Simulations DCA sauvegardées
Cache des historiques déjà téléchargés + date de dernière mise à jour
Préférences utilisateur (devise, thème)

5. Principaux états

Chargement / succès / erreur / hors-ligne pour chaque appel API
Favori ou non (par crypto)
Simulation configurée / résultat disponible ou non
Portefeuille de favoris vide / renseigné

6. Calculs métier

Performance : (valeur finale - valeur initiale) / valeur initiale × 100
Simulation DCA : quantité achetée = montant / cours à chaque date, sommée puis valorisée au cours final
(optionnel) Variation entre deux périodes ou volatilité simplifiée