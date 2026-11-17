import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Pourcentage coloré (vert si hausse, rouge si baisse) dans une pastille
/// néon : fond teinté, bord lumineux et léger halo de la même couleur.
class PercentChip extends StatelessWidget {
  const PercentChip({super.key, required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    final color = pnlColor(context, value);
    final icon = value == null
        ? null
        : (value! >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 4),
          ],
          Text(
            Formatters.percent(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              fontFeatures: tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}
