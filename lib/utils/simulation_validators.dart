/// Lecture et validation des champs du formulaire de simulation.
/// Chaque validateur renvoie un message d'erreur, ou null si la saisie est valide
/// (convention de `TextFormField.validator`).
class SimulationValidators {
  const SimulationValidators._();

  static const double maxAmount = 1e9;
  static const double minRate = -50;
  static const double maxRate = 100;
  static const int minYears = 1;
  static const int maxYears = 50;

  /// Accepte la virgule décimale et les espaces (« 1 000,5 »).
  /// Renvoie null si le texte n'est pas un nombre fini.
  static double? parseNumber(String? raw) {
    if (raw == null) return null;
    final cleaned =
        raw.replaceAll(RegExp(r'[\s\u00A0\u202F]'), '').replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    final value = double.tryParse(cleaned);
    return (value != null && value.isFinite) ? value : null;
  }

  static String? initialCapital(String? value) =>
      _amount(value, emptyMessage: 'Saisis un montant (0 si aucun).');

  /// [initialValue] : texte du capital initial, pour exiger au moins un des deux.
  static String? monthlyContribution(String? value, {String? initialValue}) {
    final error =
        _amount(value, emptyMessage: 'Saisis un montant (0 si aucun).');
    if (error != null) return error;
    final contribution = parseNumber(value)!;
    final initial = parseNumber(initialValue) ?? 0;
    if (contribution + initial <= 0) {
      return 'Saisis au moins un capital ou un versement.';
    }
    return null;
  }

  static String? annualRate(String? value) {
    final rate = parseNumber(value);
    if (rate == null) return 'Saisis un pourcentage valide.';
    if (rate < minRate || rate > maxRate) {
      return 'Entre ${minRate.toInt()} % et ${maxRate.toInt()} %.';
    }
    return null;
  }

  static String? years(String? value) {
    final years = parseNumber(value);
    if (years == null) return 'Saisis un nombre d\'années.';
    if (years != years.truncateToDouble()) return 'Un nombre entier d\'années.';
    if (years < minYears || years > maxYears) {
      return 'Entre $minYears et $maxYears ans.';
    }
    return null;
  }

  static String? _amount(String? value, {required String emptyMessage}) {
    if (value == null || value.trim().isEmpty) return emptyMessage;
    final amount = parseNumber(value);
    if (amount == null) return 'Nombre invalide.';
    if (amount < 0) return 'Le montant ne peut pas être négatif.';
    if (amount > maxAmount) return 'Montant trop élevé.';
    return null;
  }
}