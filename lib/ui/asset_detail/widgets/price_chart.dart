import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/domain/models/risk.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

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
    final minY = prices.reduce((a, b) => a < b ? a : b);
    final maxY = prices.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.08;
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
              minY: minY - padding,
              maxY: maxY + padding,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
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
                  color: color,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.12),
                  ),
                ),
                if (showDecline)
                  LineChartBarData(
                    spots: spots.sublist(dd.peakIndex, dd.troughIndex + 1),
                    isCurved: true,
                    curveSmoothness: 0.15,
                    color: declineColor,
                    barWidth: 3.5,
                    // Points uniquement au sommet et au creux.
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, _) =>
                          spot.x == dd.peakIndex || spot.x == dd.troughIndex,
                      getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                        radius: 5,
                        color: Theme.of(context).colorScheme.surface,
                        strokeWidth: 3,
                        strokeColor: declineColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Formatters.date(points.first.date), style: labelStyle),
            Text(Formatters.date(points.last.date), style: labelStyle),
          ],
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
