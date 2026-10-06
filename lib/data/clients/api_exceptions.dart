/// Erreur remontée par l'accès à l'API distante.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Réseau indisponible (pas de connexion, délai dépassé…).
class NetworkException extends ApiException {
  const NetworkException([super.message = 'Réseau indisponible.']);
}

/// Quota de l'API gratuite dépassé (HTTP 429).
class RateLimitException extends ApiException {
  const RateLimitException()
      : super('Trop de requêtes : réessaie dans une minute.', statusCode: 429);
}
