import 'dart:convert';

class HttpHelper {
  static const String host = "wifiber.web.id";
  static const String scheme = "https";
  static const String apiPath = "api/v1/";

  static Uri buildUri(String path, Map<String, dynamic>? parameters) {
    try {
      Map<String, String>? queryParameters;

      if (parameters != null && parameters.isNotEmpty) {
        queryParameters = <String, String>{};

        parameters.forEach((key, value) {
          final stringKey = key.toString();

          if (value == null) {
            return;
          }

          String stringValue;

          if (value is String) {
            stringValue = value;
          } else if (value is num) {
            stringValue = value.toString();
          } else if (value is bool) {
            stringValue = value.toString();
          } else if (value is List) {
            stringValue = value.map((item) => item.toString()).join(',');
          } else if (value is Map) {
            try {
              stringValue = jsonEncode(value);
            } catch (e) {
              return;
            }
          } else {
            stringValue = value.toString();
          }

          if (stringValue.isNotEmpty) {
            queryParameters![stringKey] = stringValue;
          }
        });
      }

      final uri = Uri(
        scheme: scheme,
        host: host,
        path: apiPath + path,
        queryParameters: queryParameters?.isNotEmpty == true
            ? queryParameters
            : null,
      );

      return uri;
    } catch (e) {
      return Uri(scheme: scheme, host: host, path: apiPath + path);
    }
  }

  static Map<String, String> buildHeaders({String? accessToken}) {
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  static String buildQueryParameters(
    String path,
    Map<String, dynamic> parameters,
  ) {
    try {
      final queryParams = <String>[];

      parameters.forEach((key, value) {
        if (value != null) {
          final encodedKey = Uri.encodeComponent(key.toString());

          String stringValue;
          if (value is Map || value is List) {
            stringValue = jsonEncode(value);
          } else {
            stringValue = value.toString();
          }

          final encodedValue = Uri.encodeComponent(stringValue);
          queryParams.add('$encodedKey=$encodedValue');
        }
      });

      if (queryParams.isEmpty) {
        return path;
      }

      return '$path?${queryParams.join('&')}';
    } catch (e) {
      return path;
    }
  }
}
