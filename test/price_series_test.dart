import 'package:flutter_test/flutter_test.dart';
import 'package:projet_investissement_flutter/domain/models/price_point.dart';
import 'package:projet_investissement_flutter/utils/price_series.dart';

void main() {
  test('garde le dernier point de chaque jour, daté à minuit UTC', () {
    final result = toDailySeries([
      PricePoint(date: DateTime.utc(2024, 1, 1, 8), price: 10),
      PricePoint(date: DateTime.utc(2024, 1, 1, 20), price: 12),
      PricePoint(date: DateTime.utc(2024, 1, 2, 3), price: 15),
    ]);
    expect(result.length, 2);
    expect(result[0].date, DateTime.utc(2024, 1, 1));
    expect(result[0].price, 12);
    expect(result[1].date, DateTime.utc(2024, 1, 2));
    expect(result[1].price, 15);
  });

  test('trie par date croissante', () {
    final result = toDailySeries([
      PricePoint(date: DateTime.utc(2024, 1, 3), price: 3),
      PricePoint(date: DateTime.utc(2024, 1, 1), price: 1),
      PricePoint(date: DateTime.utc(2024, 1, 2), price: 2),
    ]);
    expect(result.map((p) => p.price).toList(), [1, 2, 3]);
  });

  test('série vide -> liste vide', () {
    expect(toDailySeries(const []), isEmpty);
  });
}
