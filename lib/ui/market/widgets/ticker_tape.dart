import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/ui/shared/themes/app_theme.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';

/// Bandeau défilant façon salle de marché : symbole et variation 24 h des
/// actifs déjà chargés, en boucle infinie. Purement décoratif : il réutilise
/// les données du marché et ne déclenche aucun appel.
///
/// Animation programmée : un [Ticker] avance la liste de [_speed] pixels par
/// seconde ; la liste est infinie (index modulo le nombre d'actifs).
class TickerTape extends StatefulWidget {
  const TickerTape({super.key, required this.assets});

  final List<CryptoAsset> assets;

  @override
  State<TickerTape> createState() => _TickerTapeState();
}

class _TickerTapeState extends State<TickerTape>
    with SingleTickerProviderStateMixin {
  static const double _speed = 38;

  final ScrollController _scroll = ScrollController();
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_scroll.hasClients) _scroll.jumpTo(_scroll.offset + _speed * dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assets = widget.assets;
    if (assets.isEmpty) return const SizedBox.shrink();
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 34,
      // Fondu sur les bords : le texte apparaît et disparaît en douceur.
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0, 0.08, 0.92, 1],
        ).createShader(rect),
        child: ListView.builder(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final asset = assets[index % assets.length];
            final change = asset.priceChange24h;
            final color = pnlColor(context, change);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Text(
                    asset.symbol.toUpperCase(),
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    (change ?? 0) >= 0
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    color: color,
                  ),
                  Text(
                    Formatters.percent(change),
                    style: textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontFeatures: tabularFigures,
                      shadows: [
                        Shadow(color: color.withValues(alpha: 0.6), blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.line,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
