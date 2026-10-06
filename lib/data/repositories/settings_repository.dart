import 'package:flutter/material.dart' show ThemeMode;
import 'package:projet_investissement_flutter/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Préférences utilisateur (clé-valeur, via SharedPreferencesAsync).
class SettingsRepository {
  SettingsRepository({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  static const String _themeKey = 'theme_mode';
  static const String _currencyKey = 'vs_currency';

  Future<ThemeMode> getThemeMode() async {
    final raw = await _prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);

  Future<String> getVsCurrency() async {
    final raw = await _prefs.getString(_currencyKey);
    return AppConfig.supportedCurrencies.contains(raw)
        ? raw!
        : AppConfig.defaultVsCurrency;
  }

  Future<void> setVsCurrency(String currency) =>
      _prefs.setString(_currencyKey, currency);
}
