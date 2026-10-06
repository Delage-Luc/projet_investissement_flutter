import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Courbe des prix avec la date et le cours au toucher.
class PriceChart extends StatelessWidget {
  const PriceChart({
    super.key,
    required this.points,
    required this.vsCurrency,
    required this.color,
  });

  final List<PricePoint> points;
  final String vsCurrency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text('Pas assez de données pour tracer la courbe.')),
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
                  getTooltipItems: (touched) => touched.map((spot) {
                    final point = points[spot.spotIndex];
                    return LineTooltipItem(
                      '${Formatters.date(point.date)}\n'
                      '${Formatters.price(point.price, vsCurrency)}',
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
      ],
    );
  }
}
