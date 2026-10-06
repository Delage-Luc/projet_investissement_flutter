import 'package:projet_investissement_flutter/utils/finance_calculator.dart';

enum DcaFrequency {
  weekly('Hebdomadaire'),
  monthly('Mensuelle');

  const DcaFrequency(this.label);
  final String label;
}

/// Un achat simulé.
class DcaPurchase {
  const DcaPurchase({
    required this.date,
    required this.price,
    required this.amount,
    required this.quantity,
  });

  final DateTime date;
  final double price;
  final double amount;
  final double quantity;
}

/// Résultat d'une simulation DCA.
class DcaResult {
  const DcaResult({
    required this.purchases,
    required this.totalInvested,
    required this.totalQuantity,
    required this.finalValue,
  });

  static const DcaResult empty = DcaResult(
    purchases: [],
    totalInvested: 0,
    totalQuantity: 0,
    finalValue: 0,
  );

  final List<DcaPurchase> purchases;
  final double totalInvested;
  final double totalQuantity;
  final double finalValue;

  bool get isEmpty => purchases.isEmpty;
  double get gain => finalValue - totalInvested;

  /// null si aucun montant n'a été investi.
  double? get performancePercent =>
      FinanceCalculator.variationPercent(totalInvested, finalValue);
}
