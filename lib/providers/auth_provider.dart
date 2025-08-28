import 'package:wifiber/models/auth_user.dart';
import 'package:wifiber/services/auth_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class AuthProvider extends SafeChangeNotifier {
  AuthUser? user;
  bool isLoading = true;

  AuthProvider() {
    _initUser();
  }

  Future<void> _initUser({bool force = false}) async {
    try {
      user = await AuthService.loadUser(force: force);
    } catch (_) {
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reinitialize({bool force = false}) async {
    isLoading = true;
    notifyListeners();
    await _initUser(force: force);
  }

  Future<void> login(String username, String password) async {
    user = await AuthService.login(username: username, password: password);
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    user = null;
    notifyListeners();
  }

  bool get isLoggedIn => user != null;

  /// Checks if the current user has the given permission.
  bool hasPermission(String permission) {
    return user?.permissions.contains(permission) ?? false;
  }

  /// Checks if the user has at least one of the provided permissions.
  bool hasAnyPermission(List<String> permissions) {
    if (user == null) return false;
    return permissions.any((p) => user!.permissions.contains(p));
  }

  /// Checks if the user has all of the provided permissions.
  bool hasAllPermissions(List<String> permissions) {
    if (user == null) return false;
    return permissions.every((p) => user!.permissions.contains(p));
  }
}
