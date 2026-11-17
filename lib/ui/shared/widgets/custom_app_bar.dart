import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/config/app_config.dart';
import 'package:projet_investissement_flutter/routing/routes.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:provider/provider.dart';

/// Barre d'application des onglets : lexique, devise et thème.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.title, this.actions = const []});

  final String title;

  /// Actions propres à l'écran, placées avant les actions communes.
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();

    return AppBar(
      title: Text(title),
      actions: [
        ...actions,
        IconButton(
          tooltip: 'Lexique',
          icon: const Icon(Icons.menu_book_outlined),
          onPressed: () => context.push(Routes.glossary()),
        ),
        PopupMenuButton<String>(
          tooltip: 'Devise',
          icon: const Icon(Icons.currency_exchange),
          initialValue: settings.vsCurrency,
          // Les ViewModels abonnés aux préférences réagissent d'eux-mêmes.
          onSelected: settings.setVsCurrency,
          itemBuilder: (context) => [
            for (final c in AppConfig.supportedCurrencies)
              PopupMenuItem(value: c, child: Text(c.toUpperCase())),
          ],
        ),
        IconButton(
          tooltip: 'Changer de thème',
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          onPressed: () {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            settings.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
          },
        ),
      ],
    );
  }
}
