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

  /// Lexique ; [term] ouvre directement la définition d'une notion.
  static const String glossaryPattern = '/glossary';
  static String glossary({String? term}) => term == null
      ? glossaryPattern
      : '$glossaryPattern?term=${Uri.encodeQueryComponent(term)}';
}
