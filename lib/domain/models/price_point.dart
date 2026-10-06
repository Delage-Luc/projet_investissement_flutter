/// Prix d'un actif à une date, en UTC.
class PricePoint {
  const PricePoint({required this.date, required this.price});

  final DateTime date;
  final double price;

  /// Crée un point depuis une paire `[timestamp_ms, prix]` de l'API.
  factory PricePoint.fromApi(List<dynamic> pair) => PricePoint(
        date: DateTime.fromMillisecondsSinceEpoch(
          (pair[0] as num).toInt(),
          isUtc: true,
        ),
        price: (pair[1] as num).toDouble(),
      );

  /// Ramène la date à minuit UTC.
  static DateTime dayStart(DateTime d) {
    final u = d.toUtc();
    return DateTime.utc(u.year, u.month, u.day);
  }
}
