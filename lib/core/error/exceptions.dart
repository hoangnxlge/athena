class LocalException implements Exception {
  final String message;

  LocalException(this.message);

  @override
  String toString() {
    return 'LocalException: $message';
  }
}

class LunaException implements Exception {
  final String message;

  LunaException(this.message);

  @override
  String toString() {
    return 'LunaException: $message';
  }
}
