import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';

/// Bornes et pas de l'axe vertical d'un graphique : une marge autour des
/// valeurs et quatre graduations régulières.
class AxisRange {
  AxisRange._(this.min, this.max, this.interval);

  /// [floorAtZero] empêche l'axe de descendre sous 0 (montants investis).
  factory AxisRange.from(
    double minValue,
    double maxValue, {
    bool floorAtZero = false,
    int divisions = 4,
  }) {
    var range = maxValue - minValue;
    // Série plate : on ouvre artificiellement l'axe pour éviter un pas nul.
    if (range <= 0) range = minValue.abs() * 0.1 + 1;
    final padding = range * 0.08;
    var min = minValue - padding;
    if (floorAtZero && min < 0) min = 0;
    final max = maxValue + padding;
    return AxisRange._(min, max, (max - min) / divisions);
  }

  final double min;
  final double max;
  final double interval;
}

/// Axes lisibles et discrets pour les graphiques de l'app : valeurs à gauche,
/// repères de temps en bas, grille horizontale en pointillés.
class ChartAxes {
  const ChartAxes._();

  static FlTitlesData titles(
    BuildContext context, {
    required AxisRange y,
    required String Function(double value) leftLabel,
    required double bottomInterval,
    required String? Function(double value) bottomLabel,
    double leftReserved = 54,
  }) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      fontFeatures: tabularFigures,
    );
    const hidden = AxisTitles(sideTitles: SideTitles(showTitles: false));
    return FlTitlesData(
      topTitles: hidden,
      rightTitles: hidden,
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: leftReserved,
          interval: y.interval,
          // Uniquement les graduations régulières : les bornes exactes
          // tomberaient trop près d'elles et se chevaucheraient.
          minIncluded: false,
          maxIncluded: false,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            space: 6,
            child: Text(leftLabel(value), style: style),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 26,
          interval: bottomInterval,
          getTitlesWidget: (value, meta) {
            final label = bottomLabel(value);
            if (label == null) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              space: 6,
              // Garde les libellés des extrémités dans le cadre.
              fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
              child: Text(label, style: style),
            );
          },
        ),
      ),
    );
  }

  static FlGridData grid(BuildContext context, AxisRange y) {
    final line = AppColors.of(context).line;
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: y.interval,
      getDrawingHorizontalLine: (_) =>
          FlLine(color: line, strokeWidth: 0.7, dashArray: const [4, 5]),
    );
  }

  /// Axe gauche et ligne de base, très légers.
  static FlBorderData border(BuildContext context) {
    final line = AppColors.of(context).line;
    return FlBorderData(
      show: true,
      border: Border(
        left: BorderSide(color: line),
        bottom: BorderSide(color: line),
      ),
    );
  }
}
