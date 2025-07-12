import 'dart:convert';

import 'package:wifiber/models/transaction.dart';
import 'package:wifiber/services/http_service.dart';

class TransactionService {
  static final HttpService _http = HttpService();

  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String endpoint = '/transactions';

    if (startDate != null && endDate != null) {
      final startDateStr = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final endDateStr = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
      endpoint += "?start_date=$startDateStr&end_date=$endDateStr";
    }

    final response = await _http.get(endpoint, requiresAuth: true);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['data'];

      return data.map((item) => Transaction.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch transactions: ${response.statusCode}');
    }
  }

  Future<Transaction> getTransactionById(int id) async {
    final response = await _http.get('/transactions/$id', requiresAuth: true);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Transaction.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to fetch transaction');
    }
  }
}
