import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Affiche la date des données et signale le mode hors connexion,
/// sous forme d'étiquette discrète (point vert = à jour, safran = cache).
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
    final colors = AppColors.of(context);
    final dot = isStale ? colors.highlight : colors.gain;
    final text = isStale
        ? 'Hors connexion · données du ${Formatters.dateTime(lastUpdated)}'
        : 'Mis à jour le ${Formatters.dateTime(lastUpdated)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isStale ? scheme.secondaryContainer : colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isStale ? colors.highlight : colors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isStale)
                Icon(Icons.cloud_off, size: 14, color: scheme.onSurface)
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                    letterSpacing: 0.2,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
