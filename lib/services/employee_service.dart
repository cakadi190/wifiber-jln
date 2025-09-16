import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:wifiber/models/employee.dart';
import 'package:wifiber/services/http_service.dart';

class EmployeeService {
  static final HttpService _http = HttpService();
  static const String path = 'employees';

  static void _debugLog(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[EmployeeService] $message');
      if (error != null) {
        debugPrint('[EmployeeService] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[EmployeeService] StackTrace: $stackTrace');
      }
    }
    developer.log(
      message,
      name: 'EmployeeService',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _debugPrintHttpResponse(dynamic response, String operation) {
    if (kDebugMode && response != null) {
      debugPrint('[EmployeeService] =================================');
      debugPrint('[EmployeeService] $operation HTTP RESPONSE:');

      try {
        // Jika response memiliki statusCode (http.Response)
        if (response.statusCode != null) {
          debugPrint('[EmployeeService] Status Code: ${response.statusCode}');
          debugPrint('[EmployeeService] Headers: ${response.headers}');
          debugPrint('[EmployeeService] Content Length: ${response.contentLength}');

          // Parse dan print body dengan indentasi
          try {
            final decoded = jsonDecode(response.body);
            final prettyJson = const JsonEncoder.withIndent('  ').convert(decoded);
            debugPrint('[EmployeeService] Response Body:');
            debugPrint(prettyJson);
          } catch (e) {
            debugPrint('[EmployeeService] Raw Response Body: ${response.body}');
          }
        } else {
          // Jika response adalah object biasa
          final prettyJson = const JsonEncoder.withIndent('  ').convert(response);
          debugPrint('[EmployeeService] Response Object:');
          debugPrint(prettyJson);
        }
      } catch (e) {
        debugPrint('[EmployeeService] Error printing response: $e');
        debugPrint('[EmployeeService] Raw Response: $response');
      }

      debugPrint('[EmployeeService] =================================');
    }
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

      _debugPrintHttpResponse(response, 'GET EMPLOYEES');

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

      if (kDebugMode) {
        debugPrint('[EmployeeService] =================================');
        debugPrint('[EmployeeService] GET EMPLOYEES ERROR DETAILS:');
        debugPrint('[EmployeeService] Error Type: ${e.runtimeType}');
        debugPrint('[EmployeeService] Error Message: ${e.toString()}');
        debugPrint('[EmployeeService] Search Parameter: $search');
        debugPrint('[EmployeeService] =================================');
      }

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

      _debugPrintHttpResponse(response, 'CREATE EMPLOYEE');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final success = jsonData['success'] == true;
        _debugLog('createEmployee result: $success');

        if (kDebugMode) {
          debugPrint('[EmployeeService] Create Employee Success Response:');
          debugPrint('[EmployeeService] - Success: $success');
          debugPrint('[EmployeeService] - Message: ${jsonData['message']}');
          debugPrint('[EmployeeService] - Data: ${jsonData['data']}');
        }

        return success;
      } else {
        final errorMessage = 'Failed to create employee: ${response.statusCode}';
        _debugLog(errorMessage);

        // Print response body untuk error
        if (kDebugMode) {
          debugPrint('[EmployeeService] Create Employee Error Response:');
          debugPrint('[EmployeeService] - Status: ${response.statusCode}');
          debugPrint('[EmployeeService] - Body: ${response.body}');
        }

        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      _debugLog('createEmployee failed', error: e, stackTrace: stackTrace);

      if (kDebugMode) {
        debugPrint('[EmployeeService] =================================');
        debugPrint('[EmployeeService] CREATE EMPLOYEE ERROR DETAILS:');
        debugPrint('[EmployeeService] Request Data: ${jsonEncode(data)}');
        debugPrint('[EmployeeService] Error Type: ${e.runtimeType}');
        debugPrint('[EmployeeService] Error Message: ${e.toString()}');
        debugPrint('[EmployeeService] =================================');
      }

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

      _debugPrintHttpResponse(response, 'UPDATE EMPLOYEE');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final employee = Employee.fromJson(jsonData['data']);
          _debugLog('updateEmployee successful for id: $id');

          if (kDebugMode) {
            debugPrint('[EmployeeService] Update Employee Success Response:');
            debugPrint('[EmployeeService] - Success: ${jsonData['success']}');
            debugPrint('[EmployeeService] - Message: ${jsonData['message']}');
            debugPrint('[EmployeeService] - Updated Employee: ${jsonEncode(employee.toJson())}');
          }

          return employee;
        } else {
          final errorMessage = 'Failed to update employee: ${jsonData['message'] ?? 'Unknown error'}';
          _debugLog(errorMessage);

          if (kDebugMode) {
            debugPrint('[EmployeeService] Update Employee Failed Response:');
            debugPrint('[EmployeeService] - Success: ${jsonData['success']}');
            debugPrint('[EmployeeService] - Message: ${jsonData['message']}');
            debugPrint('[EmployeeService] - Errors: ${jsonData['errors']}');
          }

          throw Exception(errorMessage);
        }
      } else {
        final errorMessage = 'Failed to update employee: ${response.statusCode}';
        _debugLog(errorMessage);

        // Print response body untuk error
        if (kDebugMode) {
          debugPrint('[EmployeeService] Update Employee Error Response:');
          debugPrint('[EmployeeService] - Status: ${response.statusCode}');
          debugPrint('[EmployeeService] - Body: ${response.body}');
        }

        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      _debugLog('updateEmployee failed', error: e, stackTrace: stackTrace);

      if (kDebugMode) {
        debugPrint('[EmployeeService] =================================');
        debugPrint('[EmployeeService] UPDATE EMPLOYEE ERROR DETAILS:');
        debugPrint('[EmployeeService] Employee ID: $id');
        debugPrint('[EmployeeService] Request Data: ${jsonEncode(data)}');
        debugPrint('[EmployeeService] Error Type: ${e.runtimeType}');
        debugPrint('[EmployeeService] Error Message: ${e.toString()}');
        debugPrint('[EmployeeService] =================================');
      }

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

      _debugPrintHttpResponse(response, 'DELETE EMPLOYEE');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final success = jsonData['success'] == true;
        _debugLog('deleteEmployee result: $success');

        if (kDebugMode) {
          debugPrint('[EmployeeService] Delete Employee Response:');
          debugPrint('[EmployeeService] - Success: $success');
          debugPrint('[EmployeeService] - Message: ${jsonData['message']}');
        }

        return success;
      } else {
        final errorMessage = 'Failed to delete employee: ${response.statusCode}';
        _debugLog(errorMessage);

        // Print response body untuk error
        if (kDebugMode) {
          debugPrint('[EmployeeService] Delete Employee Error Response:');
          debugPrint('[EmployeeService] - Status: ${response.statusCode}');
          debugPrint('[EmployeeService] - Body: ${response.body}');
        }

        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      _debugLog('deleteEmployee failed', error: e, stackTrace: stackTrace);

      if (kDebugMode) {
        debugPrint('[EmployeeService] =================================');
        debugPrint('[EmployeeService] DELETE EMPLOYEE ERROR DETAILS:');
        debugPrint('[EmployeeService] Employee ID: $id');
        debugPrint('[EmployeeService] Error Type: ${e.runtimeType}');
        debugPrint('[EmployeeService] Error Message: ${e.toString()}');
        debugPrint('[EmployeeService] =================================');
      }

      rethrow;
    }
  }
}