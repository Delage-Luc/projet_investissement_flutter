import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/chart_axes.dart';

/// Capital versé (pointillés), valeur du portefeuille (trait plein) et,
/// si fourni, la même somme investie en une fois ([comparison]).
///
/// Animation programmée explicitement : un [AnimationController] fait
/// progresser de 0 à 1 le nombre de points tracés, ce qui « dessine » les
/// courbes de gauche à droite. Le contrôleur est relancé à chaque nouveau
/// résultat (didUpdateWidget) ou à la demande (bouton « Rejouer »).
/// Les bornes des axes sont calculées sur toute la série pour ne pas sauter.
class ProjectionChart extends StatefulWidget {
  const ProjectionChart({
    super.key,
    required this.result,
    required this.vsCurrency,
    this.comparison,
  });

  final ProjectionResult result;
  final String vsCurrency;
  final ProjectionResult? comparison;

  @override
  State<ProjectionChart> createState() => _ProjectionChartState();
}

class _ProjectionChartState extends State<ProjectionChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ProjectionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nouvelle simulation = nouvel objet résultat : on redessine depuis 0.
    if (!identical(oldWidget.result, widget.result)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.result.points;
    if (points.length < 2) return const SizedBox.shrink();
    final comparison = widget.comparison?.points.length == points.length
        ? widget.comparison!.points
        : null;

    final scheme = Theme.of(context).colorScheme;
    final valueColor = scheme.primary;
    final investedColor = scheme.outline;
    final comparisonColor = AppColors.of(context).highlight;
    final all = [...points, ...?comparison];
    final y = AxisRange.from(
      all.map((p) => math.min(p.value, p.invested)).reduce(math.min),
      all.map((p) => math.max(p.value, p.invested)).reduce(math.max),
      floorAtZero: true,
    );
    final months = points.last.month;
    final years = months ~/ 12;
    // Repères en bas : trimestres sur un an, sinon des années (5 au plus).
    final double bottomInterval = years <= 1
        ? 3
        : 12.0 * ((years + 4) ~/ 5);
    String? monthLabel(double v) {
      final m = v.round();
      if (m == 0) return 'Départ';
      if (years <= 1) return '$m m';
      return m % 12 == 0 ? 'An ${m ~/ 12}' : null;
    }
    final labels =['Versé', 'Valeur (DCA)', 'Tout au départ'];

    return Column(
      children: [
        SizedBox(
          height: 240,
          // Seul le graphique est reconstruit à chaque image de l'animation.
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              final visible = math.max(
                2,
                (points.length * _progress.value).round(),
              );
              List<FlSpot> spots(
                List<ProjectionPoint> source,
                double Function(ProjectionPoint) y,
              ) => [
                for (var i = 0; i < visible; i++)
                  FlSpot(i.toDouble(), y(source[i])),
              ];

              return LineChart(
                // Pas d'animation interne de fl_chart : c'est la nôtre qui pilote.
                duration: Duration.zero,
                LineChartData(
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  minY: y.min,
                  maxY: y.max,
                  // Axes : montants à gauche, mois ou années en bas.
                  gridData: ChartAxes.grid(context, y),
                  borderData: ChartAxes.border(context),
                  titlesData: ChartAxes.titles(
                    context,
                    y: y,
                    leftLabel: (v) =>
                        Formatters.compactMoney(v, widget.vsCurrency),
                    bottomInterval: bottomInterval,
                    bottomLabel: monthLabel,
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.of(context).tooltip,
                      tooltipBorderRadius: BorderRadius.circular(12),
                      getTooltipItems: (touched) => touched.map((spot) {
                        return LineTooltipItem(
                          '${labels[spot.barIndex]} : '
                          '${Formatters.money(spot.y, widget.vsCurrency)}',
                          TextStyle(
                            color: AppColors.of(context).onTooltip,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots(points, (p) => p.invested),
                      color: investedColor,
                      barWidth: 2,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: spots(points, (p) => p.value),
                      isCurved: true,
                      curveSmoothness: 0.1,
                      color: valueColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      shadow: Shadow(
                        color: valueColor.withValues(alpha: 0.8),
                        blurRadius: 16,
                      ),
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            valueColor.withValues(alpha: 0.35),
                            valueColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    if (comparison != null)
                      LineChartBarData(
                        spots: spots(comparison, (p) => p.value),
                        isCurved: true,
                        curveSmoothness: 0.1,
                        color: comparisonColor,
                        barWidth: 2.5,
                        dashArray: [3, 4],
                        shadow: Shadow(
                          color: comparisonColor.withValues(alpha: 0.8),
                          blurRadius: 10,
                        ),
                        dotData: const FlDotData(show: false),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Rejouer l\'animation',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.replay_rounded, size: 20),
              onPressed: () => _controller.forward(from: 0),
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 4,
          children: [
            _LegendDot(color: valueColor, label: 'Valeur (DCA)'),
            _LegendDot(color: investedColor, label: 'Capital versé'),
            if (comparison != null)
              _LegendDot(color: comparisonColor, label: 'Tout au départ'),
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
