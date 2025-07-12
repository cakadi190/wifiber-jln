import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:wifiber/exceptions/auth_exceptions.dart';
import 'package:wifiber/exceptions/secure_storage_exceptions.dart';
import 'package:wifiber/exceptions/user_exceptions.dart';
import 'package:wifiber/models/auth_user.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/services/secure_storage_service.dart';

class AuthService {
  static const String loginPath = '/login';
  static const String profilePath = '/profiles';
  static final HttpService _http = HttpService();

  static Future<AuthUser> loadUser() async {
    final json = await SecureStorageService.storage.read(
      key: SecureStorageService.userKey,
    );

    if (json != null) {
      try {
        final userData = jsonDecode(json);
        final user = AuthUser.fromJson(userData);

        if (user.isTokenExpired) {
          await logout();
          throw TokenExpiredException('Token has expired');
        }

        final timeUntilExpiry = user.tokenExpiryDate.difference(DateTime.now());
        if (timeUntilExpiry.inMinutes <= 10 && timeUntilExpiry.inMinutes > 0) {
          debugPrint(
            'Token will expire in ${timeUntilExpiry.inMinutes} minutes',
          );
        }

        return user;
      } catch (e) {
        await logout();
        if (e is TokenExpiredException) {
          rethrow;
        }
        throw InvalidUserException();
      }
    } else {
      throw SecureStorageNotFoundException();
    }
  }

  static Future<void> saveUser(AuthUser user) async {
    await SecureStorageService.storage.write(
      key: SecureStorageService.userKey,
      value: user.toJson(),
    );
  }

  static Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _http.post(
        loginPath,
        body: jsonEncode({'username': username, 'password': password}),
      );

      final json = jsonDecode(response.body);

      final token = json['data']['token'];
      final user = AuthUser.fromToken(token);

      final userWithProfile = await _getProfile(user.userId, user);

      if (userWithProfile != null) {
        await saveUser(userWithProfile);
        return userWithProfile;
      } else {
        await saveUser(user);
        return user;
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    await SecureStorageService.storage.delete(
      key: SecureStorageService.userKey,
    );
  }

  static Future<AuthUser?> _getProfile(int userId, AuthUser? userCache) async {
    try {
      final response = await _http.get(
        '$profilePath/$userId',
        headers: {'Authorization': 'Bearer ${userCache?.accessToken}'},
      );

      if (response.statusCode == 200) {
        final dataParse =
            jsonDecode(response.body)['data'] as Map<String, dynamic>;

        if (userCache != null) {
          final userData = <String, dynamic>{
            ...userCache.toMap(),
            ...Map<String, dynamic>.from(dataParse),
          };

          return AuthUser.fromJson(userData);
        } else {
          return AuthUser.fromJson(dataParse);
        }
      } else {
        return null;
      }
    } catch (e) {
      // debugPrint('Error fetching profile: $e');
      return null;
    }
  }
}
