import 'dart:convert';

import 'package:wifiber/models/package.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';

class PackageService {
  static final HttpService _http = HttpService();
  static const String path = 'packages';

  Future<List<PackageModel>> getPackages({String? search}) async {
    final response = await _http.get(
      path,
      requiresAuth: true,
      parameters: search != null ? {'search': search} : null,
    );
    final data = json.decode(response.body);
    if (data['success'] == true) {
      final List<dynamic> list = data['data'] ?? [];
      return list.map((e) => PackageModel.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load packages');
  }

  Future<PackageModel> getPackageById(String id) async {
    final response = await _http.get('$path/$id', requiresAuth: true);
    final data = json.decode(response.body);
    if (data['success'] == true) {
      return PackageModel.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to load package');
  }

  Future<void> createPackage(Map<String, String> fields) async {
    final response = await _http.postForm(path, fields: fields, requiresAuth: true);
    if (response.statusCode == 201) return;
    if (response.statusCode == 422) {
      final data = json.decode(response.body);
      throw ValidationException(
        errors: data['error']['message'] ?? {},
        message: data['message'] ?? 'Validation error',
      );
    }
    throw Exception('Failed to create package');
  }

  Future<void> updatePackage(String id, Map<String, String> fields) async {
    final response = await _http.postForm('$path/$id', fields: fields, requiresAuth: true);
    if (response.statusCode == 200) return;
    if (response.statusCode == 422) {
      final data = json.decode(response.body);
      throw ValidationException(
        errors: data['error']['message'] ?? {},
        message: data['message'] ?? 'Validation error',
      );
    }
    throw Exception('Failed to update package');
  }

  Future<void> deletePackage(String id) async {
    final response = await _http.delete('$path/$id', requiresAuth: true);
    if (response.statusCode == 200) return;
    throw Exception('Failed to delete package');
  }
}
