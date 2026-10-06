/// Chemins de navigation de l'application.
class Routes {
  const Routes._();

  static const String market = '/market';
  static const String favorites = '/favorites';
  static const String simulator = '/simulator';

  /// Motif de la route (avec paramètre) et constructeur de chemin.
  static const String assetPattern = '/asset/:id';
  static String asset(String id) => '/asset/${Uri.encodeComponent(id)}';
}
