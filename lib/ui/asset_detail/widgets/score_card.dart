import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/asset_score.dart';
import 'package:projet_investissement_flutter/domain/models/glossary.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/animated_number_text.dart';
import 'package:projet_investissement_flutter/ui/shared/widgets/aurora.dart';
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

    final scoreColor = _scoreColor(context, total);

    return GlassCard(
      glow: scoreColor,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Score de la période',
                    style: textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(child: _ScoreGauge(score: total, color: scoreColor)),
            const SizedBox(height: 16),
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
    );
  }

  static Color _scoreColor(BuildContext context, double score) {
    final colors = AppColors.of(context);
    if (score >= 65) return colors.gain;
    if (score >= 40) return colors.warning;
    return colors.loss;
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
          NeonBar(value: c.score / 100),
        ],
      ),
    );
  }
}

/// Jauge circulaire du score : un arc de 270° en dégradé qui se remplit
/// (TweenAnimationBuilder), avec le nombre qui défile au centre.
class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({required this.score, required this.color});

  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 190,
      height: 190,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score.clamp(0, 100) / 100),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => CustomPaint(
          painter: _GaugePainter(
            progress: v,
            track: colors.card,
            trackBorder: colors.line,
            gradient: [...colors.brand, color],
            glow: color,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedNumberText(
                  value: score,
                  format: (x) => '${x.round()}',
                  duration: const Duration(milliseconds: 1400),
                  style: textTheme.displayMedium?.copyWith(
                    color: color,
                    fontFeatures: tabularFigures,
                    shadows: [
                      Shadow(color: color.withValues(alpha: 0.7), blurRadius: 24),
                    ],
                  ),
                ),
                Text(
                  'SUR 100',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.4,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.track,
    required this.trackBorder,
    required this.gradient,
    required this.glow,
  });

  final double progress;
  final Color track;
  final Color trackBorder;
  final List<Color> gradient;
  final Color glow;

  static const double _start = math.pi * 0.75;
  static const double _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = (Offset.zero & size).deflate(stroke);
    Paint arc(double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width;

    // Piste : un liseré clair, puis le fond de verre.
    canvas.drawArc(rect, _start, _sweep, false, arc(stroke)..color = trackBorder);
    canvas.drawArc(rect, _start, _sweep, false, arc(stroke - 3)..color = track);
    if (progress <= 0) return;

    // Halo flou sous l'arc, puis l'arc net en dégradé par-dessus.
    canvas.drawArc(
      rect,
      _start,
      _sweep * progress,
      false,
      arc(stroke)
        ..color = glow.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawArc(
      rect,
      _start,
      _sweep * progress,
      false,
      arc(stroke)
        ..shader = SweepGradient(
          startAngle: _start,
          endAngle: _start + _sweep,
          colors: gradient,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.glow != glow || old.track != track;
}
