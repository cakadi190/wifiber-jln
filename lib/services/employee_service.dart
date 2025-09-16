import 'dart:convert';
import 'dart:developer' as developer;
import 'package:wifiber/models/employee.dart';
import 'package:wifiber/services/http_service.dart';

class EmployeeService {
  static final HttpService _http = HttpService();
  static const String path = 'employees';

  static void _debugLog(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'EmployeeService',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<EmployeeResponse> getEmployees({String? search}) async {
    _debugLog('getEmployees called with search: $search');

    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      _debugLog('Making GET request to: $path with params: ${jsonEncode(params)}');

      final response = await _http.get(
        path,
        requiresAuth: true,
        parameters: params.isNotEmpty ? params : null,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final employeeResponse = EmployeeResponse.fromJson(jsonData);
        _debugLog('Successfully parsed ${employeeResponse.data.length} employees');
        return employeeResponse;
      } else {
        final errorMessage = 'Failed to load employees: ${response.statusCode}';
        _debugLog(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      _debugLog('getEmployees failed', error: e, stackTrace: stackTrace);

      rethrow;
    }
  }

  Future<bool> createEmployeeForm(Map<String, String> fields) async {
    _debugLog('createEmployeeForm called with fields: ${jsonEncode(fields)}');

    try {
      _debugLog('Making POST form request to: $path');

      final response = await _http.postForm(
        path,
        fields: fields,
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final success = jsonData['success'] == true;
        _debugLog('createEmployeeForm result: $success');

        return success;
      } else {
        final errorMessage = 'Failed to create employee: ${response.statusCode}';
        _debugLog(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      _debugLog('createEmployeeForm failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> createEmployee(Map<String, dynamic> data) async {
    _debugLog('createEmployee called with data: ${jsonEncode(data)}');

    try {
      _debugLog('Making POST request to: $path');

      final response = await _http.post(
        path,
        body: json.encode(data),
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final success = jsonData['success'] == true;
        _debugLog('createEmployee result: $success');

        return success;
      } else {
        final errorMessage = 'Failed to create employee: ${response.statusCode}';
        _debugLog(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      _debugLog('createEmployee failed', error: e, stackTrace: stackTrace);

      rethrow;
    }
  }

  Future<Employee> updateEmployeeForm(String id, Map<String, String> fields) async {
    _debugLog('updateEmployeeForm called with id: $id, fields: ${jsonEncode(fields)}');

    try {
      final url = '$path/$id';
      _debugLog('Making POST form request to: $url');

      final response = await _http.postForm(
        url,
        fields: fields,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final employee = Employee.fromJson(jsonData['data']);
          _debugLog('updateEmployeeForm successful for id: $id');

          return employee;
        } else {
          final errorMessage = 'Failed to update employee: ${jsonData['message'] ?? 'Unknown error'}';
          _debugLog(errorMessage);
          throw Exception(errorMessage);
        }
      } else {
        final errorMessage = 'Failed to update employee: ${response.statusCode}';
        _debugLog(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      _debugLog('updateEmployeeForm failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Employee> updateEmployee(String id, Map<String, dynamic> data) async {
    _debugLog('updateEmployee called with id: $id, data: ${jsonEncode(data)}');

    try {
      final url = '$path/$id';
      _debugLog('Making POST request to: $url');

      final response = await _http.post(
        url,
        body: json.encode(data),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final employee = Employee.fromJson(jsonData['data']);
          _debugLog('updateEmployee successful for id: $id');

          return employee;
        } else {
          final errorMessage = 'Failed to update employee: ${jsonData['message'] ?? 'Unknown error'}';
          _debugLog(errorMessage);
          throw Exception(errorMessage);
        }
      } else {
        final errorMessage = 'Failed to update employee: ${response.statusCode}';
        _debugLog(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      _debugLog('updateEmployee failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    _debugLog('deleteEmployee called with id: $id');

    try {
      final url = '$path/$id';
      _debugLog('Making DELETE request to: $url');

      final response = await _http.delete(
        url,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final success = jsonData['success'] == true;
        _debugLog('deleteEmployee result: $success');

        return success;
      } else {
        final errorMessage = 'Failed to delete employee: ${response.statusCode}';
        _debugLog(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      _debugLog('deleteEmployee failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}