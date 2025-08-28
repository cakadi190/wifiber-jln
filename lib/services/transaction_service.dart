import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wifiber/exceptions/validation_exceptions.dart';
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
      final startDateStr =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final endDateStr =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
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
    required int nominal,
    required String description,
    required String type,
    required DateTime createdAt,
    required String createdBy,
    File? image,
  }) async {
    final fields = {
      'nominal': nominal.toString(),
      'description': description,
      'type': type,
      'created_at':
          '${createdAt.year.toString().padLeft(4, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')}',
      'created_by': createdBy,
    };

    try {
      http.Response response;
      if (image != null) {
        final multipartFile = await _http.createMultipartFile('image', image);
        final streamed = await _http.postUpload(
          '/transactions',
          fields: fields,
          files: [multipartFile],
          requiresAuth: true,
        );
        response = await _http.streamedResponseToResponse(streamed);
      } else {
        response = await _http.postForm(
          '/transactions',
          fields: fields,
          requiresAuth: true,
        );
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        final body = json.decode(response.body);
        final errors = body['errors'];
        // final message = body['message'];

        if (errors != null) {
          errors.forEach((error) {});
        } else {}

        throw Exception('Failed to create transaction');
      }

      final body = json.decode(response.body);
      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Failed to create transaction');
      }
    } on ValidationException {
      // Re-throw ValidationException tanpa mengubahnya
      rethrow;
    } catch (e) {
      // Handle error lainnya

      rethrow;
    }
  }

  Future<void> updateTransaction(
    int id, {
    required int nominal,
    required String description,
    required String type,
    required DateTime createdAt,
    required String createdBy,
    File? image,
  }) async {
    final fields = {
      'nominal': nominal.toString(),
      'description': description,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };

    try {
      http.Response response;
      if (image != null) {
        final multipartFile = await _http.createMultipartFile('image', image);
        final streamed = await _http.patchUpload(
          '/transactions/$id',
          fields: fields,
          files: [multipartFile],
          requiresAuth: true,
        );
        response = await _http.streamedResponseToResponse(streamed);
      } else {
        response = await _http.patchForm(
          '/transactions/$id',
          fields: fields,
          requiresAuth: true,
        );
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to update transaction: ${response.statusCode}');
      }

      final body = json.decode(response.body);
      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Failed to update transaction');
      }
    } on ValidationException {
      // Re-throw ValidationException tanpa mengubahnya
      rethrow;
    } catch (e) {
      // Handle error lainnya

      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    final response = await _http.delete(
      '/transactions/$id',
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction');
    }

    final body = json.decode(response.body);
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to delete transaction');
    }
  }
}
