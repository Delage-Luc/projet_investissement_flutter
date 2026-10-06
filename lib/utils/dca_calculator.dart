import 'dart:math' as math;

import 'package:projet_investissement_flutter/domain/models/dca.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';

/// Simule des investissements périodiques (DCA).
class DcaCalculator {
  const DcaCalculator._();

  /// [history] est trié par date croissante, avec un cours par jour.
  /// Chaque échéance utilise le premier cours disponible à cette date ou après.
  static DcaResult simulate({
    required List<PricePoint> history,
    required double amountPerPeriod,
    required DcaFrequency frequency,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (history.isEmpty || amountPerPeriod <= 0) return DcaResult.empty;

    final start = PricePoint.dayStart(startDate ?? history.first.date);
    final end = PricePoint.dayStart(endDate ?? history.last.date);
    if (end.isBefore(start)) return DcaResult.empty;

    final purchases = <DcaPurchase>[];
    var cursor = 0;
    for (var i = 0;; i++) {
      final scheduled = _scheduledDate(start, frequency, i);
      if (scheduled.isAfter(end)) break;
      while (cursor < history.length &&
          history[cursor].date.isBefore(scheduled)) {
        cursor++;
      }
      if (cursor >= history.length) break;
      final point = history[cursor];
      if (point.date.isAfter(end)) break;
      if (point.price <= 0) continue;
      purchases.add(DcaPurchase(
        date: point.date,
        price: point.price,
        amount: amountPerPeriod,
        quantity: amountPerPeriod / point.price,
      ));
    }
    if (purchases.isEmpty) return DcaResult.empty;

    final priceAtEnd = history
        .lastWhere((p) => !p.date.isAfter(end), orElse: () => history.first)
        .price;
    final totalQuantity = purchases.fold<double>(0, (s, p) => s + p.quantity);
    return DcaResult(
      purchases: purchases,
      totalInvested: amountPerPeriod * purchases.length,
      totalQuantity: totalQuantity,
      finalValue: totalQuantity * priceAtEnd,
    );
  }

  static DateTime _scheduledDate(DateTime start, DcaFrequency f, int index) {
    switch (f) {
      case DcaFrequency.weekly:
        return start.add(Duration(days: 7 * index));
      case DcaFrequency.monthly:
        // Garde le même jour du mois quand il existe.
        final first = DateTime.utc(start.year, start.month + index);
        final lastDay = DateTime.utc(first.year, first.month + 1, 0).day;
        return DateTime.utc(first.year, first.month, math.min(start.day, lastDay));
    }
  }
}
