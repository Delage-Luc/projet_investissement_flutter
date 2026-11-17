/// Chemins de navigation de l'application.
class Routes {
  const Routes._();

  static const String market = '/market';
  static const String favorites = '/favorites';
  static const String simulator = '/simulator';

  /// Motif de la route (avec paramètre) et constructeur de chemin.
  static const String assetPattern = '/asset/:id';
  static String asset(String id) => '/asset/${Uri.encodeComponent(id)}';

  /// Simulations sauvegardées, dans l'onglet Simulateur.
  static const String savedSimulations = '/simulator/saved';
  static String savedSimulation(int id) => '$savedSimulations/$id';

  /// Onglet Lexique.
  static const String glossaryPattern = '/glossary';

  /// Notion du lexique ouverte par-dessus la page en cours (liens
  /// « Lexique : … »), pour revenir à la fiche d'un simple retour.
  static const String glossaryNotePattern = '/notion';

  /// Sans [term] : l'onglet ; avec [term] : la notion, ouverte par-dessus.
  static String glossary({String? term}) => term == null
      ? glossaryPattern
      : '$glossaryNotePattern?term=${Uri.encodeQueryComponent(term)}';
}
