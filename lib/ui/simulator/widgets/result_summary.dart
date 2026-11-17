import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/animated_number_text.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/aurora.dart';

/// Quatre indicateurs du résultat, dont les valeurs « défilent » à l'affichage.
class ResultSummary extends StatelessWidget {
  const ResultSummary({
    super.key,
    required this.result,
    required this.vsCurrency,
  });

  final ProjectionResult result;
  final String vsCurrency;

  @override
  Widget build(BuildContext context) {
    String money(double v) => Formatters.money(v, vsCurrency);
    final gainColor = pnlColor(context, result.gain);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'Capital versé',
                value: result.totalInvested,
                format: money,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(
                label: 'Valeur finale',
                value: result.finalValue,
                format: money,
                emphasized: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'Gain',
                value: result.gain,
                format: (v) => '${v > 0 ? '+' : ''}${money(v)}',
                color: gainColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(
                label: 'Performance',
                value: result.performancePercent,
                format: Formatters.percent,
                color: gainColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.format,
    this.color,
    this.emphasized = false,
  });

  final String label;
  final double? value;
  final String Function(double) format;
  final Color? color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = AppColors.of(context);
    final onEmphasized = Colors.white;
    return GlassCard(
      glow: emphasized ? colors.brand[1] : color,
      gradient: emphasized
          ? LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary,
              ],
            )
          : null,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                color: emphasized ? onEmphasized : null,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedNumberText(
              value: value,
              format: format,
              style: textTheme.titleLarge?.copyWith(
                color: emphasized ? onEmphasized : color,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                fontFeatures: tabularFigures,
                shadows: [
                  Shadow(
                    color: (emphasized ? Colors.black : (color ?? colors.line))
                        .withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}