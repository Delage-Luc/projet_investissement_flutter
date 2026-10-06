import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/data/repositories/settings_repository.dart';

/// Préférences de thème et de devise.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repository);

  final SettingsRepository _repository;

  ThemeMode _themeMode = ThemeMode.system;
  String _vsCurrency = 'eur';

  ThemeMode get themeMode => _themeMode;
  String get vsCurrency => _vsCurrency;

  Future<void> load() async {
    try {
      _themeMode = await _repository.getThemeMode();
      _vsCurrency = await _repository.getVsCurrency();
    } catch (_) {
      // Préférences illisibles : on garde les valeurs par défaut.
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _repository.setThemeMode(mode);
  }

  Future<void> setVsCurrency(String currency) async {
    _vsCurrency = currency;
    notifyListeners();
    await _repository.setVsCurrency(currency);
  }
}
