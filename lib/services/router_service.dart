import 'dart:convert';

import 'package:wifiber/models/router.dart';
import 'package:wifiber/services/http_service.dart';

class RouterService {
  static const String baseUrl = 'routers';
  static final HttpService _http = HttpService();

  Future<List<RouterModel>> getAllRouters() async {
    try {
      final response = await _http.get(baseUrl, requiresAuth: true);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> routersJson = data['data'] ?? data['routers'] ?? [];

        return routersJson.map((json) => RouterModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load routers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching routers: $e');
    }
  }

  Future<RouterModel> getRouterById(int id) async {
    try {
      final response = await _http.get('$baseUrl/$id', requiresAuth: true);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RouterModel.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to load router: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching router: $e');
    }
  }

  Future<RouterModel> addRouter(AddRouterModel router) async {
    try {
      final response = await _http.post(
        baseUrl,
        body: json.encode(router.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RouterModel.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to add router: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding router: $e');
    }
  }

  Future<RouterModel> updateRouter(int id, UpdateRouterModel router) async {
    try {
      final response = await _http.put(
        '$baseUrl/$id',
        body: json.encode(router.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RouterModel.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to update router: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating router: $e');
    }
  }

  Future<bool> deleteRouter(int id) async {
    try {
      final response = await _http.delete(
        '$baseUrl/$id',
        requiresAuth: true,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting router: $e');
    }
  }

  Future<bool> testRouterConnection(int id) async {
    try {
      final response = await _http.get(
        '$baseUrl/$id/test-connection',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Error testing router connection: $e');
    }
  }

  Future<RouterModel> toggleAutoIsolate(int id, ToggleRouterModel router) async {
    try {
      final response = await _http.post(
        '$baseUrl/$id',
        requiresAuth: true,
        body: json.encode(router.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RouterModel.fromJson(data['data'] ?? data);
      } else {
        throw Exception(
          'Failed to toggle auto isolate: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error toggling auto isolate: $e');
    }
  }
}
