import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Affiche la date des données et signale le mode hors connexion.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.lastUpdated,
    required this.isStale,
  });

  final DateTime lastUpdated;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background =
        isStale ? scheme.tertiaryContainer : scheme.surfaceContainerHighest;
    final foreground =
        isStale ? scheme.onTertiaryContainer : scheme.onSurfaceVariant;
    final text = isStale
        ? 'Hors connexion : données du ${Formatters.dateTime(lastUpdated)}'
        : 'Mis à jour le ${Formatters.dateTime(lastUpdated)}';

    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(isStale ? Icons.cloud_off : Icons.check_circle_outline,
              size: 16, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: foreground)),
          ),
        ],
      ),
    );
  }
}
