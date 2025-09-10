import 'dart:convert';

import 'package:wifiber/models/area.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';

class AreaService {
  static final HttpService _http = HttpService();
  static const String path = 'areas';

  Future<List<AreaModel>> getAreas({String? search}) async {
    final response = await _http.get(
      path,
      requiresAuth: true,
      parameters: search != null ? {'search': search} : null,
    );

    final data = json.decode(response.body);
    if (data['success'] == true) {
      final List<dynamic> list = data['data'] ?? [];
      return list.map((e) => AreaModel.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load areas');
  }

  Future<AreaModel> getAreaById(String id) async {
    final response = await _http.get('$path/$id', requiresAuth: true);
    final data = json.decode(response.body);
    if (data['success'] == true) {
      return AreaModel.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to load area');
  }

  Future<void> createArea(Map<String, String> fields) async {
    final response = await _http.postForm(path, fields: fields, requiresAuth: true);
    if (response.statusCode == 201) return;
    if (response.statusCode == 422) {
      final data = json.decode(response.body);
      throw ValidationException(
        errors: data['error']['message'] ?? {},
        message: data['message'] ?? 'Validation error',
      );
    }
    throw Exception('Failed to create area');
  }

  Future<void> updateArea(String id, Map<String, String> fields) async {
    final response = await _http.postForm('$path/$id', fields: fields, requiresAuth: true);
    if (response.statusCode == 200) return;
    if (response.statusCode == 422) {
      final data = json.decode(response.body);
      throw ValidationException(
        errors: data['error']['message'] ?? {},
        message: data['message'] ?? 'Validation error',
      );
    }
    throw Exception('Failed to update area');
  }

  Future<void> deleteArea(String id) async {
    final response = await _http.delete('$path/$id', requiresAuth: true);
    if (response.statusCode == 200) return;
    throw Exception('Failed to delete area');
  }
}
