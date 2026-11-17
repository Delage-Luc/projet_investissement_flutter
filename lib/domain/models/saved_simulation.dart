import 'dart:convert';

import 'package:projet_investissement_flutter/domain/models/projection.dart';

/// Simulation enregistrée par l'utilisateur (donnée métier persistée).
/// Le résultat est stocké avec les paramètres : il reste consultable hors
/// connexion et ne change pas si les cours sont mis à jour ensuite.
class SavedSimulation {
  const SavedSimulation({
    this.id,
    required this.name,
    required this.createdAt,
    required this.vsCurrency,
    required this.input,
    required this.result,
    required this.lumpSum,
  });

  /// null tant que la simulation n'a pas été insérée en base.
  final int? id;
  final String name;
  final DateTime createdAt;

  /// Devise des montants au moment de la simulation.
  final String vsCurrency;
  final SimulationInput input;

  /// Investissement programmé (DCA).
  final ProjectionResult result;

  /// Même somme placée en une fois au départ, pour comparaison.
  final ProjectionResult lumpSum;

  static const String typeFixedRate = 'fixed_rate';
  static const String typeCrypto = 'crypto';

  String get type => input.isCrypto ? typeCrypto : typeFixedRate;

  SavedSimulation copyWith({int? id}) => SavedSimulation(
    id: id ?? this.id,
    name: name,
    createdAt: createdAt,
    vsCurrency: vsCurrency,
    input: input,
    result: result,
    lumpSum: lumpSum,
  );

  /// Ligne de la table `saved_simulations`.
  factory SavedSimulation.fromRow(Map<String, Object?> row) {
    final params =
        jsonDecode(row['params_json'] as String) as Map<String, dynamic>;
    final results =
        jsonDecode(row['result_json'] as String) as Map<String, dynamic>;
    return SavedSimulation(
      id: row['id'] as int?,
      name: row['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['created_at_ms'] as int,
        isUtc: true,
      ),
      vsCurrency: params['vsCurrency'] as String? ?? 'eur',
      input: SimulationInput.fromJson(params),
      result: ProjectionResult.fromJson(results['dca'] as List<dynamic>),
      lumpSum: ProjectionResult.fromJson(
        results['lumpSum'] as List<dynamic>? ?? const [],
      ),
    );
  }

  Map<String, Object?> toRow() => {
    if (id != null) 'id': id,
    'name': name,
    'type': type,
    'params_json': jsonEncode({...input.toJson(), 'vsCurrency': vsCurrency}),
    'result_json': jsonEncode({
      'dca': result.toJson(),
      'lumpSum': lumpSum.toJson(),
    }),
    'created_at_ms': createdAt.toUtc().millisecondsSinceEpoch,
  };
}
