# Documentation du code de `lib`

La documentation est répartie en pages thématiques. Chaque page décrit les fichiers de sa partie et les principaux objets, classes et fonctions.

## Pages

- [Démarrage, configuration et navigation](demarrage-navigation.md) — entrée de l'application, configuration générale et routes.
- [Accès aux données](donnees.md) — API CoinGecko, SQLite, dépôts et préférences.
- [Modèles métier](modeles.md) — structures représentant les actifs, prix, périodes et résultats.
- [Écrans et logique de présentation](interface.md) — pages, ViewModels et composants d'interface.
- [Calculs et utilitaires](calculs-utilitaires.md) — états asynchrones, calculs financiers, séries de prix et formatage.

## Organisation

`lib/` est organisé autour de la présentation (`ui/`), de l'accès aux données (`data/`), des modèles (`domain/`) et des fonctions utilitaires (`utils/`). `main.dart`, `app.dart`, `config/` et `routing/` démarrent et assemblent l'application.
