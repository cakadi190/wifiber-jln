import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/app_logo.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/splash_screen_controller.dart';

class SplashScreenBody extends StatelessWidget {
  const SplashScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: SizedBox()),
        const AppLogo(),
        const Expanded(child: SizedBox()),
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 16),
        Consumer<SplashScreenController>(
          builder: (context, controller, child) {
            return Text(
              controller.splashText,
              style: const TextStyle(color: Colors.black),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
