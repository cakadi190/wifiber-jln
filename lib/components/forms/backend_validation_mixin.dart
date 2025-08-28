import 'package:flutter/material.dart';

/// Mixin to handle backend validation errors and display them
/// directly in form fields.
mixin BackendValidationMixin<T extends StatefulWidget> on State<T> {
  /// Stores backend errors mapped by field name.
  final Map<String, String?> _backendErrors = {};

  /// Key of the form that should be validated when errors change.
  GlobalKey<FormState> get formKey;

  /// Clears currently stored backend errors.
  void clearBackendErrors() {
    if (_backendErrors.isNotEmpty) {
      setState(() => _backendErrors.clear());
    }
  }

  /// Set new backend errors and trigger form validation to show them.
  void setBackendErrors(Map<String, dynamic> errors) {
    _backendErrors
      ..clear()
      ..addAll(errors.map((key, value) => MapEntry(key, _parseFirstError(value))));
    setState(() {});
    formKey.currentState?.validate();
  }

  /// Returns validator that combines local validation with backend errors.
  String? Function(String?) validator(
    String field, [
    String? Function(String?)? localValidator,
  ]) {
    return (value) {
      final local = localValidator?.call(value);
      if (local != null) return local;
      return _backendErrors[field];
    };
  }

  String? _parseFirstError(dynamic value) {
    if (value is List && value.isNotEmpty) return value.first.toString();
    return value?.toString();
  }
}
