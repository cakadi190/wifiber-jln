import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/models/auth_user.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';

enum PasswordStrength { weak, medium, strong, veryStrong }

class PasswordMeter {
  final PasswordStrength strength;
  final double progress;
  final String message;
  final Color color;

  PasswordMeter({
    required this.strength,
    required this.progress,
    required this.message,
    required this.color,
  });
}

class ChangePasswordController extends SafeChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final String resetPasswordPath = '/reset-password';
  final HttpService _http = HttpService();

  bool _obscureCurrentPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  int passwordSecureIndex = 0;
  PasswordMeter? _passwordMeter;

  bool get obscureCurrentPassword => _obscureCurrentPassword;

  bool get obscurePassword => _obscurePassword;

  bool get obscureConfirmPassword => _obscureConfirmPassword;

  bool get isLoading => _isLoading;

  PasswordMeter? get passwordMeter => _passwordMeter;

  ChangePasswordController() {
    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  void _onPasswordChanged() {
    _passwordMeter = _calculatePasswordStrength(passwordController.text);
    notifyListeners();
  }

  void _onConfirmPasswordChanged() {
    notifyListeners();
  }

  PasswordMeter _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordMeter(
        strength: PasswordStrength.weak,
        progress: 0.0,
        message: '',
        color: Colors.grey,
      );
    }

    int score = 0;

    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;

    if (RegExp(r'[a-z]').hasMatch(password)) score += 1;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 1;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 1;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 1;

    if (password.length >= 16) score += 1;

    switch (score) {
      case 0:
      case 1:
      case 2:
        return PasswordMeter(
          strength: PasswordStrength.weak,
          progress: 0.25,
          message: 'Lemah',
          color: Colors.red,
        );
      case 3:
      case 4:
        return PasswordMeter(
          strength: PasswordStrength.medium,
          progress: 0.5,
          message: 'Sedang',
          color: Colors.orange,
        );
      case 5:
        return PasswordMeter(
          strength: PasswordStrength.strong,
          progress: 0.75,
          message: 'Kuat',
          color: Colors.blue,
        );
      case 6:
      case 7:
        return PasswordMeter(
          strength: PasswordStrength.veryStrong,
          progress: 1.0,
          message: 'Sangat Kuat',
          color: Colors.green,
        );
      default:
        return PasswordMeter(
          strength: PasswordStrength.weak,
          progress: 0.25,
          message: 'Lemah',
          color: Colors.red,
        );
    }
  }

  void toggleCurrentPasswordVisibility() {
    _obscureCurrentPassword = !_obscureCurrentPassword;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi sekarang tidak boleh kosong';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi baru tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    ).hasMatch(value)) {
      return 'Kata sandi harus mengandung huruf besar, huruf kecil, angka, dan simbol';
    }
    if (value == currentPasswordController.text) {
      return 'Kata sandi baru tidak boleh sama dengan kata sandi sekarang';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    ).hasMatch(value)) {
      return 'Kata sandi harus mengandung huruf besar, huruf kecil, angka, dan simbol';
    }
    if (value != passwordController.text) {
      return 'Konfirmasi kata sandi tidak cocok';
    }
    if (value == currentPasswordController.text) {
      return 'Kata sandi baru tidak boleh sama dengan kata sandi sekarang';
    }
    return null;
  }

  Future<bool> changePassword(
    BuildContext context,
    AuthUser? user, {
    void Function(Map<String, dynamic> errors)? onValidationError,
  }) async {
    if (user == null) {
      return false;
    }

    if (!formKey.currentState!.validate()) {
      return false;
    }

    setLoading(true);

    try {
      final response = await _http.post(
        resetPasswordPath,
        body: jsonEncode({
          'username': user.username,
          'existing_password': currentPasswordController.text,
          'new_password': passwordController.text,
        }),
        requiresAuth: true,
      );

      if (!context.mounted) return false;

      if (response.statusCode == 200) {
        _showSuccessMessage(context);
        _clearControllers();
        return true;
      } else {
        _showErrorMessage(context, 'Kata sandi sekarang tidak valid');
        return false;
      }
    } on ValidationException catch (e) {
      onValidationError?.call(e.errors);
      _showErrorMessage(context, e.message);
      return false;
    } catch (e) {
      if (!context.mounted) return false;

      if (e.toString().contains("401")) {
        _showErrorMessage(
          context,
          'Silahkan autentikasikan diri anda terlebih dahulu sebelum mengganti sandi!',
        );
      } else if (e.toString().contains("422")) {
        _showErrorMessage(
          context,
          'Ups, kata sandi akun anda saat ini tidak valid. Periksa kembali ya!',
        );
      } else {
        _showErrorMessage(
          context,
          'Terjadi kesalahan saat mengubah kata sandi',
        );
      }
      return false;
    } finally {
      setLoading(false);
    }
  }

  void _showSuccessMessage(BuildContext context) {
    SnackBars.success(context, "Kata sandi berhasil diubah!").clearSnackBars();
  }

  void _showErrorMessage(BuildContext context, String message) {
    SnackBars.error(context, message);
  }

  void _clearControllers() {
    currentPasswordController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _passwordMeter = null;
    notifyListeners();
  }

  @override
  void dispose() {
    passwordController.removeListener(_onPasswordChanged);
    confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    currentPasswordController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
