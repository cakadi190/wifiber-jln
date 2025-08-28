import 'package:flutter/material.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/dashboard/home_dashboard_screen.dart';
import 'package:wifiber/screens/forgot_password_screen.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';

class LoginScreenController {
  final BuildContext context;

  LoginScreenController(this.context);

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool formLoading = false;

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama pengguna tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama pengguna minimal 3 karakter';
    }
    if (value.trim().length > 20) {
      return 'Nama pengguna maksimal 20 karakter';
    }
    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(value.trim())) {
      return 'Nama pengguna hanya boleh berisi huruf, angka, underscore, dan titik';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.trim().length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    if (value.trim().length > 50) {
      return 'Kata sandi maksimal 50 karakter';
    }
    return null;
  }

  Future<void> navigateToForgotPassword() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  Future<void> submitForm({
    required VoidCallback onLoading,
    required VoidCallback onComplete,
    required AuthProvider authProvider,
    void Function(Map<String, dynamic> errors)? onValidationError,
  }) async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    onLoading();

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    try {
      await authProvider.login(username, password);

      if (context.mounted) {
        SnackBars.success(
          context,
          "Selamat datang kembali, ${authProvider.user?.username ?? username}.",
        ).clearSnackBars();

        await Future.delayed(const Duration(seconds: 2));

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
          );
        }
      }
    } on ValidationException catch (e) {
      onValidationError?.call(e.errors);
      if (context.mounted) {
        SnackBars.error(
          context,
          e.message,
        ).clearSnackBars();
      }
    } catch (e) {
      final message = e.toString().contains("400")
          ? "Nama pengguna atau kata sandi salah."
          : e.toString();
      if (context.mounted) {
        SnackBars.error(
          context,
          message,
        ).clearSnackBars();
      }
    } finally {
      onComplete();
    }
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}
