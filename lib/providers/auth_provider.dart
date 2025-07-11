import 'package:flutter/material.dart';
import 'package:wifiber/models/auth_user.dart';
import 'package:wifiber/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthUser? user;
  bool isLoading = true;

  AuthProvider() {
    _initUser();
  }

  Future<void> _initUser() async {
    try {
      user = await AuthService.loadUser();
    } catch (_) {
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
}
