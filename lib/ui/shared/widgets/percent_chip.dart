import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Pourcentage coloré (vert si hausse, rouge si baisse) avec une flèche.
class PercentChip extends StatelessWidget {
  const PercentChip({super.key, required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    final color = pnlColor(context, value);
    final icon = value == null
        ? null
        : (value! >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, color: color, size: 22),
        Text(
          Formatters.percent(value),
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
