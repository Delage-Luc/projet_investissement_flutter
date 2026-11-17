import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/glossary.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/learn_more_link.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/aurora.dart';

/// Compare le DCA à la même somme investie en une fois au départ, et
/// explique pourquoi l'une des deux stratégies l'emporte sur ces données.
class StrategyComparison extends StatelessWidget {
  const StrategyComparison({
    super.key,
    required this.input,
    required this.dca,
    required this.lumpSum,
    required this.vsCurrency,
  });

  final SimulationInput input;
  final ProjectionResult dca;
  final ProjectionResult lumpSum;
  final String vsCurrency;

  @override
  Widget build(BuildContext context) {
    // Sans versement mensuel, les deux stratégies sont identiques.
    if (lumpSum.isEmpty || input.monthlyContribution <= 0) {
      return const SizedBox.shrink();
    }
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final dcaValue = dca.finalValue;
    final lumpValue = lumpSum.finalValue;
    final maxValue = math.max(dcaValue, lumpValue);
    final diff = (dcaValue - lumpValue).abs();
    String money(double v) => Formatters.money(v, vsCurrency);

    return GlassCard(
      glow: AppColors.of(context).highlight,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Et si tu avais tout investi au départ ?',
              style: textTheme.titleLarge?.copyWith(fontSize: 19),
            ),
            const SizedBox(height: 4),
            Text(
              'Même somme totale (${money(lumpSum.totalInvested)}), placée '
              'en une seule fois le premier jour.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _Bar(
              label: 'Chaque mois (DCA)',
              ratio: maxValue <= 0 ? 0 : dcaValue / maxValue,
              color: scheme.primary,
              text: money(dcaValue),
            ),
            const SizedBox(height: 8),
            _Bar(
              label: 'Tout au départ',
              ratio: maxValue <= 0 ? 0 : lumpValue / maxValue,
              color: AppColors.of(context).highlight,
              text: money(lumpValue),
            ),
            const SizedBox(height: 12),
            Text(_explanation(diff, money)),
            Wrap(
              children: const [
                LearnMoreLink(termId: GlossaryTerms.dca),
                LearnMoreLink(termId: GlossaryTerms.lumpSum),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _explanation(double diff, String Function(double) money) {
    final dcaWins = dca.finalValue > lumpSum.finalValue;
    if (diff < 1) {
      return 'Les deux stratégies arrivent au même résultat.';
    }
    if (!input.isCrypto) {
      return input.annualRatePercent >= 0
          ? 'Avec un rendement fixe positif, l\'argent placé tôt travaille plus '
                'longtemps : tout investir au départ rapporte ${money(diff)} de '
                'plus. Mais un vrai marché n\'est jamais régulier : le DCA évite '
                'de tout investir juste avant une baisse.'
          : 'Avec un rendement négatif, chaque euro placé tôt perd plus '
                'longtemps : le DCA limite la casse de ${money(diff)}.';
    }
    final name = input.cryptoAsset!.name;
    return dcaWins
        ? 'Le DCA rapporte ${money(diff)} de plus : le cours de $name a baissé '
              'à certains moments, et chaque versement a alors acheté davantage '
              'd\'unités à prix réduit.'
        : 'Tout investir au départ rapporte ${money(diff)} de plus : le cours '
              'de $name a surtout monté, donc l\'argent placé tôt a profité de '
              'toute la hausse. Sur une autre période, le résultat aurait pu '
              's\'inverser.';
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.ratio,
    required this.color,
    required this.text,
  });

  final String label;
  final double ratio;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            Text(
              text,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontFeatures: tabularFigures,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        NeonBar(
          value: ratio,
          height: 12,
          colors: [color.withValues(alpha: 0.55), color],
        ),
      ],
    );
  }
}
