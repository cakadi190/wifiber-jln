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

  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = false,
  }) async {
    final uri = HelperService.buildUri(path);
    final completeHeaders = await _buildHeaders(headers, requiresAuth);

    final response = await _client.put(
      uri,
      headers: completeHeaders,
      body: body,
    );

    _handleResponseErrors(response);
    return response;
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = false,
  }) async {
    final uri = HelperService.buildUri(path);
    final completeHeaders = await _buildHeaders(headers, requiresAuth);

    final response = await _client.delete(
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

  String? _buildErrorCodeMessage(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return 'ERR_400_BAD_REQUEST';
      case 401:
        return 'ERR_401_UNAUTHORIZED';
      case 402:
        return 'ERR_402_PAYMENT_REQUIRED';
      case 403:
        return 'ERR_403_FORBIDDEN';
      case 404:
        return 'ERR_404_NOT_FOUND';
      case 405:
        return 'ERR_405_METHOD_NOT_ALLOWED';
      case 406:
        return 'ERR_406_NOT_ACCEPTABLE';
      case 407:
        return 'ERR_407_PROXY_AUTHENTICATION_REQUIRED';
      case 408:
        return 'ERR_408_REQUEST_TIMEOUT';
      case 409:
        return 'ERR_409_CONFLICT';
      case 410:
        return 'ERR_410_GONE';
      case 411:
        return 'ERR_411_LENGTH_REQUIRED';
      case 412:
        return 'ERR_412_PRECONDITION_FAILED';
      case 413:
        return 'ERR_413_PAYLOAD_TOO_LARGE';
      case 414:
        return 'ERR_414_URI_TOO_LONG';
      case 415:
        return 'ERR_415_UNSUPPORTED_MEDIA_TYPE';
      case 416:
        return 'ERR_416_RANGE_NOT_SATISFIABLE';
      case 417:
        return 'ERR_417_EXPECTATION_FAILED';
      case 418:
        return 'ERR_418_IM_A_TEAPOT';
      case 419:
        return 'ERR_419_CSRF_MISMATCH';
      case 421:
        return 'ERR_421_MISDIRECTED_REQUEST';
      case 422:
        return 'ERR_422_UNPROCESSABLE_ENTITY';
      case 423:
        return 'ERR_423_LOCKED';
      case 424:
        return 'ERR_424_FAILED_DEPENDENCY';
      case 425:
        return 'ERR_425_TOO_EARLY';
      case 426:
        return 'ERR_426_UPGRADE_REQUIRED';
      case 428:
        return 'ERR_428_PRECONDITION_REQUIRED';
      case 429:
        return 'ERR_429_TOO_MANY_REQUESTS';
      case 431:
        return 'ERR_431_REQUEST_HEADER_FIELDS_TOO_LARGE';
      case 451:
        return 'ERR_451_UNAVAILABLE_FOR_LEGAL_REASONS';
      case 500:
        return 'ERR_500_INTERNAL_SERVER_ERROR';
      case 501:
        return 'ERR_501_NOT_IMPLEMENTED';
      case 502:
        return 'ERR_502_BAD_GATEWAY';
      case 503:
        return 'ERR_503_SERVICE_UNAVAILABLE';
      case 504:
        return 'ERR_504_GATEWAY_TIMEOUT';
      case 505:
        return 'ERR_505_HTTP_VERSION_NOT_SUPPORTED';
      case 506:
        return 'ERR_506_VARIANT_ALSO_NEGOTIATES';
      case 507:
        return 'ERR_507_INSUFFICIENT_STORAGE';
      case 508:
        return 'ERR_508_LOOP_DETECTED';
      case 510:
        return 'ERR_510_NOT_EXTENDED';
      case 511:
        return 'ERR_511_NETWORK_AUTHENTICATION_REQUIRED';
      default:
        if (response.statusCode >= 500) {
          return 'ERR_${response.statusCode}_SERVER_ERROR';
        } else if (response.statusCode >= 400) {
          return 'ERR_${response.statusCode}_CLIENT_ERROR';
        }
        return null;
    }
  }

  void _handleResponseErrors(http.Response response) {
    final errorCode = _buildErrorCodeMessage(response);

    if (response.statusCode == 401) {
      throw StringException(
        'Sesi Anda telah habis. Silakan login kembali. $errorCode',
      );
    } else if (response.statusCode == 403) {
      throw StringException('Anda tidak memiliki izin. $errorCode');
    } else if (response.statusCode == 404) {
      throw StringException('Halaman tidak ditemukan. $errorCode');
    } else if (response.statusCode == 400) {
      throw StringException(
        'Terjadi kesalahan: request Anda salah. $errorCode',
      );
    } else if (response.statusCode == 402) {
      throw StringException(
        'Terjadi kesalahan: request Anda tidak valid. $errorCode',
      );
    } else if (response.statusCode == 405) {
      throw StringException(
        'Terjadi kesalahan: metode request Anda tidak diperbolehkan. $errorCode',
      );
    } else if (response.statusCode >= 500) {
      throw StringException('Terjadi kesalahan server. $errorCode');
    } else if (response.statusCode >= 400) {
      throw StringException(
        'Terjadi kesalahan, coba lagi beberapa saat. $errorCode',
      );
    }
  }
}
