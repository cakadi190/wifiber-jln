import 'dart:convert';

import 'package:wifiber/exceptions/string_exceptions.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/models/bills.dart';
import 'package:wifiber/services/http_service.dart';

class BillsService {
  static const String _baseUrl = 'bills';
  static final HttpService _http = HttpService();

  Future<BillResponse> getBills({
    String? customerId,
    String? period,
    String? status,
    String? searchQuery,
  }) async {
    try {
      final parameters = <String, String>{};
      if (customerId != null) parameters['customer_id'] = customerId;
      if (period != null) parameters['period'] = period;
      if (status != null) parameters['status'] = status;
      if (status != null) parameters['customer_id'] = searchQuery ?? '';

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
      if (createBill.paymentProof != null) {
        final response = await _http.uploadFile(
          _baseUrl,
          'payment_proof',
          createBill.paymentProof!,
          requiresAuth: true,
          fields: createBill.toFormFields(),
        );

        final normalResponse = await _http.streamedResponseToResponse(response);

        if (normalResponse.statusCode == 200 ||
            normalResponse.statusCode == 201) {
          final Map<String, dynamic> data = json.decode(normalResponse.body);
          return BillResponse.fromJson(data);
        } else {
          throw Exception(
            'Failed to create bill: ${normalResponse.statusCode}',
          );
        }
      } else {
        final response = await _http.postForm(
          _baseUrl,
          requiresAuth: true,
          fields: createBill.toFormFields(),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = json.decode(response.body);
          return BillResponse.fromJson(data);
        } else {
          throw Exception('Failed to create bill: ${response.statusCode}');
        }
      }
    } on ValidationException catch (_)  {
      rethrow;
    } on StringException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Error creating bill: $e');
    }
  }
}
