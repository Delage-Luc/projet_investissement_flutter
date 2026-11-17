import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/asset_score.dart';
import 'package:projet_investissement_flutter/domain/models/glossary.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/animated_number_text.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/learn_more_link.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Score explicable : la note totale, puis le détail de chaque critère
/// (valeur mesurée, note, poids, règle) pour pouvoir refaire le calcul.
class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.score});

  final AssetScore score;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final total = score.total;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Score de la période',
                    style: textTheme.titleMedium,
                  ),
                ),
                AnimatedNumberText(
                  value: total,
                  format: (v) => '${v.round()}/100',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _scoreColor(total),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final c in score.criteria) _CriterionRow(criterion: c),
            Theme(
              // Retire les séparateurs de l'ExpansionTile dans la carte.
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(
                  'Comment est-il calculé ?',
                  style: textTheme.labelLarge,
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final c in score.criteria)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• ${c.label} (poids ${(c.weight * 100).round()} %) : '
                        '${c.rule}',
                        style: textTheme.bodySmall,
                      ),
                    ),
                  Text(
                    'Score = ${score.criteria.map((c) => '${c.score.round()} × '
                        '${c.weight.toString().replaceAll('.', ',')}').join(' + ')}'
                    ' = ${total.round()}/100',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ce score résume le passé sur la période choisie : '
                    'ce n\'est ni une prédiction ni un conseil d\'investissement.',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const LearnMoreLink(termId: GlossaryTerms.score),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _scoreColor(double score) {
    if (score >= 65) return Colors.green.shade600;
    if (score >= 40) return Colors.orange.shade700;
    return Colors.red.shade600;
  }
}

class _CriterionRow extends StatelessWidget {
  const _CriterionRow({required this.criterion});

  final ScoreCriterion criterion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = criterion;
    final measured = c.label == 'Stabilité'
        ? 'volatilité ${Formatters.unsignedPercent(c.measured)}/an'
        : Formatters.percent(c.measured);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${c.label} · $measured',
                  style: textTheme.bodyMedium,
                ),
              ),
              Text('${c.score.round()}/100', style: textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 4),
          // La barre se remplit jusqu'à la note (et glisse si elle change).
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: c.score / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: value, minHeight: 8),
            ),
          ),
        ],
      ),
    );
  }
}
