import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/animated_number_text.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Trois indicateurs de période, chacun expliqué au toucher.
class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.performance,
    required this.volatility,
    required this.maxDrawdown,
  });

  final double? performance;
  final double? volatility;
  final double? maxDrawdown;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatCard(
            label: 'Performance',
            value: performance,
            color: pnlColor(context, performance),
            explanation:
                'Variation du prix entre le début et la fin de la période : '
                '(prix final − prix initial) ÷ prix initial × 100. '
                'Exemple : 100 € qui deviennent 120 € = +20 %.',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Volatilité / an',
            value: volatility,
            format: Formatters.unsignedPercent,
            explanation:
                'Mesure à quel point le prix varie (écart-type des variations '
                'quotidiennes, ramené à une année : × √365). Plus elle est '
                'élevée, plus le prix est instable : un rendement potentiel '
                'élevé s\'accompagne souvent d\'un risque élevé. Repère : un '
                'grand indice d\'actions tourne autour de 15 à 20 % par an.',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Baisse max',
            value: maxDrawdown,
            color: pnlColor(context, maxDrawdown),
            explanation:
                'Plus forte chute observée entre un sommet et le point bas '
                'qui suit. Exemple : 125 → 90 = −28 %. Elle montre le pire '
                'moment qu\'aurait traversé un investisseur sur la période.',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.explanation,
    this.color,
    this.format = Formatters.percent,
  });

  final String label;
  final double? value;
  final String explanation;
  final Color? color;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showGeneralDialog<void>(
          context: context,
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(context)
              .modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
            title: Text(label),
            content: Text(explanation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Compris'),
              ),
            ],
          ),
          transitionBuilder: (context, animation, secondaryAnimation, child) =>
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                  reverseCurve: Curves.easeIn,
                ),
                child: child,
              ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.info_outline, size: 14),
                ],
              ),
              const SizedBox(height: 6),
              AnimatedNumberText(
                value: value,
                format: format,
                style: textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
