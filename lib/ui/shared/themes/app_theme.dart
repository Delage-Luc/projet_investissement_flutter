import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Direction artistique « Aurora ».
///
/// Une aurore boréale animée en fond de toute l'application ([AuroraBackground]),
/// des cartes en verre translucide posées dessus, des accents néon et une
/// typographie XXL en dégradé.
///
/// - Sombre (identité principale) : nuit spatiale, violet → cyan, accent lime.
/// - Clair : nacre lavande, aurore pastel, violet → bleu ciel.
///
/// Les écrans gardent un fond transparent : c'est l'aurore, dessinée une seule
/// fois au-dessus du routeur, qui sert de fond à toutes les pages.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(_lightPalette);
  static ThemeData get dark => _build(_darkPalette);

  static const _Palette _darkPalette = _Palette(
    brightness: Brightness.dark,
    base: Color(0xFF07060F),
    aurora: [Color(0xFF7C3AED), Color(0xFF06B6D4), Color(0xFFDB2777)],
    ink: Color(0xFFF5F3FF),
    inkSoft: Color(0xFFA5A0C4),
    glassFill: Color(0x14FFFFFF),
    glassFillStrong: Color(0x22FFFFFF),
    glassBorder: Color(0x33FFFFFF),
    primary: Color(0xFFA78BFA),
    onPrimary: Color(0xFF12082B),
    secondary: Color(0xFF22D3EE),
    highlight: Color(0xFFC6F432),
    onHighlight: Color(0xFF0B0D02),
    gain: Color(0xFF34F5A0),
    loss: Color(0xFFFF4D79),
    warning: Color(0xFFFFC23D),
    panel: Color(0xEE15122A),
    onPanel: Color(0xFFF5F3FF),
    brand: [Color(0xFFA78BFA), Color(0xFF22D3EE), Color(0xFFC6F432)],
  );

  static const _Palette _lightPalette = _Palette(
    brightness: Brightness.light,
    base: Color(0xFFF4F1FF),
    aurora: [Color(0xFFC4B5FD), Color(0xFF99F6E4), Color(0xFFFBCFE8)],
    ink: Color(0xFF130F26),
    inkSoft: Color(0xFF5B5675),
    glassFill: Color(0xA6FFFFFF),
    glassFillStrong: Color(0xD9FFFFFF),
    glassBorder: Color(0xCCFFFFFF),
    primary: Color(0xFF6D28D9),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF0284C7),
    highlight: Color(0xFFDB2777),
    onHighlight: Color(0xFFFFFFFF),
    gain: Color(0xFF059669),
    loss: Color(0xFFE11D48),
    warning: Color(0xFFD97706),
    panel: Color(0xF2130F26),
    onPanel: Color(0xFFF5F3FF),
    brand: [Color(0xFF6D28D9), Color(0xFFDB2777), Color(0xFF0284C7)],
  );

  static ThemeData _build(_Palette p) {
    final isDark = p.brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.glassFillStrong,
      onPrimaryContainer: p.ink,
      secondary: p.secondary,
      onSecondary: p.onPrimary,
      secondaryContainer: Color.alphaBlend(
        p.primary.withValues(alpha: 0.18),
        p.glassFill,
      ),
      onSecondaryContainer: p.ink,
      tertiary: p.highlight,
      onTertiary: p.onHighlight,
      tertiaryContainer: p.glassFillStrong,
      onTertiaryContainer: p.ink,
      error: p.loss,
      onError: Colors.white,
      errorContainer: Color.alphaBlend(
        p.loss.withValues(alpha: 0.22),
        isDark ? const Color(0xFF15122A) : Colors.white,
      ),
      onErrorContainer: p.ink,
      surface: p.base,
      onSurface: p.ink,
      onSurfaceVariant: p.inkSoft,
      surfaceContainerLowest: p.glassFill,
      surfaceContainerLow: p.glassFill,
      surfaceContainer: p.glassFill,
      surfaceContainerHigh: p.glassFillStrong,
      surfaceContainerHighest: p.glassFillStrong,
      outline: p.inkSoft,
      outlineVariant: p.glassBorder,
      inverseSurface: p.panel,
      onInverseSurface: p.onPanel,
      inversePrimary: p.highlight,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = _textTheme(base.textTheme, p);
    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(40));
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: p.glassBorder),
    );
    // Fond opaque pour ce qui flotte au-dessus du contenu (menus, dialogues).
    final floating = isDark ? const Color(0xFF17142C) : const Color(0xFFFFFFFF);

    return base.copyWith(
      // Transparent : l'aurore animée sert de fond à toutes les pages.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: floating,
      textTheme: text,
      dividerColor: p.glassBorder,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      extensions: [
        AppColors(
          gain: p.gain,
          loss: p.loss,
          warning: p.warning,
          highlight: p.highlight,
          onHighlight: p.onHighlight,
          line: p.glassBorder,
          card: p.glassFill,
          cardAlt: p.glassFillStrong,
          tooltip: p.panel,
          onTooltip: p.onPanel,
          base: p.base,
          aurora: p.aurora,
          brand: p.brand,
          floating: floating,
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        // Icônes de la barre d'état lisibles sur l'aurore (claire ou sombre).
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        centerTitle: false,
        titleSpacing: 20,
        toolbarHeight: 72,
        titleTextStyle: TextStyle(
          color: p.ink,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.4,
          height: 1,
        ),
        iconTheme: IconThemeData(color: p.ink),
        actionsIconTheme: IconThemeData(color: p.ink),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: p.glassFill,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(color: p.glassBorder),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.inkSoft,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodyMedium?.copyWith(color: p.inkSoft),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? p.glassFillStrong
                : p.primary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? p.inkSoft : p.onPrimary,
          ),
          // Ombre colorée : le bouton « brille » au lieu d'être ombré.
          elevation: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? 0 : 10,
          ),
          shadowColor: WidgetStatePropertyAll(p.primary.withValues(alpha: 0.8)),
          shape: WidgetStatePropertyAll(pill),
          minimumSize: const WidgetStatePropertyAll(Size(0, 56)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24),
          ),
          textStyle: WidgetStatePropertyAll(
            text.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          side: BorderSide(color: p.glassBorder, width: 1.4),
          shape: pill,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? p.highlight : p.primary,
          shape: pill,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: p.ink),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(pill),
          side: WidgetStatePropertyAll(BorderSide(color: p.glassBorder)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.primary : p.glassFill,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.onPrimary : p.ink,
          ),
          textStyle: WidgetStatePropertyAll(
            text.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 46)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.glassFill,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        disabledBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.glassBorder.withValues(alpha: 0.4)),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.secondary, width: 2),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.loss),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.loss, width: 2),
        ),
        labelStyle: TextStyle(color: p.inkSoft),
        floatingLabelStyle: TextStyle(
          color: p.secondary,
          fontWeight: FontWeight.w800,
        ),
        hintStyle: TextStyle(color: p.inkSoft),
        prefixIconColor: p.inkSoft,
        suffixStyle: TextStyle(color: p.inkSoft, fontWeight: FontWeight.w700),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(floating),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: floating,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.glassBorder),
        ),
        textStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: floating,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: p.glassBorder),
        ),
        titleTextStyle: TextStyle(
          color: p.ink,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.panel,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: p.onPanel,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: isDark ? p.highlight : const Color(0xFFC4B5FD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: p.primary.withValues(alpha: 0.6)),
        ),
        elevation: 0,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        iconColor: p.ink,
        collapsedIconColor: p.inkSoft,
        textColor: p.ink,
        collapsedTextColor: p.ink,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.secondary,
        linearTrackColor: p.glassFill,
        circularTrackColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: p.glassBorder, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: floating,
        surfaceTintColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.panel,
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(color: p.onPanel),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, _Palette p) {
    // Tailles Material 3 incluses pour les styles utilisés hors Theme.of.
    final themed = Typography.englishLike2021
        .merge(base)
        .apply(bodyColor: p.ink, displayColor: p.ink);
    TextStyle? display(TextStyle? s, double spacing) => s?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: spacing,
          height: 1.05,
        );
    return themed.copyWith(
      displayLarge: display(themed.displayLarge, -2.5),
      displayMedium: display(themed.displayMedium, -2),
      displaySmall: display(themed.displaySmall, -1.6),
      headlineLarge: display(themed.headlineLarge, -1.4),
      headlineMedium: display(themed.headlineMedium, -1.2),
      headlineSmall: display(themed.headlineSmall, -1),
      titleLarge: themed.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.6,
      ),
      titleMedium: themed.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      labelMedium: themed.labelMedium?.copyWith(
        color: p.inkSoft,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

/// Couleurs propres à l'application, absentes du [ColorScheme] standard.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.gain,
    required this.loss,
    required this.warning,
    required this.highlight,
    required this.onHighlight,
    required this.line,
    required this.card,
    required this.cardAlt,
    required this.tooltip,
    required this.onTooltip,
    required this.base,
    required this.aurora,
    required this.brand,
    required this.floating,
  });

  final Color gain;
  final Color loss;
  final Color warning;

  /// Accent néon (lime en sombre, magenta en clair).
  final Color highlight;
  final Color onHighlight;

  /// Bord et remplissages « verre ».
  final Color line;
  final Color card;
  final Color cardAlt;

  /// Fond et texte des bulles des graphiques et des SnackBars.
  final Color tooltip;
  final Color onTooltip;

  /// Couleur de fond sous l'aurore, et les trois couleurs de l'aurore.
  final Color base;
  final List<Color> aurora;

  /// Dégradé de marque (titres, jauges, cartes mises en avant).
  final List<Color> brand;

  /// Fond opaque des éléments flottants (menus, dialogues).
  final Color floating;

  LinearGradient get brandGradient => LinearGradient(
        colors: brand,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? gain,
    Color? loss,
    Color? warning,
    Color? highlight,
    Color? onHighlight,
    Color? line,
    Color? card,
    Color? cardAlt,
    Color? tooltip,
    Color? onTooltip,
    Color? base,
    List<Color>? aurora,
    List<Color>? brand,
    Color? floating,
  }) =>
      AppColors(
        gain: gain ?? this.gain,
        loss: loss ?? this.loss,
        warning: warning ?? this.warning,
        highlight: highlight ?? this.highlight,
        onHighlight: onHighlight ?? this.onHighlight,
        line: line ?? this.line,
        card: card ?? this.card,
        cardAlt: cardAlt ?? this.cardAlt,
        tooltip: tooltip ?? this.tooltip,
        onTooltip: onTooltip ?? this.onTooltip,
        base: base ?? this.base,
        aurora: aurora ?? this.aurora,
        brand: brand ?? this.brand,
        floating: floating ?? this.floating,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    List<Color> lerpList(List<Color> a, List<Color> b) => [
          for (var i = 0; i < a.length && i < b.length; i++)
            Color.lerp(a[i], b[i], t)!,
        ];
    return AppColors(
      gain: Color.lerp(gain, other.gain, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      onHighlight: Color.lerp(onHighlight, other.onHighlight, t)!,
      line: Color.lerp(line, other.line, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      tooltip: Color.lerp(tooltip, other.tooltip, t)!,
      onTooltip: Color.lerp(onTooltip, other.onTooltip, t)!,
      base: Color.lerp(base, other.base, t)!,
      aurora: lerpList(aurora, other.aurora),
      brand: lerpList(brand, other.brand),
      floating: Color.lerp(floating, other.floating, t)!,
    );
  }
}

class _Palette {
  const _Palette({
    required this.brightness,
    required this.base,
    required this.aurora,
    required this.ink,
    required this.inkSoft,
    required this.glassFill,
    required this.glassFillStrong,
    required this.glassBorder,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.highlight,
    required this.onHighlight,
    required this.gain,
    required this.loss,
    required this.warning,
    required this.panel,
    required this.onPanel,
    required this.brand,
  });

  final Brightness brightness;
  final Color base;
  final List<Color> aurora;
  final Color ink;
  final Color inkSoft;
  final Color glassFill;
  final Color glassFillStrong;
  final Color glassBorder;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color highlight;
  final Color onHighlight;
  final Color gain;
  final Color loss;
  final Color warning;
  final Color panel;
  final Color onPanel;
  final List<Color> brand;
}

/// Chiffres à chasse fixe : les montants restent alignés et ne « dansent »
/// pas pendant les animations de nombres.
const List<FontFeature> tabularFigures = [FontFeature.tabularFigures()];

/// Vert pour un gain, rouge pour une perte, neutre si inconnu.
Color pnlColor(BuildContext context, double? value) {
  if (value == null) return Theme.of(context).colorScheme.onSurfaceVariant;
  final colors = AppColors.of(context);
  return value >= 0 ? colors.gain : colors.loss;
}
