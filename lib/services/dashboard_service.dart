import 'dart:convert';

import 'package:wifiber/models/dashboard.dart';
import 'package:wifiber/services/http_service.dart';

class DashboardService {
  final HttpService _http = HttpService();

  Future<DashboardData> getDashboardData() async {
    try {
      final response = await _http.get('/dashboard-data', requiresAuth: true);

      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return DashboardData.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load dashboard data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }
}
