import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:wifiber/models/employee.dart';
import 'package:wifiber/services/employee_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';

class EmployeeProvider extends SafeChangeNotifier {
  final EmployeeService _employeeService;

  EmployeeProvider(this._employeeService);

  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _validationErrors;

  List<Employee> get employees => _employees;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Map<String, dynamic>? get validationErrors => _validationErrors;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message, {Map<String, dynamic>? validationErrors}) {
    _error = message;
    _validationErrors = validationErrors;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _validationErrors = null;
    notifyListeners();
  }

  void _debugLog(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[EmployeeProvider] $message');
      if (error != null) {
        print('[EmployeeProvider] Error: $error');
      }
      if (stackTrace != null) {
        print('[EmployeeProvider] StackTrace: $stackTrace');
      }
    }

    developer.log(
      message,
      name: 'EmployeeProvider',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _debugPrintResponse(dynamic response, String operation) {
    if (kDebugMode) {
      print('[EmployeeProvider] $operation Response Details:');
      if (response != null) {
        try {
          if (response is String) {
            final decoded = jsonDecode(response);
            final prettyJson = const JsonEncoder.withIndent(
              '  ',
            ).convert(decoded);
            print('[EmployeeProvider] Response Body: $prettyJson');
          } else {
            final prettyJson = const JsonEncoder.withIndent(
              '  ',
            ).convert(response);
            print('[EmployeeProvider] Response Object: $prettyJson');
          }
        } catch (e) {
          print('[EmployeeProvider] Raw Response: $response');
        }
      }
    }
  }

  Future<void> loadEmployees({String? search}) async {
    _debugLog('Loading employees with search: $search');
    _setLoading(true);

    try {
      final response = await _employeeService.getEmployees(search: search);
      _debugPrintResponse(response, 'loadEmployees');

      _employees = response.data;
      _setError(null);
      _debugLog('Successfully loaded ${_employees.length} employees');
    } catch (e, stackTrace) {
      _employees = [];
      final errorMessage = _parseErrorMessage(e);
      _setError(errorMessage);
      _debugLog('Failed to load employees', error: e, stackTrace: stackTrace);

      if (kDebugMode) {
        print('[EmployeeProvider] =================================');
        print('[EmployeeProvider] LOAD EMPLOYEES ERROR DETAILS:');
        print('[EmployeeProvider] Error Type: ${e.runtimeType}');
        print('[EmployeeProvider] Error String: ${e.toString()}');
        print('[EmployeeProvider] Parsed Message: $errorMessage');
        print('[EmployeeProvider] =================================');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadEmployees();

  Future<bool> createEmployee(Map<String, dynamic> data) async {
    _debugLog('Creating employee with data: ${jsonEncode(data)}');
    _setLoading(true);
    _setError(null);

    try {
      final success = await _employeeService.createEmployee(data);
      _debugLog('Create employee result: $success');

      if (success) {
        await loadEmployees();
        _debugLog('Employee created successfully');
        return true;
      }

      final errorMessage = 'Gagal menambahkan karyawan';
      _setError(errorMessage);
      _debugLog('Create employee failed: $errorMessage');
      return false;
    } catch (e, stackTrace) {
      final errorData = _parseError(e);
      _setError(
        errorData['message'],
        validationErrors: errorData['validationErrors'],
      );
      _debugLog('Failed to create employee', error: e, stackTrace: stackTrace);

      if (kDebugMode) {
        print('[EmployeeProvider] =================================');
        print('[EmployeeProvider] CREATE EMPLOYEE ERROR DETAILS:');
        print('[EmployeeProvider] Request Data: ${jsonEncode(data)}');
        print('[EmployeeProvider] Error Type: ${e.runtimeType}');
        print('[EmployeeProvider] Error String: ${e.toString()}');
        print('[EmployeeProvider] Parsed Message: ${errorData['message']}');
        print(
          '[EmployeeProvider] Validation Errors: ${errorData['validationErrors']}',
        );

        if (e is ValidationException) {
          print('[EmployeeProvider] ValidationException Details:');
          print('[EmployeeProvider] - Message: ${e.message}');
          print('[EmployeeProvider] - Errors: ${jsonEncode(e.errors)}');
        }
        print('[EmployeeProvider] =================================');
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEmployee(String id, Map<String, dynamic> data) async {
    _debugLog('Updating employee $id with data: ${jsonEncode(data)}');
    _setLoading(true);
    _setError(null);

    try {
      final employee = await _employeeService.updateEmployee(id, data);
      _debugPrintResponse(employee.toJson(), 'updateEmployee');

      final index = _employees.indexWhere((e) => e.id == id);
      if (index != -1) {
        _employees[index] = employee;
        _debugLog('Employee updated at index $index');
      } else {
        _debugLog('Warning: Updated employee not found in local list');
      }

      notifyListeners();
      _debugLog('Employee updated successfully');
      return true;
    } catch (e, stackTrace) {
      final errorData = _parseError(e);
      _setError(
        errorData['message'],
        validationErrors: errorData['validationErrors'],
      );
      _debugLog('Failed to update employee', error: e, stackTrace: stackTrace);

      if (kDebugMode) {
        print('[EmployeeProvider] =================================');
        print('[EmployeeProvider] UPDATE EMPLOYEE ERROR DETAILS:');
        print('[EmployeeProvider] Employee ID: $id');
        print('[EmployeeProvider] Request Data: ${jsonEncode(data)}');
        print('[EmployeeProvider] Error Type: ${e.runtimeType}');
        print('[EmployeeProvider] Error String: ${e.toString()}');
        print('[EmployeeProvider] Parsed Message: ${errorData['message']}');
        print(
          '[EmployeeProvider] Validation Errors: ${errorData['validationErrors']}',
        );

        if (e is ValidationException) {
          print('[EmployeeProvider] ValidationException Details:');
          print('[EmployeeProvider] - Message: ${e.message}');
          print('[EmployeeProvider] - Errors: ${jsonEncode(e.errors)}');
        }
        print('[EmployeeProvider] =================================');
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEmployee(String id) async {
    _debugLog('Deleting employee with id: $id');
    _setLoading(true);
    _setError(null);

    try {
      final success = await _employeeService.deleteEmployee(id);
      _debugLog('Delete employee result: $success');

      if (success) {
        _employees.removeWhere((e) => e.id == id);
        notifyListeners();
        _debugLog('Employee deleted successfully');
        return true;
      }

      final errorMessage = 'Gagal menghapus karyawan';
      _setError(errorMessage);
      _debugLog('Delete employee failed: $errorMessage');
      return false;
    } catch (e, stackTrace) {
      final errorMessage = _parseErrorMessage(e);
      _setError(errorMessage);
      _debugLog('Failed to delete employee', error: e, stackTrace: stackTrace);

      if (kDebugMode) {
        print('[EmployeeProvider] =================================');
        print('[EmployeeProvider] DELETE EMPLOYEE ERROR DETAILS:');
        print('[EmployeeProvider] Employee ID: $id');
        print('[EmployeeProvider] Error Type: ${e.runtimeType}');
        print('[EmployeeProvider] Error String: ${e.toString()}');
        print('[EmployeeProvider] Parsed Message: $errorMessage');
        print('[EmployeeProvider] =================================');
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _parseErrorMessage(dynamic error) {
    if (error is Exception) {
      String message = error.toString();

      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }

      if (message.contains('422')) {
        return 'Data yang dimasukkan tidak valid';
      } else if (message.contains('409')) {
        return 'Data sudah ada sebelumnya';
      } else if (message.contains('401')) {
        return 'Tidak memiliki izin untuk melakukan aksi ini';
      } else if (message.contains('403')) {
        return 'Akses ditolak';
      } else if (message.contains('404')) {
        return 'Data tidak ditemukan';
      } else if (message.contains('500')) {
        return 'Terjadi kesalahan pada server';
      } else if (message.contains('network') ||
          message.contains('connection')) {
        return 'Periksa koneksi internet Anda';
      }

      return message;
    }

    return error?.toString() ?? 'Terjadi kesalahan yang tidak diketahui';
  }

  Map<String, dynamic> _parseError(dynamic error) {
    String message = 'Terjadi kesalahan yang tidak diketahui';
    Map<String, dynamic>? validationErrors;

    if (error is ValidationException) {
      message = error.message;
      validationErrors = error.errors;

      _debugLog('ValidationException caught: $message');
      _debugLog('Validation errors: ${jsonEncode(validationErrors)}');
    } else if (error is Exception) {
      String errorString = error.toString();

      if (errorString.startsWith('Exception: ')) {
        errorString = errorString.substring(11);
      }

      if (errorString.contains('email') && errorString.contains('unique')) {
        message = 'Email sudah digunakan';
        validationErrors = {'email': 'Email sudah digunakan'};
      } else if (errorString.contains('username') &&
          errorString.contains('unique')) {
        message = 'Username sudah digunakan';
        validationErrors = {'username': 'Username sudah digunakan'};
      } else if (errorString.contains('validation')) {
        message = 'Data yang dimasukkan tidak valid';

        validationErrors = {};
        if (errorString.contains('name')) {
          validationErrors['name'] = 'Nama tidak valid';
        }
        if (errorString.contains('email')) {
          validationErrors['email'] = 'Format email tidak valid';
        }
        if (errorString.contains('password')) {
          validationErrors['password'] = 'Password tidak memenuhi kriteria';
        }
        if (errorString.contains('role')) {
          validationErrors['role'] = 'Role tidak valid';
        }

        if (validationErrors.isEmpty) {
          validationErrors = null;
        }
      } else {
        message = _parseErrorMessage(error);
      }
    }

    return {'message': message, 'validationErrors': validationErrors};
  }
}
