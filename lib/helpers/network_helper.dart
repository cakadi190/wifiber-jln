import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkHelper {
  static Future<String?> getPublicIp() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (_) {}
    return null;
  }

  static Future<String?> getLocalIp() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 &&
              !address.isLoopback) {
            return address.address;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
