import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/chart_period.dart';
import 'package:projet_investissement_flutter/domain/models/glossary.dart';
import 'package:projet_investissement_flutter/domain/models/risk.dart';
import 'package:projet_investissement_flutter/ui/asset_detail/view_models/asset_detail_view_model.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/learn_more_link.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// « Ce que ça signifie » : les indicateurs traduits en phrases concrètes,
/// recalculées à partir des données réelles de la période choisie.
class InsightsCard extends StatelessWidget {
  const InsightsCard({
    super.key,
    required this.detail,
    required this.assetName,
  });

  final AssetDetailViewModel detail;
  final String assetName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final vs = detail.vsCurrency;
    final periodText = _periodText(detail.period);
    final items = <Widget>[];

    // 1. Et si j'avais investi 100 € ?
    final whatIf = detail.whatIfValue;
    if (whatIf != null) {
      const amount = AssetDetailViewModel.whatIfAmount;
      final diff = whatIf - amount;
      items.add(
        _Insight(
          icon: Icons.savings_outlined,
          color: pnlColor(context, diff),
          text:
              'Si tu avais investi ${Formatters.money(amount, vs)} dans '
              '$assetName $periodText, tu aurais environ '
              '${Formatters.price(whatIf, vs)} aujourd\'hui '
              '(${diff >= 0 ? 'gain' : 'perte'} de '
              '${Formatters.price(diff.abs(), vs)}).',
          termId: GlossaryTerms.performance,
        ),
      );
    }

    // 2. Le pire moment.
    final dd = detail.drawdown;
    if (dd != null) {
      items.add(
        _Insight(
          icon: Icons.trending_down,
          color: Theme.of(context).colorScheme.error,
          text: dd.hasDecline
              ? 'Pire moment : du ${Formatters.date(dd.peak.date)} au '
                    '${Formatters.date(dd.trough.date)} (${dd.durationDays} j), '
                    'le prix a chuté de ${Formatters.unsignedPercent(dd.percent)}. '
                    'Quelqu\'un entré au sommet aurait '
                    'vu ${Formatters.money(100, vs)} devenir '
                    '${Formatters.money(100 * (1 + dd.percent / 100), vs)}. '
                    'C\'est la portion en rouge sur le graphique.'
              : 'Aucune baisse sur la période : le prix n\'a fait que monter. '
                    'C\'est rare, surtout pour une crypto.',
          termId: GlossaryTerms.drawdown,
        ),
      );
    }

    // 3. Volatilité interprétée, comparée au Bitcoin.
    final vol = detail.volatility;
    final level = detail.volatilityLevel;
    if (vol != null && level != null) {
      final reference = detail.referenceVolatility;
      final comparison = reference == null
          ? ''
          : ' Pour comparer, le ${AssetDetailViewModel.referenceAssetName} : '
                '${_volText(reference)} sur la même période'
                '${_comparisonWord(vol, reference)}.';
      items.add(
        _Insight(
          icon: Icons.waves,
          color: _levelColor(context, level),
          text:
              'Volatilité ${level.label} (${_volText(vol)}) : '
              '${level.meaning}$comparison',
          termId: GlossaryTerms.volatility,
        ),
      );
    }

    // 4. Les jours de hausse et de baisse.
    final total = detail.upDays + detail.downDays;
    if (total > 0) {
      items.add(
        _Insight(
          icon: Icons.calendar_month_outlined,
          color: Theme.of(context).colorScheme.primary,
          text:
              'Le prix a monté ${detail.upDays} jours et baissé '
              '${detail.downDays} jours. Même quand la tendance est bonne, '
              'les jours de baisse sont nombreux : regarder le prix chaque jour '
              'donne une image trompeuse.',
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline),
                const SizedBox(width: 8),
                Text('Ce que ça signifie', style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  static String _periodText(ChartPeriod period) => switch (period) {
    ChartPeriod.month => 'il y a 30 jours',
    ChartPeriod.quarter => 'il y a 90 jours',
    ChartPeriod.year => 'il y a un an',
  };

  static String _volText(double v) => '${Formatters.unsignedPercent(v)} par an';

  static String _comparisonWord(double vol, double reference) {
    if (reference <= 0) return '';
    final ratio = vol / reference;
    if (ratio > 1.15) {
      final times = ratio.toStringAsFixed(1).replaceAll('.', ',');
      return ', donc $times fois plus agité';
    }
    if (ratio < 0.85) return ', donc plus calme';
    return ', donc comparable';
  }

  static Color _levelColor(BuildContext context, VolatilityLevel level) =>
      switch (level) {
        VolatilityLevel.low => pnlColor(context, 1),
        VolatilityLevel.moderate => Colors.orange.shade700,
        VolatilityLevel.high => pnlColor(context, -1),
      };
}

class _Insight extends StatelessWidget {
  const _Insight({
    required this.icon,
    required this.color,
    required this.text,
    this.termId,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String? termId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text),
                if (termId != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LearnMoreLink(termId: termId!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
