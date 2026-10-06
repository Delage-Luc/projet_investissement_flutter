import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/data/clients/api_exceptions.dart';

/// Rend une erreur technique lisible.
String errorMessage(Object? error) {
  if (error is NetworkException) {
    return 'Impossible de joindre le serveur et aucune donnée n\'est '
        'enregistrée sur l\'appareil.';
  }
  if (error is ApiException) return error.message;
  return 'Une erreur inattendue est survenue.';
}

/// Écran d'erreur avec action de réessai.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
