import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/config/app_config.dart';
import 'package:projet_investissement_flutter/routing/routes.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:provider/provider.dart';

/// Barre d'application des onglets : grand titre en dégradé surmonté de la
/// signature de l'app, et actions (lexique, devise, thème) regroupées dans
/// une capsule de verre.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.title, this.actions = const []});

  final String title;

  /// Actions propres à l'écran, placées avant les actions communes.
  final List<Widget> actions;

  static const double height = 88;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'INVESTMENT COMPANION',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.6,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Le titre rétrécit plutôt que d'être coupé par les actions.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ),
        ],
      ),
      actions: [
        AppBarActions(
          children: [
            ...actions,
            IconButton(
              tooltip: 'Lexique',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.menu_book_rounded, size: 21),
              onPressed: () => context.push(Routes.glossary()),
            ),
          ],
        ),
      ],
    );
  }
}

/// Capsule d'actions de la barre du haut, présente sur toutes les pages :
/// les actions propres à l'écran ([children]) suivies de la devise et du
/// thème, réglables de partout.
class AppBarActions extends StatelessWidget {
  const AppBarActions({super.key, this.children = const []});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isDark ? colors.card : colors.cardAlt,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: colors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...children,
            PopupMenuButton<String>(
              tooltip: 'Devise',
              icon: const Icon(Icons.currency_exchange_rounded, size: 21),
              initialValue: settings.vsCurrency,
              // Les ViewModels abonnés aux préférences réagissent seuls.
              onSelected: settings.setVsCurrency,
              itemBuilder: (context) => [
                for (final c in AppConfig.supportedCurrencies)
                  PopupMenuItem(value: c, child: Text(c.toUpperCase())),
              ],
            ),
            IconButton(
              tooltip: 'Changer de thème',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 21,
              ),
              onPressed: () => settings.setThemeMode(
                isDark ? ThemeMode.light : ThemeMode.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
