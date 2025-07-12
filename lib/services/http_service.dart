import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wifiber/exceptions/secure_storage_exceptions.dart';
import 'package:wifiber/exceptions/string_exceptions.dart';
import 'package:wifiber/services/helper_service.dart';
import 'package:wifiber/services/secure_storage_service.dart';

class HttpService {
  final http.Client _client = http.Client();

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = false,
  }) async {
    final uri = HelperService.buildUri(path);
    final completeHeaders = await _buildHeaders(headers, requiresAuth);

    final response = await _client.post(
      uri,
      headers: completeHeaders,
      body: body,
    );

    _handleResponseErrors(response);
    return response;
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final uri = HelperService.buildUri(path);
    final completeHeaders = await _buildHeaders(headers, requiresAuth);

    final response = await _client.get(uri, headers: completeHeaders);
    _handleResponseErrors(response);
    return response;
  }

  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? headers,
    bool requiresAuth,
  ) async {
    final baseHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final json = await SecureStorageService.storage.read(
        key: SecureStorageService.userKey,
      );

      if (json == null) throw SecureStorageNotFoundException();

      final token = jsonDecode(json)['access'];
      baseHeaders['Authorization'] = 'Bearer $token';
    }

    if (headers != null) baseHeaders.addAll(headers);
    return baseHeaders;
  }

  void _handleResponseErrors(http.Response response) {
    if (response.statusCode == 401) {
      throw StringException('Sesi Anda telah habis. Silakan login kembali.');
    } else if (response.statusCode == 403) {
      throw StringException('Anda tidak memiliki izin.');
    } else if (response.statusCode >= 400) {
      throw StringException('Terjadi kesalahan: ${response.statusCode}');
    } else if (response.statusCode >= 500) {
      throw StringException('Terjadi kesalahan server.');
    }
  }
}
