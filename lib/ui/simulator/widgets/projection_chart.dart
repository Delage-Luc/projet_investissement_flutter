import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Capital versé (pointillés) vs valeur du portefeuille (trait plein).
///
/// Animation programmée : un TweenAnimationBuilder fait progresser de 0 à 1
/// le nombre de points tracés, ce qui « dessine » la courbe de gauche à droite.
/// Les bornes des axes sont calculées sur toute la série pour ne pas sauter.
class ProjectionChart extends StatelessWidget {
  const ProjectionChart({
    super.key,
    required this.result,
    required this.vsCurrency,
  });

  final ProjectionResult result;
  final String vsCurrency;

  @override
  Widget build(BuildContext context) {
    final points = result.points;
    if (points.length < 2) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final valueColor = scheme.primary;
    final investedColor = scheme.outline;
    final maxY = points.map((p) => math.max(p.value, p.invested)).reduce(math.max);
    final minY = points.map((p) => math.min(p.value, p.invested)).reduce(math.min);
    final padding = (maxY - minY) * 0.06;
    final years = points.last.month ~/ 12;
    final labelStyle = Theme.of(context).textTheme.bodySmall;

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: TweenAnimationBuilder<double>(
            // Nouvelle simulation = nouvel objet résultat = animation rejouée.
            key: ObjectKey(result),
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOut,
            builder: (context, progress, _) {
              final visible = math.max(2, (points.length * progress).round());
              List<FlSpot> spots(double Function(ProjectionPoint) y) => [
                    for (var i = 0; i < visible; i++)
                      FlSpot(i.toDouble(), y(points[i])),
                  ];

              return LineChart(
                // Pas d'animation interne de fl_chart : c'est la nôtre qui pilote.
                duration: Duration.zero,
                LineChartData(
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  minY: math.max(0, minY - padding),
                  maxY: maxY + padding,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touched) => touched.map((spot) {
                        final label = spot.barIndex == 0 ? 'Versé' : 'Valeur';
                        return LineTooltipItem(
                          '$label : ${Formatters.money(spot.y, vsCurrency)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots((p) => p.invested),
                      color: investedColor,
                      barWidth: 2,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: spots((p) => p.value),
                      isCurved: true,
                      curveSmoothness: 0.1,
                      color: valueColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: valueColor.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Départ', style: labelStyle),
            Text('Année $years', style: labelStyle),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: valueColor, label: 'Valeur du portefeuille'),
            const SizedBox(width: 16),
            _LegendDot(color: investedColor, label: 'Capital versé'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}