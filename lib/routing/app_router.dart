import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/routing/routes.dart';
import 'package:projet_investissement_flutter/ui/asset_detail/pages/asset_detail_page.dart';
import 'package:projet_investissement_flutter/ui/favorites/pages/favorites_page.dart';
import 'package:projet_investissement_flutter/ui/market/pages/market_page.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/app_shell.dart';
import 'package:projet_investissement_flutter/ui/simulator/pages/simulator_page.dart';

/// Trois onglets et une fiche d'actif accessible depuis chacun d'eux.
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
    ],
  );
}
