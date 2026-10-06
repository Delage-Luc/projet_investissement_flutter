import 'package:projet_investissement_flutter/domain/models/price_point.dart';

/// Garde le dernier cours de chaque jour UTC et trie les dates.
List<PricePoint> toDailySeries(Iterable<PricePoint> points) {
  final sorted = points.toList()..sort((a, b) => a.date.compareTo(b.date));
  final byDay = <DateTime, PricePoint>{};
  for (final p in sorted) {
    final day = PricePoint.dayStart(p.date);
    byDay[day] = PricePoint(date: day, price: p.price);
  }
  return byDay.values.toList();
}
