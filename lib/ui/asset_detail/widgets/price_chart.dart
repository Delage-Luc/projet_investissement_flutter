import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/domain/models/risk.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/chart_axes.dart';

/// Courbe des prix avec la date et le cours au toucher.
/// Si [drawdown] est fourni, la pire baisse est surlignée du sommet au creux.
class PriceChart extends StatelessWidget {
  const PriceChart({
    super.key,
    required this.points,
    required this.vsCurrency,
    required this.color,
    this.drawdown,
  });

  final List<PricePoint> points;
  final String vsCurrency;
  final Color color;
  final DrawdownInfo? drawdown;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: Text('Pas assez de données pour tracer la courbe.'),
        ),
      );
    }

    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].price),
    ];
    final prices = points.map((p) => p.price);
    final y = AxisRange.from(
      prices.reduce((a, b) => a < b ? a : b),
      prices.reduce((a, b) => a > b ? a : b),
    );
    final lastIndex = points.length - 1;
    final labelStyle = Theme.of(context).textTheme.bodySmall;
    final declineColor = Theme.of(context).colorScheme.error;
    final dd = drawdown;
    final showDecline =
        dd != null && dd.hasDecline && dd.troughIndex < points.length;

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minY: y.min,
              maxY: y.max,
              // Axes : prix à gauche, quatre dates réparties en bas.
              gridData: ChartAxes.grid(context, y),
              borderData: ChartAxes.border(context),
              titlesData: ChartAxes.titles(
                context,
                y: y,
                leftLabel: (v) => Formatters.compactMoney(v, vsCurrency),
                bottomInterval: lastIndex / 3,
                bottomLabel: (v) {
                  final i = v.round().clamp(0, lastIndex);
                  return Formatters.shortDate(points[i].date);
                },
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.of(context).tooltip,
                  tooltipBorderRadius: BorderRadius.circular(12),
                  // Une seule bulle par position : celle de la courbe principale.
                  getTooltipItems: (touched) => touched.map((spot) {
                    if (spot.barIndex != 0) return null;
                    final point = points[spot.spotIndex];
                    return LineTooltipItem(
                      '${Formatters.date(point.date)}\n'
                      '${Formatters.price(point.price, vsCurrency)}',
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
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.15,
                  // Trait néon : couleur de la tendance et halo.
                  color: color,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  shadow: Shadow(
                    color: color.withValues(alpha: 0.7),
                    blurRadius: 14,
                  ),
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.22),
                        color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                if (showDecline)
                  LineChartBarData(
                    spots: spots.sublist(dd.peakIndex, dd.troughIndex + 1),
                    isCurved: true,
                    curveSmoothness: 0.15,
                    color: declineColor,
                    barWidth: 4,
                    shadow: Shadow(
                      color: declineColor.withValues(alpha: 0.9),
                      blurRadius: 16,
                    ),
                    // Points uniquement au sommet et au creux.
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, _) =>
                          spot.x == dd.peakIndex || spot.x == dd.troughIndex,
                      getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                        radius: 5,
                        color: AppColors.of(context).base,
                        strokeWidth: 3,
                        strokeColor: declineColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showDecline) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 3, color: declineColor),
              const SizedBox(width: 6),
              Text(
                'Pire baisse de la période : ${Formatters.percent(dd.percent)}',
                style: labelStyle,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
