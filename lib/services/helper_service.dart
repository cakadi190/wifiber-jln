class HelperService {
  static const String host = "wifiber.web.id";
  static const String scheme = "https";
  static const String apiPath = "/api/v1/";

  static Uri buildUri(String path) {
    return Uri(scheme: scheme, host: host, path: apiPath + path);
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
}
