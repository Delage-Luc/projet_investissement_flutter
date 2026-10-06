enum AsyncStatus { initial, loading, success, error }

/// État asynchrone partagé entre le ViewModel et l'interface.
class AsyncState<T> {
  const AsyncState.initial()
      : status = AsyncStatus.initial,
        data = null,
        error = null,
        lastUpdated = null,
        isStale = false;

  const AsyncState.loading({this.data, this.lastUpdated, this.isStale = false})
      : status = AsyncStatus.loading,
        error = null;

  const AsyncState.success(T this.data,
      {required this.lastUpdated, this.isStale = false})
      : status = AsyncStatus.success,
        error = null;

  const AsyncState.error(this.error, {this.data, this.lastUpdated})
      : status = AsyncStatus.error,
        isStale = false;

  final AsyncStatus status;
  final T? data;
  final Object? error;

  /// Dernière actualisation des données.
  final DateTime? lastUpdated;

  /// Indique que les données viennent du cache après une erreur réseau.
  final bool isStale;

  bool get hasData => data != null;
  bool get isLoading => status == AsyncStatus.loading;
}
