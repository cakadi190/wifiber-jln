import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wifiber/models/bills.dart';
import 'package:wifiber/services/http_service.dart';

class BillsService {
  static const String _baseUrl = '/bills';
  static final HttpService _http = HttpService();

  Future<BillResponse> getBills({
    String? customerId,
    String? period,
    String? status,
  }) async {
    try {
      final parameters = <String, String>{};
      if (customerId != null) parameters['customer_id'] = customerId;
      if (period != null) parameters['period'] = period;
      if (status != null) parameters['status'] = status;

      final response = await _http.get(
        _baseUrl,
        requiresAuth: true,
        parameters: parameters,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return BillResponse.fromJson(data);
      } else {
        throw Exception('Failed to load bills: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bills: $e');
    }
  }

  Future<BillResponse> createBill(CreateBill createBill) async {
    try {
      final response = await _http.postForm(
        _baseUrl,
        requiresAuth: true,
        fields: createBill.toJson().cast<String, String>(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return BillResponse.fromJson(data);
      } else {
        throw Exception('Failed to create bill: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating bill: $e');
    }
  }

  Future<BillResponse> getBillsByCustomerId(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bills?customer_id=$customerId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return BillResponse.fromJson(data);
      } else {
        throw Exception(
          'Failed to load bills for customer: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching bills by customer ID: $e');
    }
  }
}
