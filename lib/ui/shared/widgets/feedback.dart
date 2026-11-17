import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/ui/favorites/view_models/favorites_view_model.dart';
import 'package:provider/provider.dart';

/// Affiche un message en bas de l'écran ([isError] le colore en erreur).
void showMessage(
  ScaffoldMessengerState messenger,
  String message, {
  bool isError = false,
  SnackBarAction? action,
}) {
  final scheme = Theme.of(messenger.context).colorScheme;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: isError ? TextStyle(color: scheme.onErrorContainer) : null,
        ),
        backgroundColor: isError ? scheme.errorContainer : null,
        behavior: SnackBarBehavior.floating,
        // Se retire d'un glissement vers la gauche ou la droite.
        dismissDirection: DismissDirection.horizontal,
        action: action,
        // Par défaut, un SnackBar avec action reste affiché jusqu'au clic :
        // on le laisse disparaître seul après sa durée, comme les autres.
        persist: false,
      ),
    );
}

/// Bascule un favori et prévient l'utilisateur si l'enregistrement échoue.
Future<void> toggleFavorite(BuildContext context, String assetId) async {
  // Le messenger est lu avant l'attente : le contexte peut disparaître.
  final messenger = ScaffoldMessenger.of(context);
  final error = await context.read<FavoritesViewModel>().toggle(assetId);
  if (error != null && messenger.mounted) {
    showMessage(messenger, error, isError: true);
  }
}
