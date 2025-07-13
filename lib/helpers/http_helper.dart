class HttpHelper {
  static const String host = "wifiber.web.id";
  static const String scheme = "https";
  static const String apiPath = "/api/v1/";

  static Uri buildUri(String path, Map<String, dynamic>? parameters) {
    return Uri(
      scheme: scheme,
      host: host,
      path: apiPath + path,
      queryParameters: parameters,
    );
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

  String buildQueryParameters(String path, Map<String, dynamic> parameters) {
    final queryParams = parameters.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}',
        )
        .join('&');

    return '$path?$queryParams';
  }
}
