import 'package:flutter/material.dart';

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

class ChangePasswordController extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
  }

  void _onPasswordChanged() {
    _passwordMeter = _calculatePasswordStrength(passwordController.text);
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
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi tidak boleh kosong';
    }
    if (value != passwordController.text) {
      return 'Konfirmasi kata sandi tidak cocok';
    }
    return null;
  }

  Future<bool> changePassword(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final success = true;

      if (success) {
        _showSuccessMessage(context);
        _clearControllers();
        return true;
      } else {
        _showErrorMessage(context, 'Kata sandi sekarang tidak valid');
        return false;
      }
    } catch (e) {
      _showErrorMessage(context, 'Terjadi kesalahan saat mengubah kata sandi');
      return false;
    } finally {
      setLoading(false);
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kata sandi berhasil diubah!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
    currentPasswordController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
