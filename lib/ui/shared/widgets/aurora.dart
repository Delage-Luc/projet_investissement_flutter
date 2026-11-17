import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';

/// Fond animé de toute l'application : trois halos de lumière qui dérivent
/// lentement sur une nuit (ou une nacre en mode clair), plus une fine grille.
///
/// Animation programmée : un [AnimationController] en boucle (40 s) pilote un
/// [CustomPainter] ; seul le fond est repeint, isolé par un [RepaintBoundary].
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _AuroraPainter(
              animation: _controller,
              base: colors.base,
              blobs: colors.aurora,
              intensity: isDark ? 0.55 : 0.75,
              gridColor: colors.line.withValues(alpha: isDark ? 0.18 : 0.35),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.animation,
    required this.base,
    required this.blobs,
    required this.intensity,
    required this.gridColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color base;
  final List<Color> blobs;
  final double intensity;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);

    final t = animation.value * 2 * math.pi;
    final w = size.width;
    final h = size.height;
    // Trajectoires de Lissajous : chaque halo suit sa propre boucle.
    final centers = [
      Offset(w * (0.2 + 0.25 * math.sin(t)), h * (0.18 + 0.12 * math.cos(t * 2))),
      Offset(w * (0.85 + 0.2 * math.cos(t)), h * (0.45 + 0.2 * math.sin(t))),
      Offset(w * (0.35 + 0.3 * math.cos(t * 2)), h * (0.9 + 0.1 * math.sin(t))),
    ];
    final radius = math.max(w, h) * 0.55;
    for (var i = 0; i < blobs.length && i < centers.length; i++) {
      final c = centers[i];
      final paint = Paint()
        ..shader = ui.Gradient.radial(c, radius, [
          blobs[i].withValues(alpha: intensity),
          blobs[i].withValues(alpha: 0),
        ]);
      canvas.drawCircle(c, radius, paint);
    }

    // Grille fine qui s'estompe vers le bas : effet « tableau de bord ».
    const step = 36.0;
    final grid = Paint()
      ..strokeWidth = 0.6
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, h * 0.6), [
        gridColor,
        gridColor.withValues(alpha: 0),
      ]);
    for (var x = 0.0; x < w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h * 0.6), grid);
    }
    for (var y = 0.0; y < h * 0.6; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.base != base ||
      old.intensity != intensity ||
      old.gridColor != gridColor ||
      !_sameColors(old.blobs, blobs);

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Carte en verre : remplissage translucide, bord lumineux en dégradé et,
/// en option, un halo coloré ([glow]) ou un remplissage dégradé ([gradient]).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 26,
    this.glow,
    this.gradient,
    this.onTap,
    this.blur = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Couleur du halo projeté autour de la carte (null : aucun).
  final Color? glow;

  /// Remplit la carte d'un dégradé au lieu du verre translucide.
  final Gradient? gradient;
  final VoidCallback? onTap;

  /// Floute ce qui est derrière (plus coûteux : réservé aux grandes surfaces).
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(radius);

    Widget content = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );

    content = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: gradient == null ? colors.card : null,
        gradient: gradient,
      ),
      child: content,
    );

    if (blur) {
      content = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          if (glow != null)
            // Halo uniquement à l'extérieur : il ne teinte pas le verre.
            BoxShadow(
              color: glow!.withValues(alpha: isDark ? 0.45 : 0.3),
              blurRadius: 24,
              blurStyle: BlurStyle.outer,
            ),
        ],
      ),
      // Bord fin peint par-dessus le verre, teinté par le halo éventuel.
      child: CustomPaint(
        foregroundPainter: _GradientBorderPainter(
          radius: radius,
          gradient: LinearGradient(
            colors: [
              glow?.withValues(alpha: 0.6) ?? colors.line,
              glow?.withValues(alpha: 0.6) ?? colors.line,
            ],
          ),
        ),
        child: ClipRRect(borderRadius: borderRadius, child: content),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  _GradientBorderPainter({required this.radius, required this.gradient});

  final double radius;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 1.3;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter old) =>
      old.radius != radius || old.gradient != gradient;
}

/// Texte peint avec le dégradé de marque (ou [gradient]).
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final shader = gradient ?? AppColors.of(context).brandGradient;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => shader.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style, maxLines: maxLines, overflow: overflow),
    );
  }
}

/// Titre de page pour les [AppBar] : grand, et qui rétrécit plutôt que
/// d'être coupé quand il est long.
class PageTitle extends StatelessWidget {
  const PageTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
    );
  }
}

/// Barre de progression néon : piste en verre, remplissage qui s'anime
/// jusqu'à [value] (entre 0 et 1) et brille légèrement.
class NeonBar extends StatelessWidget {
  const NeonBar({
    super.key,
    required this.value,
    this.colors,
    this.height = 10,
  });

  final double value;
  final List<Color>? colors;
  final double height;

  @override
  Widget build(BuildContext context) {
    final app = AppColors.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final fill = colors ?? [primary, primary];
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Container(
        height: height,
        decoration: BoxDecoration(
          color: app.card,
          borderRadius: BorderRadius.circular(height),
          border: Border.all(color: app.line.withValues(alpha: 0.5)),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: fill),
              borderRadius: BorderRadius.circular(height),
              boxShadow: [
                BoxShadow(
                  color: fill.last.withValues(alpha: 0.55),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Apparition en glissé-fondu, décalée selon [index] (cascade de cartes).
/// Ne se rejoue pas quand le widget est reconstruit au même endroit. Seuls
/// les premiers éléments sont décalés : ceux qui arrivent en défilant
/// apparaissent tout de suite.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = index < 10 ? index * 55 : 0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Interval(
        delay / (420 + delay),
        1,
        curve: Curves.easeOutCubic,
      ),
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 28 * (1 - v)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
