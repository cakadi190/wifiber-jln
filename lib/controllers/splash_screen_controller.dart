import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/dashboard/home_dashboard_screen.dart';
import 'package:wifiber/screens/login_screen.dart';
import 'package:wifiber/screens/onboarding_screen.dart';
import 'package:wifiber/services/first_launch_service.dart';

class SplashScreenController extends ChangeNotifier {
  final BuildContext context;
  String _splashText = "Loading...";

  SplashScreenController(this.context);

  String get splashText => _splashText;

  void _updateSplashText(String newText) {
    _splashText = newText;
    notifyListeners();
  }

  Future<void> initializeApp() async {
    try {
      _updateSplashText("Initializing...");

      final auth = Provider.of<AuthProvider>(context, listen: false);

      _updateSplashText("Checking authentication...");

      final results = await Future.wait([
        Future.delayed(const Duration(seconds: 1)),
        _checkFirstLaunch(),
      ]);

      final isFirstLaunch = results[1] as bool;

      _updateSplashText("Preparing app...");

      await Future.delayed(const Duration(milliseconds: 500));

      _navigateToRoute(_getTargetRoute(isFirstLaunch, auth.isLoggedIn));
    } catch (e) {
      _updateSplashText("Error occurred, redirecting...");
      await Future.delayed(const Duration(seconds: 1));
      _navigateToRoute(const LoginScreen());
    }
  }

  Future<bool> _checkFirstLaunch() async {
    _updateSplashText("Preparing the system...");
    return await FirstLaunchService.isFirstLaunch();
  }

  Widget _getTargetRoute(bool isFirstLaunch, bool isLoggedIn) {
    if (isFirstLaunch && !isLoggedIn) {
      _updateSplashText("Welcome! Redirecting...");
      return const OnboardingScreen();
    }

    if (isLoggedIn) {
      _updateSplashText("Welcome back!");
      return const HomeDashboardScreen();
    } else {
      _updateSplashText("Please sign in...");
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