import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:wifiber/exceptions/secure_storage_exceptions.dart';
import 'package:wifiber/exceptions/string_exceptions.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/helpers/http_helper.dart';
import 'package:wifiber/services/secure_storage_service.dart';

class HttpService {
  final http.Client _client = http.Client();

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
    final completeHeaders = await _buildHeaders(headers, requiresAuth);

    final response = await _client.post(
      uri,
      headers: completeHeaders,
      body: body,
    );

    _handleResponseErrors(response);
    return response;
  }

  Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
    final completeHeaders = await _buildHeaders(headers, requiresAuth);

    final response = await _client.patch(
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
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
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
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
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
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final uri = HttpHelper.buildUri(path, parameters);
      final completeHeaders = await _buildHeaders(headers, requiresAuth);

      final response = await _client.get(uri, headers: completeHeaders);

      _handleResponseErrors(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> postForm(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
    final completeHeaders = await _buildFormHeaders(headers, requiresAuth);

    final response = await _client.post(
      uri,
      headers: completeHeaders,
      body: fields != null ? _encodeFormData(fields) : null,
    );

    _handleResponseErrors(response);
    return response;
  }

  Future<http.Response> patchForm(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
    final completeHeaders = await _buildFormHeaders(headers, requiresAuth);

    final response = await _client.patch(
      uri,
      headers: completeHeaders,
      body: fields != null ? _encodeFormData(fields) : null,
    );

    _handleResponseErrors(response);
    return response;
  }

  Future<http.Response> putForm(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
    final completeHeaders = await _buildFormHeaders(headers, requiresAuth);

    final response = await _client.put(
      uri,
      headers: completeHeaders,
      body: fields != null ? _encodeFormData(fields) : null,
    );

    _handleResponseErrors(response);
    return response;
  }

  Future<http.Response> deleteForm(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
    final completeHeaders = await _buildFormHeaders(headers, requiresAuth);

    final response = await _client.delete(
      uri,
      headers: completeHeaders,
      body: fields != null ? _encodeFormData(fields) : null,
    );

    _handleResponseErrors(response);
    return response;
  }

  Future<http.StreamedResponse> postUpload(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
    final request = http.MultipartRequest('POST', uri);

    final completeHeaders = await _buildMultipartHeaders(headers, requiresAuth);
    request.headers.addAll(completeHeaders);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (files != null) {
      request.files.addAll(files);
    }

    final streamedResponse = await _client.send(request);
    _handleStreamedResponseErrors(streamedResponse);
    return streamedResponse;
  }

  Future<http.StreamedResponse> putUpload(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
    final request = http.MultipartRequest('PUT', uri);

    final completeHeaders = await _buildMultipartHeaders(headers, requiresAuth);
    request.headers.addAll(completeHeaders);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (files != null) {
      request.files.addAll(files);
    }

    final streamedResponse = await _client.send(request);
    _handleStreamedResponseErrors(streamedResponse);
    return streamedResponse;
  }

  Future<http.StreamedResponse> patchUpload(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
  }) async {
    final uri = HttpHelper.buildUri(path, parameters);
    final request = http.MultipartRequest('PATCH', uri);

    final completeHeaders = await _buildMultipartHeaders(headers, requiresAuth);
    request.headers.addAll(completeHeaders);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (files != null) {
      request.files.addAll(files);
    }

    final streamedResponse = await _client.send(request);
    _handleStreamedResponseErrors(streamedResponse);
    return streamedResponse;
  }

  Future<http.MultipartFile> createMultipartFile(
    String fieldName,
    File file, {
    String? filename,
    String? contentType,
  }) async {
    if (!await file.exists()) {
      throw FileSystemException('File tidak ditemukan', file.path);
    }

    return http.MultipartFile.fromPath(
      fieldName,
      file.path,
      filename: filename ?? file.path.split('/').last,
    );
  }

  http.MultipartFile createMultipartFileFromStream(
    String fieldName,
    File file, {
    String? filename,
    String? contentType,
    int? length,
  }) {
    return http.MultipartFile(
      fieldName,
      file.openRead(),
      length ?? file.lengthSync(),
      filename: filename ?? file.path.split('/').last,
      contentType: contentType != null ? MediaType.parse(contentType) : null,
    );
  }

  http.MultipartFile createMultipartFileFromBytes(
    String fieldName,
    List<int> bytes, {
    required String filename,
    String? contentType,
  }) {
    return http.MultipartFile.fromBytes(fieldName, bytes, filename: filename);
  }

  Future<http.StreamedResponse> uploadFile(
    String path,
    String fieldName,
    File file, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
    String? filename,
  }) async {
    final multipartFile = await createMultipartFile(
      fieldName,
      file,
      filename: filename,
    );

    return postUpload(
      path,
      headers: headers,
      fields: fields,
      files: [multipartFile],
      requiresAuth: requiresAuth,
      parameters: parameters,
    );
  }

  Future<http.StreamedResponse> uploadFiles(
    String path,
    Map<String, File> files, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    bool requiresAuth = false,
    Map<String, dynamic>? parameters,
  }) async {
    final multipartFiles = <http.MultipartFile>[];

    for (final entry in files.entries) {
      final multipartFile = await createMultipartFile(entry.key, entry.value);
      multipartFiles.add(multipartFile);
    }

    return postUpload(
      path,
      headers: headers,
      fields: fields,
      files: multipartFiles,
      requiresAuth: requiresAuth,
      parameters: parameters,
    );
  }

  Future<http.Response> streamedResponseToResponse(
    http.StreamedResponse streamedResponse,
  ) async {
    final bytes = await streamedResponse.stream.toBytes();
    return http.Response.bytes(
      bytes,
      streamedResponse.statusCode,
      headers: streamedResponse.headers,
      reasonPhrase: streamedResponse.reasonPhrase,
    );
  }

  String _encodeFormData(Map<String, String> fields) {
    return fields.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }

  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? headers,
    bool requiresAuth,
  ) async {
    try {
      final baseHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (requiresAuth) {
        final json = await SecureStorageService.storage.read(
          key: SecureStorageService.userKey,
        );

        if (json == null) throw SecureStorageNotFoundException();

        final userdata = jsonDecode(json);
        if (userdata is Map<String, dynamic> &&
            userdata.containsKey('access')) {
          final token = userdata['access'];
          if (token is String) {
            baseHeaders['Authorization'] = 'Bearer $token';
          } else {
            throw Exception('Invalid token format');
          }
        } else {
          throw Exception('Access token not found in user data');
        }
      }

      if (headers != null) baseHeaders.addAll(headers);
      return baseHeaders;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> _buildFormHeaders(
    Map<String, String>? headers,
    bool requiresAuth,
  ) async {
    try {
      final baseHeaders = <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };

      if (requiresAuth) {
        final json = await SecureStorageService.storage.read(
          key: SecureStorageService.userKey,
        );

        if (json == null) throw SecureStorageNotFoundException();

        final userdata = jsonDecode(json);
        if (userdata is Map<String, dynamic> &&
            userdata.containsKey('access')) {
          final token = userdata['access'];
          if (token is String) {
            baseHeaders['Authorization'] = 'Bearer $token';
          } else {
            throw Exception('Invalid token format');
          }
        } else {
          throw Exception('Access token not found in user data');
        }
      }

      if (headers != null) baseHeaders.addAll(headers);
      return baseHeaders;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> _buildMultipartHeaders(
    Map<String, String>? headers,
    bool requiresAuth,
  ) async {
    try {
      final baseHeaders = <String, String>{'Accept': 'application/json'};

      if (requiresAuth) {
        final json = await SecureStorageService.storage.read(
          key: SecureStorageService.userKey,
        );

        if (json == null) throw SecureStorageNotFoundException();

        final userdata = jsonDecode(json);
        if (userdata is Map<String, dynamic> &&
            userdata.containsKey('access')) {
          final token = userdata['access'];
          if (token is String) {
            baseHeaders['Authorization'] = 'Bearer $token';
          } else {
            throw Exception('Invalid token format');
          }
        } else {
          throw Exception('Access token not found in user data');
        }
      }

      if (headers != null) baseHeaders.addAll(headers);
      return baseHeaders;
    } catch (e) {
      rethrow;
    }
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
    } else if (response.statusCode == 422) {
      try {
        final json = jsonDecode(response.body);

        Map<String, dynamic>? validationErrors;
        String mainMessage = 'Validasi gagal.';

        if (json['error']?['message'] != null &&
            json['error']['message'] is Map<String, dynamic>) {
          validationErrors = json['error']['message'];
          mainMessage = json['message'] ?? mainMessage;
        } else if (json['errors'] != null &&
            json['errors'] is Map<String, dynamic>) {
          validationErrors = json['errors'];
          mainMessage = json['message'] ?? mainMessage;
        } else if (json is Map<String, dynamic>) {
          validationErrors = Map<String, dynamic>.from(json);
          validationErrors.removeWhere(
            (key, value) =>
                key == 'message' || key == 'error' || key == 'status',
          );

          if (validationErrors.isEmpty == true) {
            validationErrors = null;
          }
          mainMessage = json['message'] ?? mainMessage;
        }

        if (validationErrors != null && validationErrors.isNotEmpty) {
          throw ValidationException(
            errors: validationErrors,
            message: mainMessage,
          );
        } else {
          throw StringException('$mainMessage $errorCode');
        }
      } catch (e) {
        if (e is ValidationException) rethrow;
        throw StringException('Validasi gagal. $errorCode');
      }
    } else if (response.statusCode >= 500) {
      throw StringException('Terjadi kesalahan server. $errorCode');
    } else if (response.statusCode >= 400) {
      throw StringException(
        'Terjadi kesalahan, coba lagi beberapa saat. $errorCode',
      );
    }
  }

  void _handleStreamedResponseErrors(http.StreamedResponse response) {
    final errorCode = _buildErrorCodeMessageFromStatusCode(response.statusCode);

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

  String? _buildErrorCodeMessageFromStatusCode(int statusCode) {
    switch (statusCode) {
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
        if (statusCode >= 500) {
          return 'ERR_${statusCode}_SERVER_ERROR';
        } else if (statusCode >= 400) {
          return 'ERR_${statusCode}_CLIENT_ERROR';
        }
        return null;
    }
  }
}
