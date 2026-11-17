/// Un critère du score : valeur mesurée, note sur 100 et poids.
class ScoreCriterion {
  const ScoreCriterion({
    required this.label,
    required this.measured,
    required this.score,
    required this.weight,
    required this.rule,
  });

  final String label;

  /// Valeur d'origine (en %), affichée pour que la note reste vérifiable.
  final double measured;

  /// Note du critère, de 0 à 100.
  final double score;

  /// Poids dans le score total (la somme des poids vaut 1).
  final double weight;

  /// Règle de normalisation, expliquée en une phrase.
  final String rule;

  /// Points apportés au score total.
  double get contribution => score * weight;
}

/// Score pédagogique sur 100, calculé à partir de l'historique.
/// Ce n'est pas une prédiction : il résume ce qui s'est passé.
class AssetScore {
  const AssetScore({required this.criteria});

  final List<ScoreCriterion> criteria;

  double get total =>
      criteria.fold<double>(0, (sum, c) => sum + c.contribution);
}
