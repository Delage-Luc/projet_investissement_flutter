import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:projet_investissement_flutter/app.dart';
import 'package:projet_investissement_flutter/data/clients/coingecko_client.dart';
import 'package:projet_investissement_flutter/data/clients/local_database.dart';
import 'package:projet_investissement_flutter/data/repositories/favorites_repository.dart';
import 'package:projet_investissement_flutter/data/repositories/market_repository.dart';
import 'package:projet_investissement_flutter/data/repositories/settings_repository.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');

  // Prépare la base et les préférences avant l'affichage.
  final database = await LocalDatabase.open();
  final settings = SettingsViewModel(SettingsRepository());
  await settings.load(); // Charge les préférences avant l'affichage.

  runApp(App(
    settings: settings,
    marketRepository: MarketRepository(
      client: CoinGeckoClient(),
      database: database,
    ),
    favoritesRepository: FavoritesRepository(database),
  ));
}
