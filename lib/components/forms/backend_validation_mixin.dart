import 'package:flutter/material.dart';

mixin BackendValidationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String?> _backendErrors = {};

  GlobalKey<FormState> get formKey;

  void clearBackendErrors() {
    if (_backendErrors.isNotEmpty) {
      setState(() => _backendErrors.clear());
    }
  }

  void setBackendErrors(Map<String, dynamic> errors) {
    _backendErrors
      ..clear()
      ..addAll(
        errors.map((key, value) => MapEntry(key, _parseFirstError(value))),
      );
    setState(() {});
    formKey.currentState?.validate();
  }

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

  String? backendErrorFor(String field) => _backendErrors[field];

  String? _parseFirstError(dynamic value) {
    if (value is List && value.isNotEmpty) return value.first.toString();
    return value?.toString();
  }
}
