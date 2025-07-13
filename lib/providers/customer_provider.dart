import 'dart:convert';

import 'package:wifiber/services/http_service.dart';

class CustomerProvider {
  static const String profilePath = '/customers';
  static final HttpService _http = HttpService();

  Future<Map<String, dynamic>> getCustomers(String? search, String? status) async {
    try {
      final response = await _http.get(profilePath, requiresAuth: true);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'];
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }
}