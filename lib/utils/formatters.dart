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

  static String date(DateTime d) =>
      DateFormat('dd/MM/yyyy', _locale).format(d.toLocal());

  static String dateTime(DateTime d) =>
      DateFormat('dd/MM/yyyy HH:mm', _locale).format(d.toLocal());
}