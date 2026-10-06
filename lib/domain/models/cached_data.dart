/// Donnée du repository, avec sa date et son origine (cache ou réseau).
class CachedData<T> {
  const CachedData(this.data, this.lastUpdated, {this.isStale = false});

  final T data;
  final DateTime lastUpdated;

  /// Indique si le cache est obsolète.
  final bool isStale;
}
