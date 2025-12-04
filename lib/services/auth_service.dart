import 'dart:async';
import 'dart:convert';

import 'package:wifiber/exceptions/auth_exceptions.dart';
import 'package:wifiber/exceptions/secure_storage_exceptions.dart';
import 'package:wifiber/exceptions/user_exceptions.dart';
import 'package:wifiber/models/auth_user.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/services/secure_storage_service.dart';

class AuthService {
  static const String loginPath = '/login';
  static const String profilePath = '/profiles';
  static const String refreshTokenPath = '/refresh-token';
  static final HttpService _http = HttpService();
  static AuthUser? _cachedUser;
  static Completer<bool>? _refreshCompleter;

  static Future<AuthUser> loadUser({bool force = false}) async {
    final json = await SecureStorageService.storage.read(
      key: SecureStorageService.userKey,
    );

    if (json != null) {
      try {
        final userData = jsonDecode(json);
        final user = AuthUser.fromJson(userData);
        _cachedUser = user;

        if (user.isTokenExpired) {
          try {
            final refreshedUser = await refreshSession(currentUser: user);
            if (refreshedUser != null) {
              return refreshedUser;
            }
          } on InvalidRefreshTokenException catch (e) {
            await logout();
            throw TokenExpiredException(e.message);
          }
        }

        if (force) {
          final updatedUser = await _getProfile(user.userId, user);
          if (updatedUser != null) {
            await saveUser(updatedUser);
            return updatedUser;
          }
        }

        _cachedUser = user;
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
    _cachedUser = user;
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

      final data = json['data'] as Map<String, dynamic>?;

      final accessToken = data?['access_token'] ?? data?['token'];
      final refreshToken = data?['refresh_token'];

      if (accessToken is! String || accessToken.isEmpty) {
        throw LoginException('Token tidak ditemukan pada respons login');
      }

      final user = AuthUser.fromToken(
        accessToken,
        refreshToken: refreshToken is String ? refreshToken : '',
      );

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
    _cachedUser = null;
  }

  static Future<AuthUser?> refreshSession({AuthUser? currentUser}) async {
    if (_refreshCompleter != null) {
      final success = await _refreshCompleter!.future;
      return success ? _cachedUser : null;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final storedJson = await SecureStorageService.storage.read(
        key: SecureStorageService.userKey,
      );

      if (storedJson == null) {
        completer.complete(false);
        return null;
      }

      final storedData = jsonDecode(storedJson);
      final user = currentUser ??
          _cachedUser ??
          AuthUser.fromJson(Map<String, dynamic>.from(storedData));

      if (!user.hasRefreshToken) {
        throw InvalidRefreshTokenException('Refresh token not found');
      }

      final response = await _http.post(
        refreshTokenPath,
        headers: {
          'Authorization': 'Bearer ${user.refreshToken}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw InvalidRefreshTokenException('Refresh token expired or invalid');
      } else if (response.statusCode != 200) {
        throw RefreshTokenException(
          'Failed to refresh token: ${response.statusCode}',
        );
      }

      final responseJson = jsonDecode(response.body);
      final responseData = responseJson['data'] as Map<String, dynamic>?;

      final newAccessToken =
          responseData?['access_token'] ?? responseData?['token'];
      final newRefreshToken = responseData?['refresh_token'];

      if (newAccessToken is! String || newAccessToken.isEmpty) {
        throw RefreshTokenException('Access token missing');
      }

      user.accessToken = newAccessToken;
      if (newRefreshToken is String && newRefreshToken.isNotEmpty) {
        user.refreshToken = newRefreshToken;
      }

      await saveUser(user);

      completer.complete(true);
      return user;
    } on InvalidRefreshTokenException catch (e) {
      await logout();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      throw InvalidRefreshTokenException(e.message);
    } on RefreshTokenException {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      return null;
    } catch (_) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      return null;
    } finally {
      _refreshCompleter = null;
    }
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
      return null;
    }
  }
}
