/// Configuration de l'application.
class AppConfig {
  const AppConfig._();

  static const String coinGeckoBaseUrl = 'https://api.coingecko.com/api/v3';
  static const String coinGeckoApiKey = 'CG-dytLpfQaDtGLbJrhTFFtjhC5';
     

  /// Nombre d'actifs affichés au démarrage.
  static const int catalogSize = 30;

  static const String defaultVsCurrency = 'eur';
  static const List<String> supportedCurrencies = ['eur', 'usd'];

  static const Duration requestTimeout = Duration(seconds: 15);

  /// Durée de validité des caches.
  static const Duration assetsTtl = Duration(minutes: 10);
  static const Duration historyTtl = Duration(hours: 6);

  /// Limite du plan Demo CoinGecko.
  static const int maxHistoryDays = 365;

  static const String databaseName = 'investment_companion.db';
}
