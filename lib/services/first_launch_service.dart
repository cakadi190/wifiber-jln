import 'package:wifiber/services/secure_storage_service.dart';

/// A service class that manages the first launch status of the application.
///
/// This service provides functionality to check if the app has been launched
/// before and to update the first launch status. It uses secure storage to
/// persist the launch status across app sessions.
///
/// The service stores a boolean value as a string in secure storage, where:
/// - `null` or any value other than 'false' indicates first launch
/// - `'false'` indicates the app has been launched before
///
/// Example usage:
/// ```dart
/// // Check if this is the first launch
/// bool isFirst = await FirstLaunchService.isFirstLaunch();
///
/// if (isFirst) {
///   // Show onboarding or welcome screen
///   await showOnboarding();
///
///   // Mark that the app has been launched
///   await FirstLaunchService.setFirstLaunchStatus(false);
/// }
/// ```
class FirstLaunchService {
  /// The storage key used to store the first launch status
  static const String _key = SecureStorageService.firstLaunchKey;

  /// Private constructor to prevent instantiation
  FirstLaunchService._();

  /// Checks if this is the first time the application is being launched.
  ///
  /// Returns `true` if the app has never been launched before or if the
  /// stored value is not 'false'. Returns `false` if the app has been
  /// launched before and the status has been explicitly set.
  ///
  /// Returns:
  ///   A [Future<bool>] that resolves to `true` for first launch,
  ///   `false` for subsequent launches.
  ///
  /// Throws:
  ///   May throw storage-related exceptions if secure storage access fails.
  ///
  /// Example:
  /// ```dart
  /// final isFirst = await FirstLaunchService.isFirstLaunch();
  /// if (isFirst) {
  ///   print('Welcome to the app!');
  /// }
  /// ```
  static Future<bool> isFirstLaunch() async {
    try {
      final value = await SecureStorageService.storage.read(key: _key);
      return value != 'false';
    } catch (e) {
      return true;
    }
  }

  /// Sets the first launch status of the application.
  ///
  /// This method should be called after the first launch sequence is complete
  /// (e.g., after onboarding, tutorial, or initial setup).
  ///
  /// Parameters:
  ///   [isFirstLaunch]: `true` to mark as first launch, `false` to mark as
  ///                    launched before. Typically called with `false` after
  ///                    the first launch is complete.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the status is successfully stored.
  ///
  /// Throws:
  ///   May throw storage-related exceptions if secure storage write fails.
  ///
  /// Example:
  /// ```dart
  /// // After completing onboarding
  /// await FirstLaunchService.setFirstLaunchStatus(false);
  /// ```
  static Future<void> setFirstLaunchStatus(bool isFirstLaunch) async {
    await SecureStorageService.storage.write(
      key: _key,
      value: isFirstLaunch.toString(),
    );
  }

  /// Resets the first launch status to indicate a first launch.
  ///
  /// This method is useful for testing purposes or when you want to
  /// trigger the first launch experience again.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the status is reset.
  ///
  /// Throws:
  ///   May throw storage-related exceptions if secure storage operations fail.
  ///
  /// Example:
  /// ```dart
  /// // Reset for testing
  /// await FirstLaunchService.reset();
  /// ```
  static Future<void> reset() async {
    await SecureStorageService.storage.delete(key: _key);
  }

  /// Checks if the first launch status has been explicitly set.
  ///
  /// This method helps distinguish between a true first launch and
  /// cases where the storage might have been cleared or corrupted.
  ///
  /// Returns:
  ///   A [Future<bool>] that resolves to `true` if the status has been
  ///   explicitly set (either true or false), `false` if no status exists.
  ///
  /// Example:
  /// ```dart
  /// final hasStatus = await FirstLaunchService.hasFirstLaunchStatus();
  /// if (!hasStatus) {
  ///   // Handle case where storage might have been cleared
  /// }
  /// ```
  static Future<bool> hasFirstLaunchStatus() async {
    try {
      final value = await SecureStorageService.storage.read(key: _key);
      return value != null;
    } catch (e) {
      return false;
    }
  }
}
