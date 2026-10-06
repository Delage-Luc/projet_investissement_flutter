import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/data/repositories/favorites_repository.dart';
import 'package:projet_investissement_flutter/data/repositories/market_repository.dart';
import 'package:projet_investissement_flutter/routing/app_router.dart';
import 'package:projet_investissement_flutter/ui/favorites/view_models/favorites_view_model.dart';
import 'package:projet_investissement_flutter/ui/market/view_models/market_view_model.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:provider/provider.dart';

/// Racine de l'app : dépendances, thème et routes.
class App extends StatefulWidget {
  const App({
    super.key,
    required this.settings,
    required this.marketRepository,
    required this.favoritesRepository,
  });

  final SettingsViewModel settings;
  final MarketRepository marketRepository;
  final FavoritesRepository favoritesRepository;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Le routeur reste stable entre les builds.
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MarketRepository>.value(value: widget.marketRepository),
        ChangeNotifierProvider<SettingsViewModel>.value(value: widget.settings),
        ChangeNotifierProvider(
          create: (context) => MarketViewModel(
            repository: widget.marketRepository,
            settings: context.read<SettingsViewModel>(),
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesViewModel(widget.favoritesRepository)..load(),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) => MaterialApp.router(
          title: 'Investment Companion',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          routerConfig: _router,
        ),
      ),
    );
  }
}
