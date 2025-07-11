class StringException implements Exception {
  StringException(this.message);
  final String message;

  @override
  String toString() => message;
}