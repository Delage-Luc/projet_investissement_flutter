import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/chart_period.dart';

/// Choix de la période affichée (30 j / 90 j / 1 an).
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ChartPeriod selected;
  final ValueChanged<ChartPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ChartPeriod>(
      segments: [
        for (final p in ChartPeriod.values)
          ButtonSegment(value: p, label: Text(p.label)),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}
