class ValidationException implements Exception {
  final Map<String, dynamic> errors;
  final String message;

  ValidationException({required this.errors, this.message = 'Validasi gagal.'});

  @override
  String toString() => 'ValidationException: $message\n$errors';
}
