import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);

    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            'Selamat Datang!',
            style: appTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Silahkan masuk dengan akun anda untuk melanjutkan ke dalam sistem.',
            style: appTheme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
