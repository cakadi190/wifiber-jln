import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const storage = FlutterSecureStorage();

  static const String userKey = 'user';
  static const String firstLaunchKey = 'first_launch';
  static const String avatarKey = 'avatar';

  static const String avatarCachePrefix = 'avatar_cache_';
  static const String userAvatarPrefix = 'user_avatar_';

  static Future<void> cacheAvatarByUrl(String url, Uint8List imageData) async {
    final key = _getUrlCacheKey(url);
    final base64String = base64Encode(imageData);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await storage.write(key: key, value: base64String);
    await storage.write(key: '${key}_timestamp', value: timestamp.toString());
  }

  static Future<Uint8List?> getCachedAvatarByUrl(
    String url, {
    Duration? maxAge,
  }) async {
    final key = _getUrlCacheKey(url);
    final base64String = await storage.read(key: key);
    final timestampStr = await storage.read(key: '${key}_timestamp');

    if (base64String != null && timestampStr != null) {
      final timestamp = int.tryParse(timestampStr);
      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final cacheAge = Duration(milliseconds: now - timestamp);
        final maxCacheAge = maxAge ?? const Duration(days: 7);

        if (cacheAge < maxCacheAge) {
          return base64Decode(base64String);
        } else {
          await storage.delete(key: key);
          await storage.delete(key: '${key}_timestamp');
        }
      }
    }

    return null;
  }

  static Future<void> cacheUserAvatar(
    String userId,
    Uint8List imageData,
  ) async {
    final key = '${userAvatarPrefix}$userId';
    final base64String = base64Encode(imageData);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await storage.write(key: key, value: base64String);
    await storage.write(key: '${key}_timestamp', value: timestamp.toString());
  }

  static Future<Uint8List?> getUserAvatar(
    String userId, {
    Duration? maxAge,
  }) async {
    final key = '${userAvatarPrefix}$userId';
    final base64String = await storage.read(key: key);
    final timestampStr = await storage.read(key: '${key}_timestamp');

    if (base64String != null && timestampStr != null) {
      final timestamp = int.tryParse(timestampStr);
      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final cacheAge = Duration(milliseconds: now - timestamp);
        final maxCacheAge = maxAge ?? const Duration(days: 7);

        if (cacheAge < maxCacheAge) {
          return base64Decode(base64String);
        } else {
          await storage.delete(key: key);
          await storage.delete(key: '${key}_timestamp');
        }
      }
    }

    return null;
  }

  static Future<void> clearUserAvatar(String userId) async {
    final key = '${userAvatarPrefix}$userId';
    await storage.delete(key: key);
    await storage.delete(key: '${key}_timestamp');
  }

  static Future<void> clearAllAvatarCache() async {
    final allKeys = await storage.readAll();
    final avatarKeys = allKeys.keys.where(
      (key) =>
          key.startsWith(avatarCachePrefix) || key.startsWith(userAvatarPrefix),
    );

    for (final key in avatarKeys) {
      await storage.delete(key: key);
      await storage.delete(key: '${key}_timestamp');
    }
  }

  static Future<void> clearExpiredAvatarCache() async {
    final allKeys = await storage.readAll();
    final now = DateTime.now().millisecondsSinceEpoch;
    const defaultCacheDuration = Duration(days: 7);

    final avatarKeys = allKeys.keys.where(
      (key) =>
          key.startsWith(avatarCachePrefix) || key.startsWith(userAvatarPrefix),
    );

    for (final key in avatarKeys) {
      final timestampStr = await storage.read(key: '${key}_timestamp');
      if (timestampStr != null) {
        final timestamp = int.tryParse(timestampStr);
        if (timestamp != null) {
          final cacheAge = Duration(milliseconds: now - timestamp);
          if (cacheAge > defaultCacheDuration) {
            await storage.delete(key: key);
            await storage.delete(key: '${key}_timestamp');
          }
        }
      }
    }
  }

  static Future<double> getAvatarCacheSize() async {
    final allKeys = await storage.readAll();
    double totalSize = 0;

    final avatarKeys = allKeys.keys.where(
      (key) =>
          key.startsWith(avatarCachePrefix) || key.startsWith(userAvatarPrefix),
    );

    for (final key in avatarKeys) {
      final value = await storage.read(key: key);
      if (value != null) {
        totalSize += value.length;
      }
    }

    return totalSize / 1024 / 1024;
  }

  static Future<void> saveUser(String userData) async {
    await storage.write(key: userKey, value: userData);
  }

  static Future<String?> getUser() async {
    return await storage.read(key: userKey);
  }

  static Future<void> clearUser() async {
    await storage.delete(key: userKey);
  }

  static Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await storage.write(key: firstLaunchKey, value: isFirstLaunch.toString());
  }

  static Future<bool> isFirstLaunch() async {
    final value = await storage.read(key: firstLaunchKey);
    return value == null || value == 'true';
  }

  static Future<void> saveUserAvatarUrl(String avatarUrl) async {
    await storage.write(key: avatarKey, value: avatarUrl);
  }

  static Future<String?> getUserAvatarUrl() async {
    return await storage.read(key: avatarKey);
  }

  static Future<void> clearAllUserData() async {
    await storage.delete(key: userKey);
    await storage.delete(key: avatarKey);
  }

  static Future<void> clearAll() async {
    await storage.deleteAll();
  }

  static String _getUrlCacheKey(String url) {
    return '${avatarCachePrefix}${md5.convert(utf8.encode(url)).toString()}';
  }
}
