import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/models/broadcast_customer.dart';
import 'package:wifiber/services/http_service.dart';

class BroadcastService {
  static final HttpService _http = HttpService();
  static const String _basePath = 'broadcast';

  Future<List<BroadcastCustomer>> getFilteredCustomers({
    List<int>? selectedAreaIds,
    String customerStatus = 'all',
  }) async {
    final response = await _http.get(
      '$_basePath/customers',
      requiresAuth: true,
      parameters: {
        if (selectedAreaIds != null && selectedAreaIds.isNotEmpty)
          'selected_area_id': selectedAreaIds.join(','),
        if (customerStatus.isNotEmpty) 'customer_status': customerStatus,
      },
    );

    final data = _decodeBody(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List<dynamic> rawList = data['data'] ?? [];
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(BroadcastCustomer.fromJson)
          .toList();
    }

    throw Exception(data['message'] ?? 'Gagal memuat data pelanggan');
  }

  Future<void> sendUnpaidReminder({List<int>? customerIds}) async {
    final body = jsonEncode({
      'customers': (customerIds == null || customerIds.isEmpty)
          ? null
          : customerIds,
    });

    final response = await _http.post(
      '$_basePath/unpaid-reminder',
      requiresAuth: true,
      body: body,
    );

    _handleMutationResponse(
      response: response,
      defaultErrorMessage: 'Gagal mengirim pengingat tagihan.',
    );
  }

  Future<void> sendManualMessage({
    required String message,
    List<int>? customerIds,
  }) async {
    final payload = <String, dynamic>{'message': message};

    if (customerIds != null && customerIds.isNotEmpty) {
      payload['customers'] = customerIds;
    } else {
      payload['customers'] = null;
    }

    final response = await _http.post(
      '$_basePath/manual-message',
      requiresAuth: true,
      body: jsonEncode(payload),
    );

    _handleMutationResponse(
      response: response,
      defaultErrorMessage: 'Gagal mengirim pesan broadcast.',
    );
  }

  void _handleMutationResponse({
    required http.Response response,
    required String defaultErrorMessage,
  }) {
    if (response.statusCode == 204) {
      return;
    }

    final data = _decodeBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data.isEmpty || data['success'] == null || data['success'] == true) {
        return;
      }
      throw Exception(data['message'] ?? defaultErrorMessage);
    }

    if (response.statusCode == 422) {
      final errors = data['error']?['message'] ?? data['errors'] ?? {};
      throw ValidationException(
        message: data['message'] ?? defaultErrorMessage,
        errors: errors is Map<String, dynamic>
            ? errors
            : (errors is Map ? Map<String, dynamic>.from(errors) : {}),
      );
    }

    if (response.statusCode == 401) {
      throw Exception('Sesi telah berakhir. Silakan login kembali.');
    }

    if (response.statusCode == 403) {
      throw Exception('Anda tidak memiliki hak akses untuk aksi ini.');
    }

    throw Exception(data['message'] ?? defaultErrorMessage);
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is List) {
        return {'data': decoded};
      }

      return {'data': decoded};
    } catch (_) {
      return {};
    }
  }
}
