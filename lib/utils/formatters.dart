import 'package:intl/intl.dart';

/// Formatage des montants, pourcentages et dates (locale fr_FR).
class Formatters {
  const Formatters._();

  static const String _locale = 'fr_FR';

  static String currencySymbol(String vsCurrency) {
    switch (vsCurrency.toLowerCase()) {
      case 'eur':
        return '€';
      case 'usd':
        return r'$';
      default:
        return vsCurrency.toUpperCase();
    }
  }

  /// Plus le prix est petit, plus on affiche de décimales.
  static String price(double value, String vsCurrency) {
    final decimals = value >= 1 ? 2 : (value >= 0.01 ? 4 : 6);
    return NumberFormat.currency(
      locale: _locale,
      symbol: currencySymbol(vsCurrency),
      decimalDigits: decimals,
    ).format(value);
  }

  /// Montant arrondi à l'unité (résultats de simulation).
  static String money(double value, String vsCurrency) {
    return NumberFormat.currency(
      locale: _locale,
      symbol: currencySymbol(vsCurrency),
      decimalDigits: 0,
    ).format(value);
  }

  static String percent(double? value) {
    if (value == null) return '—';
    final sign = value > 0 ? '+' : '';
    return '$sign${NumberFormat('0.00', _locale).format(value)} %';
  }

  /// Montant abrégé pour les axes des graphiques (« 58 k€ », « 0,91 € »).
  static String compactMoney(double value, String vsCurrency) {
    final symbol = currencySymbol(vsCurrency);
    final abs = value.abs();
    if (abs >= 1000) {
      return '${NumberFormat.compact(locale: _locale).format(value)} $symbol';
    }
    final decimals = abs >= 100 ? 0 : (abs >= 1 ? 1 : (abs >= 0.01 ? 3 : 5));
    return '${NumberFormat.decimalPatternDigits(locale: _locale, decimalDigits: decimals).format(value)} $symbol';
  }

  /// Date courte pour les axes (« 05/10 »).
  static String shortDate(DateTime d) =>
      DateFormat('dd/MM', _locale).format(d.toLocal());

  /// Pourcentage sans signe (« 28,00 % »), pour les phrases explicatives.
  static String unsignedPercent(double value) =>
      '${NumberFormat('0.0', _locale).format(value.abs())} %';

  static String date(DateTime d) =>
      DateFormat('dd/MM/yyyy', _locale).format(d.toLocal());

  static String dateTime(DateTime d) =>
      DateFormat('dd/MM/yyyy HH:mm', _locale).format(d.toLocal());
}
