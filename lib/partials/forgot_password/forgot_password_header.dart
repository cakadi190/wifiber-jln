import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);

    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            'Lupa Kata Sandi?',
            style: appTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Masukkan email Anda dan kami akan mengirimkan instruksi reset kata sandi ke email Anda.',
            style: appTheme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
