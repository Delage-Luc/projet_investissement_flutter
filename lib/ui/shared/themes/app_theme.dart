import 'package:flutter/material.dart';

/// Direction artistique « Carnet » : un carnet de notes d'investisseur.
///
/// - Clair : papier crème, encre presque noire, accent indigo, surligneur
///   safran. Sombre : encre de nuit, papier devenu texte, accent safran.
/// - Titres en serif (police système, aucune dépendance réseau) pour un ton
///   éditorial ; chiffres à chasse fixe pour que les montants s'alignent.
/// - Cartes plates bordées d'un trait fin plutôt qu'ombrées, coins généreux,
///   boutons en pilule : on s'éloigne volontairement du Material par défaut.
class AppTheme {
  const AppTheme._();

  /// Police des titres : la serif du système (Noto Serif sur Android).
  static const String displayFont = 'serif';

  static ThemeData get light => _build(_lightPalette);
  static ThemeData get dark => _build(_darkPalette);

  static const _Palette _lightPalette = _Palette(
    brightness: Brightness.light,
    background: Color(0xFFF4EFE6),
    surface: Color(0xFFFFFBF4),
    surfaceAlt: Color(0xFFEAE3D5),
    ink: Color(0xFF1C1B22),
    inkSoft: Color(0xFF615C69),
    line: Color(0xFFD9D0BF),
    primary: Color(0xFF3730A3),
    onPrimary: Color(0xFFFFFBF4),
    highlight: Color(0xFFF2A541),
    onHighlight: Color(0xFF1C1B22),
    teal: Color(0xFF1E8C80),
    gain: Color(0xFF1B8A5A),
    loss: Color(0xFFD1434B),
    warning: Color(0xFFC77A0A),
    navBar: Color(0xFF1C1B22),
    onNavBar: Color(0xFFF4EFE6),
  );

  static const _Palette _darkPalette = _Palette(
    brightness: Brightness.dark,
    background: Color(0xFF111017),
    surface: Color(0xFF1A1921),
    surfaceAlt: Color(0xFF25232E),
    ink: Color(0xFFF2ECE1),
    inkSoft: Color(0xFFA7A1B1),
    line: Color(0xFF33303D),
    primary: Color(0xFFF2B04E),
    onPrimary: Color(0xFF1A1405),
    highlight: Color(0xFFF2B04E),
    onHighlight: Color(0xFF1A1405),
    teal: Color(0xFF5CC8B8),
    gain: Color(0xFF4CC38A),
    loss: Color(0xFFFF6B6B),
    warning: Color(0xFFF5B94A),
    navBar: Color(0xFF1F1D27),
    onNavBar: Color(0xFFF2ECE1),
  );

  static ThemeData _build(_Palette p) {
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: Color.alphaBlend(
        p.primary.withValues(alpha: 0.14),
        p.surface,
      ),
      onPrimaryContainer: p.ink,
      secondary: p.highlight,
      onSecondary: p.onHighlight,
      secondaryContainer: Color.alphaBlend(
        p.highlight.withValues(alpha: 0.22),
        p.surface,
      ),
      onSecondaryContainer: p.ink,
      tertiary: p.teal,
      onTertiary: p.surface,
      tertiaryContainer: Color.alphaBlend(
        p.teal.withValues(alpha: 0.18),
        p.surface,
      ),
      onTertiaryContainer: p.ink,
      error: p.loss,
      onError: p.surface,
      errorContainer: Color.alphaBlend(
        p.loss.withValues(alpha: 0.16),
        p.surface,
      ),
      onErrorContainer: p.ink,
      surface: p.background,
      onSurface: p.ink,
      onSurfaceVariant: p.inkSoft,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceAlt,
      surfaceContainerHighest: p.surfaceAlt,
      outline: p.inkSoft,
      outlineVariant: p.line,
      inverseSurface: p.ink,
      onInverseSurface: p.background,
      inversePrimary: p.highlight,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: p.brightness,
    );
    final text = _textTheme(base.textTheme, p);
    const radius = 22.0;
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: p.line),
    );
    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(40));
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: p.line),
    );

    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: text,
      dividerColor: p.line,
      splashFactory: InkSparkle.splashFactory,
      extensions: [
        AppColors(
          gain: p.gain,
          loss: p.loss,
          warning: p.warning,
          highlight: p.highlight,
          onHighlight: p.onHighlight,
          line: p.line,
          card: p.surface,
          cardAlt: p.surfaceAlt,
          tooltip: p.navBar,
          onTooltip: p.onNavBar,
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        // Taille explicite : le textTheme de ThemeData n'a pas encore ses
        // tailles ici (elles sont fusionnées plus tard par Theme.of).
        titleTextStyle: TextStyle(
          color: p.ink,
          fontFamily: displayFont,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        iconTheme: IconThemeData(color: p.ink),
        actionsIconTheme: IconThemeData(color: p.ink),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: cardShape,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.inkSoft,
        titleTextStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        subtitleTextStyle: text.bodyMedium?.copyWith(color: p.inkSoft),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.navBar,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: p.highlight,
        indicatorShape: pill,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? p.onHighlight
                : p.onNavBar.withValues(alpha: 0.7),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? p.onNavBar
                : p.onNavBar.withValues(alpha: 0.7),
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.ink,
          foregroundColor: p.background,
          disabledBackgroundColor: p.line,
          shape: pill,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          side: BorderSide(color: p.ink, width: 1.4),
          shape: pill,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.brightness == Brightness.light
              ? p.primary
              : p.highlight,
          shape: pill,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: p.ink),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(pill),
          side: WidgetStatePropertyAll(BorderSide(color: p.ink, width: 1.2)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.ink : p.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.background : p.ink,
          ),
          textStyle: WidgetStatePropertyAll(
            text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        disabledBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.line.withValues(alpha: 0.5)),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.ink, width: 1.6),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.loss),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.loss, width: 1.6),
        ),
        labelStyle: TextStyle(color: p.inkSoft),
        floatingLabelStyle: TextStyle(
          color: p.ink,
          fontWeight: FontWeight.w700,
        ),
        prefixIconColor: p.inkSoft,
        suffixStyle: TextStyle(color: p.inkSoft, fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(p.surface),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.line),
        ),
        textStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: p.line),
        ),
        titleTextStyle: TextStyle(
          color: p.ink,
          fontFamily: displayFont,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.navBar,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.onNavBar),
        actionTextColor: p.highlight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        iconColor: p.ink,
        collapsedIconColor: p.inkSoft,
        textColor: p.ink,
        collapsedTextColor: p.ink,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.brightness == Brightness.light ? p.primary : p.highlight,
        linearTrackColor: p.surfaceAlt,
        circularTrackColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.navBar,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(color: p.onNavBar),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, _Palette p) {
    // Ajoute les tailles Material 3 pour que les styles dérivés ci-dessous
    // (barre, onglets, boutons…) aient une taille même hors de Theme.of.
    final themed = Typography.englishLike2021
        .merge(base)
        .apply(bodyColor: p.ink, displayColor: p.ink);
    TextStyle? serif(TextStyle? s, {FontWeight weight = FontWeight.w700}) =>
        s?.copyWith(
          fontFamily: displayFont,
          fontWeight: weight,
          letterSpacing: -0.5,
        );
    return themed.copyWith(
      displayLarge: serif(themed.displayLarge),
      displayMedium: serif(themed.displayMedium),
      displaySmall: serif(themed.displaySmall),
      headlineLarge: serif(themed.headlineLarge),
      headlineMedium: serif(themed.headlineMedium),
      headlineSmall: serif(themed.headlineSmall),
      titleLarge: serif(themed.titleLarge),
      titleMedium: themed.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      labelMedium: themed.labelMedium?.copyWith(
        color: p.inkSoft,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
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
  });

  final Color gain;
  final Color loss;
  final Color warning;

  /// Surligneur safran (indicateurs, poignée de la fiche résultat…).
  final Color highlight;
  final Color onHighlight;

  /// Trait fin des cartes et séparateurs.
  final Color line;
  final Color card;
  final Color cardAlt;

  /// Fond et texte des bulles d'information des graphiques.
  final Color tooltip;
  final Color onTooltip;

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
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
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
    );
  }
}

class _Palette {
  const _Palette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkSoft,
    required this.line,
    required this.primary,
    required this.onPrimary,
    required this.highlight,
    required this.onHighlight,
    required this.teal,
    required this.gain,
    required this.loss,
    required this.warning,
    required this.navBar,
    required this.onNavBar,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color inkSoft;
  final Color line;
  final Color primary;
  final Color onPrimary;
  final Color highlight;
  final Color onHighlight;
  final Color teal;
  final Color gain;
  final Color loss;
  final Color warning;
  final Color navBar;
  final Color onNavBar;
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
