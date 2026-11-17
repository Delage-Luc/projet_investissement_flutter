import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/routing/routes.dart';
import 'package:projet_investissement_flutter/ui/asset_detail/pages/asset_detail_page.dart';
import 'package:projet_investissement_flutter/ui/favorites/pages/favorites_page.dart';
import 'package:projet_investissement_flutter/ui/glossary/pages/glossary_page.dart';
import 'package:projet_investissement_flutter/ui/market/pages/market_page.dart';
import 'package:projet_investissement_flutter/ui/saved_simulations/pages/saved_simulation_detail_page.dart';
import 'package:projet_investissement_flutter/ui/saved_simulations/pages/saved_simulations_page.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/app_shell.dart';
import 'package:projet_investissement_flutter/ui/simulator/pages/simulator_page.dart';

/// Trois onglets, une fiche d'actif et un lexique accessibles depuis chacun
/// d'eux ; les simulations sauvegardées sont dans l'onglet Simulateur.
GoRouter createRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.market,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.market,
              builder: (context, state) => const MarketPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.favorites,
              builder: (context, state) => const FavoritesPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.simulator,
              builder: (context, state) => const SimulatorPage(),
              routes: [
                // Restent dans l'onglet : la barre de navigation reste visible.
                GoRoute(
                  path: 'saved',
                  builder: (context, state) => const SavedSimulationsPage(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => SavedSimulationDetailPage(
                        simulationId:
                            int.tryParse(state.pathParameters['id']!) ?? -1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
      GoRoute(
        path: Routes.assetPattern,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            AssetDetailPage(assetId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.glossaryPattern,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            GlossaryPage(initialTermId: state.uri.queryParameters['term']),
      ),
    ],
  );
}
