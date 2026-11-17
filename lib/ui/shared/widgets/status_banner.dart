import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Affiche la date des données et signale le mode hors connexion, sous forme
/// d'étiquette « en direct » : un point qui pulse (vert = à jour,
/// orange = données du cache).
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.lastUpdated,
    required this.isStale,
  });

  final DateTime lastUpdated;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final dot = isStale ? colors.warning : colors.gain;
    final text = isStale
        ? 'HORS CONNEXION · ${Formatters.dateTime(lastUpdated)}'
        : 'À JOUR · ${Formatters.dateTime(lastUpdated)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: dot.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: dot.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isStale)
                Icon(Icons.cloud_off_rounded, size: 14, color: dot)
              else
                _PulsingDot(color: dot),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Point qui « respire » (AnimationController en aller-retour).
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.8),
              blurRadius: 4 + 8 * _controller.value,
              spreadRadius: 2 * _controller.value,
            ),
          ],
        ),
      ),
    );
  }
}
