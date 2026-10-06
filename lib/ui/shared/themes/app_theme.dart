import 'package:flutter/material.dart';

/// Thèmes clair et sombre (Material 3).
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF0E7C66);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: const CardThemeData(margin: EdgeInsets.zero),
    );
  }
}

/// Vert pour un gain, rouge pour une perte, neutre si inconnu.
Color pnlColor(BuildContext context, double? value) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (value == null) return Theme.of(context).colorScheme.onSurfaceVariant;
  if (value >= 0) return isDark ? Colors.green.shade400 : Colors.green.shade700;
  return isDark ? Colors.red.shade300 : Colors.red.shade700;
}
