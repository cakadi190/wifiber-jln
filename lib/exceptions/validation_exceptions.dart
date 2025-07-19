class ValidationException implements Exception {
  final Map<String, dynamic> errors;
  final String message;

  ValidationException({required this.errors, required this.message});

  String getFormattedErrors() {
    final buffer = StringBuffer();
    errors.forEach((field, messages) {
      if (messages is List) {
        for (final message in messages) {
          buffer.writeln('$field: $message');
        }
      } else {
        buffer.writeln('$field: $messages');
      }
    });
    return buffer.toString().trim();
  }

  List<String> getFieldErrors(String field) {
    final fieldErrors = errors[field];
    if (fieldErrors == null) return [];

    if (fieldErrors is List) {
      return fieldErrors.cast<String>();
    } else {
      return [fieldErrors.toString()];
    }
  }

  String? getFirstFieldError(String field) {
    final fieldErrors = getFieldErrors(field);
    return fieldErrors.isEmpty ? null : fieldErrors.first;
  }

  @override
  String toString() => '$message\n${getFormattedErrors()}';
}
