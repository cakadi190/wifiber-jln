import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/exceptions/string_exceptions.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/login_screen.dart';
import 'package:wifiber/services/http_service.dart';

class ForgotPasswordController {
  final BuildContext context;

  ForgotPasswordController(this.context);

  final HttpService _httpService = HttpService();
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool formLoading = false;

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kolom surel tidak boleh kosong';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format kolom surel tidak valid';
    }

    return null;
  }

  Future<void> submitForm({
    required VoidCallback onLoading,
    required VoidCallback onComplete,
    required AuthProvider authProvider,
  }) async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    onLoading();

    final email = emailController.text.trim();

    try {
      await _httpService.post(
        '/forgot-password',
        body: jsonEncode({'email': email}),
      );

      if (context.mounted) {
        SnackBars.success(
          context,
          "Permintaan reset kata sandi berhasil dikirim. Silahkan cek surel anda dan ikuti instruksi yang ada.",
        );

        await Future.delayed(const Duration(seconds: 3));

        if (context.mounted) {
          if (authProvider.isLoggedIn) {
            authProvider.logout();

            SnackBars.info(
              context,
              "Silahkan masuk terlebih dahulu untuk melanjutkan ke dalam sistem setelah reset kata sandi.",
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          } else {
            Navigator.of(context).pop();
          }
        }
      }
    } on StringException catch (e) {
      if (context.mounted) {
        String errorMessage = e.message;

        if (e.message.contains('ERR_404')) {
          errorMessage = "Surel tidak ditemukan.";
        } else if (e.message.contains('ERR_400')) {
          errorMessage = "Data yang dikirim tidak valid.";
        } else if (e.message.contains('ERR_500') ||
            e.message.contains('SERVER_ERROR')) {
          errorMessage =
              "Terjadi kesalahan pada server. Silahkan coba lagi nanti.";
        } else if (e.message.contains('ERR_401')) {
          errorMessage = "Tidak memiliki akses untuk melakukan reset password.";
        } else if (e.message.contains('ERR_429')) {
          errorMessage = "Terlalu banyak permintaan. Silahkan coba lagi nanti.";
        }

        SnackBars.error(context, errorMessage).clearSnackBars();
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = "Terjadi kesalahan jaringan. Silahkan coba lagi.";

        if (e.toString().contains('timeout')) {
          errorMessage = "Koneksi timeout. Periksa koneksi internet Anda.";
        } else if (e.toString().contains('SocketException')) {
          errorMessage =
              "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.";
        }

        SnackBars.error(context, errorMessage).clearSnackBars();
      }
    } finally {
      onComplete();
    }
  }

  void dispose() {
    emailController.dispose();
  }
}
