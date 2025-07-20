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
  int? groupId;
  String? picture;
  DateTime? createdAt;
  String? groupName;

  AuthUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.name,
    required this.permissions,
    required this.accessToken,
    this.groupId,
    this.picture,
    this.createdAt,
    this.groupName,
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
      groupId: int.tryParse(decoded['groupId'].toString()) ?? 0,
      groupName: decoded['groupName'] ?? '',
      picture: decoded['picture'] ?? '',
      createdAt: DateTime.tryParse(decoded['createdAt'] ?? ''),
    );
  }

  String get nameInitials {
    final names = name.split(' ');
    final initials = names.map((name) => name[0]).join().toUpperCase();
    return initials;
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "username": username,
      "email": email,
      "name": name,
      "permissions": permissions,
      "access": accessToken,
      "groupId": groupId,
      "groupName": groupName,
      "picture": picture,
      "createdAt": createdAt?.toIso8601String(),
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] ?? json['user_id'] ?? json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
      accessToken: json['access'] ?? '',
      groupId: json['groupId'] ?? json['group_id'],
      groupName: json['GroupName'] ?? json['group_name'],
      picture: json['picture'],
      createdAt: DateTime.tryParse(
        json['createdAt'] ?? json['created_at'] ?? '',
      ),
    );
  }

  bool get isTokenExpired => JwtDecoder.isExpired(accessToken);

  DateTime get tokenExpiryDate => JwtDecoder.getExpirationDate(accessToken);
}
