import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/dashboard/home_dashboard_screen.dart';
import 'package:wifiber/screens/login_screen.dart';
import 'package:wifiber/screens/onboarding_screen.dart';
import 'package:wifiber/services/first_launch_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class SplashScreenController extends SafeChangeNotifier {
  final BuildContext context;
  String _splashText = "Memuat...";

  SplashScreenController(this.context);

  String get splashText => _splashText;

  void _updateSplashText(String newText) {
    _splashText = newText;
    notifyListeners();
  }

  Future<void> initializeApp() async {
    try {
      _updateSplashText("Menginisialisasi sistem...");
      final auth = Provider.of<AuthProvider>(context, listen: false);

      await Future.delayed(const Duration(milliseconds: 500));

      _updateSplashText("Memeriksa peluncuran dan autentikasi...");

      final results = await Future.wait([
        Future.delayed(const Duration(seconds: 1)),
        _checkFirstLaunch(),
      ]);

      final isFirstLaunch = results[1] as bool;

      _updateSplashText("Mengarahkan...");

      await Future.delayed(const Duration(milliseconds: 300));

      _navigateToRoute(_getTargetRoute(isFirstLaunch, auth.isLoggedIn));
    } catch (e) {
      _updateSplashText("Terjadi kesalahan...");
      await Future.delayed(const Duration(seconds: 1));
      _navigateToRoute(const LoginScreen());
    }
  }

  Future<bool> _checkFirstLaunch() async {
    _updateSplashText("Mempersiapkan sistem...");
    return await FirstLaunchService.isFirstLaunch();
  }

  Widget _getTargetRoute(bool isFirstLaunch, bool isLoggedIn) {
    if (isFirstLaunch && !isLoggedIn) {
      _updateSplashText("Selamat datang! Mengalihkan...");
      return const OnboardingScreen();
    }

    if (isLoggedIn) {
      _updateSplashText("Selamat datang kembali!");
      return const HomeDashboardScreen();
    } else {
      _updateSplashText("Silakan masuk...");
      return const LoginScreen();
    }
  }

  void _navigateToRoute(Widget screen) {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }
}