import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';

/// Barre d'onglets avec un navigateur indépendant pour chaque onglet.
///
/// Visuellement : une capsule de verre flottante. Un indicateur en dégradé
/// glisse d'un onglet à l'autre (AnimatedAlign) et l'icône active grossit.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<_Tab> _tabs = [
    _Tab(Icons.show_chart_rounded, Icons.insights_rounded, 'Marché'),
    _Tab(Icons.star_border_rounded, Icons.star_rounded, 'Favoris'),
    _Tab(Icons.calculate_outlined, Icons.calculate_rounded, 'Simulateur'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _GlowNavBar(
        tabs: _tabs,
        currentIndex: navigationShell.currentIndex,
        onSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _GlowNavBar extends StatelessWidget {
  const _GlowNavBar({
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<_Tab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const duration = Duration(milliseconds: 420);
    const curve = Curves.easeOutBack;
    // Position de l'indicateur entre -1 (premier onglet) et 1 (dernier).
    final x = tabs.length == 1 ? 0.0 : -1 + 2 * currentIndex / (tabs.length - 1);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: colors.brand.first.withValues(alpha: isDark ? 0.35 : 0.25),
                blurRadius: 30,
                spreadRadius: -8,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 72,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xB3100E1F)
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: colors.line),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: duration,
                      curve: curve,
                      alignment: Alignment(x, 0),
                      child: FractionallySizedBox(
                        widthFactor: 1 / tabs.length,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: colors.brandGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: colors.brand[1].withValues(alpha: 0.6),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < tabs.length; i++)
                          Expanded(
                            child: _NavItem(
                              tab: tabs[i],
                              selected: i == currentIndex,
                              onTap: () => onSelected(i),
                              selectedColor: isDark
                                  ? const Color(0xFF0B0820)
                                  : Colors.white,
                              idleColor: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    required this.idleColor,
  });

  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color idleColor;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : idleColor;
    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.18 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Icon(
                selected ? tab.selectedIcon : tab.icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0.3,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}
