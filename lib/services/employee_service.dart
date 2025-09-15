import 'dart:convert';

import 'package:wifiber/models/employee.dart';
import 'package:wifiber/services/http_service.dart';

class EmployeeService {
  static final HttpService _http = HttpService();
  static const String path = 'employees';

  Future<EmployeeResponse> getEmployees({String? search}) async {
    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      final response = await _http.get(
        path,
        requiresAuth: true,
        parameters: params.isNotEmpty ? params : null,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return EmployeeResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching employees: $e');
    }
  }

  Future<bool> createEmployee(Map<String, dynamic> data) async {
    try {
      final response = await _http.post(
        path,
        body: json.encode(data),
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      } else {
        throw Exception('Failed to create employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating employee: $e');
    }
  }

  Future<Employee> updateEmployee(String id, Map<String, dynamic> data) async {
    try {
      final response = await _http.put(
        '$path/$id',
        body: json.encode(data),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return Employee.fromJson(jsonData['data']);
        } else {
          throw Exception(
            'Failed to update employee: ${jsonData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to update employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating employee: $e');
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      final response = await _http.delete(
        '$path/$id',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      } else {
        throw Exception('Failed to delete employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting employee: $e');
    }
  }
}
