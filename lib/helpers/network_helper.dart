import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class NetworkHelper {
  static Future<String?> getPublicIp() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      debugPrint('Error getting public IP: $e');
    }
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
    } catch (e) {
      debugPrint('Error getting local IP: $e');
    }
    return null;
  }
}
