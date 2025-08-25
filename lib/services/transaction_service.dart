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

  Future<void> createTransaction({
    required int amount,
    required String description,
    required String type,
  }) async {
    final response = await _http.postForm(
      '/transactions',
      fields: {
        'nominal': amount.toString(),
        'description': description,
        'type': type,
      },
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create transaction');
    }

    final body = json.decode(response.body);
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to create transaction');
    }
  }

  Future<void> updateTransaction(
    int id, {
    required int amount,
    required String description,
    required String type,
  }) async {
    final response = await _http.postForm(
      '/transactions/$id',
      fields: {
        'nominal': amount.toString(),
        'description': description,
        'type': type,
      },
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update transaction');
    }

    final body = json.decode(response.body);
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to update transaction');
    }
  }

  Future<void> deleteTransaction(int id) async {
    final response = await _http.delete('/transactions/$id', requiresAuth: true);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction');
    }

    final body = json.decode(response.body);
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to delete transaction');
    }
  }
}
