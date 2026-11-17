import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Pourcentage coloré (vert si hausse, rouge si baisse) avec une flèche,
/// posé sur une pastille teintée de la même couleur.
class PercentChip extends StatelessWidget {
  const PercentChip({super.key, required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    final color = pnlColor(context, value);
    final icon = value == null
        ? null
        : (value! >= 0 ? Icons.north_east : Icons.south_east);
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 3, 9, 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 3),
          ],
          Text(
            Formatters.percent(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              fontFeatures: tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}
