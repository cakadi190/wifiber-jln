import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:wifiber/exceptions/user_exceptions.dart';

class AuthUser {
  final int userId;
  final String username;
  final String email;
  final String name;
  final List<String> permissions;
  String accessToken;

  AuthUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.name,
    required this.permissions,
    required this.accessToken,
  });

  factory AuthUser.fromToken(String token) {
    if (JwtDecoder.isExpired(token)) {
      throw InvalidUserException();
    }

    final Map<String, dynamic> decoded = JwtDecoder.decode(token);

    return AuthUser(
      userId: int.tryParse(decoded['sub'].toString()) ?? 0,
      username: decoded['username'] ?? '',
      email: decoded['email'] ?? '',
      name: decoded['name'] ?? '',
      permissions: List<String>.from(decoded['permissions'] ?? []),
      accessToken: token,
    );
  }

  String get nameInitials {
    final names = name.split(' ');
    final initials = names.map((name) => name[0]).join().toUpperCase();
    return initials;
  }

  String toJson() {
    return jsonEncode({
      "userId": userId,
      "username": username,
      "email": email,
      "name": name,
      "permissions": permissions,
      "access": accessToken,
    });
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      permissions: List<String>.from(json['permissions']),
      accessToken: json['access'],
    );
  }

  bool get isTokenExpired => JwtDecoder.isExpired(accessToken);
  DateTime get tokenExpiryDate => JwtDecoder.getExpirationDate(accessToken);
}
