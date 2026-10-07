import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/config/app_config.dart';
import 'package:projet_investissement_flutter/ui/market/view_models/market_view_model.dart';
import 'package:projet_investissement_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  Widget build(BuildContext context) {
    final market = context.watch<MarketViewModel>();

    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Devise',
          icon: const Icon(Icons.currency_exchange),
          initialValue: market.vsCurrency,
          onSelected: market.changeCurrency,
          itemBuilder: (context) => [
            for (final c in AppConfig.supportedCurrencies)
              PopupMenuItem(value: c, child: Text(c.toUpperCase())),
          ],
        ),
        IconButton(
          tooltip: 'Changer de thème',
          icon: Icon(Theme.of(context).brightness == Brightness.dark
              ? Icons.light_mode
              : Icons.dark_mode),
          onPressed: () {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            context
                .read<SettingsViewModel>()
                .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
          },
        ),
      ],
    );
  }
}