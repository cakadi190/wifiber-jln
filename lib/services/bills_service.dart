import 'dart:convert';

import 'package:wifiber/models/bills.dart';
import 'package:wifiber/services/http_service.dart';

class BillService {
  final HttpService _http = HttpService();
  final path = '/bills';

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

      final response = await _http.get(path, parameters: parameters);

      if (response.statusCode == 200) {
        return BillResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load bills');
      }
    } catch (e) {
      rethrow;
    }
  }
}
