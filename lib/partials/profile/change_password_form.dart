import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:wifiber/components/widgets/password_meter.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/change_password_controller.dart';

class ChangePasswordForm extends StatelessWidget {
  const ChangePasswordForm({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.currentPasswordValidator,
    required this.newPasswordValidator,
    required this.confirmPasswordValidator,
  });

  final ChangePasswordController controller;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final FormFieldValidator<String>? currentPasswordValidator;
  final FormFieldValidator<String>? newPasswordValidator;
  final FormFieldValidator<String>? confirmPasswordValidator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return TextFormField(
                controller: controller.currentPasswordController,
                textInputAction: TextInputAction.next,
                obscureText: controller.obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Sekarang',
                  suffixIcon: GestureDetector(
                    onTap: controller.toggleCurrentPasswordVisibility,
                    child: Icon(
                      controller.obscureCurrentPassword
                          ? RemixIcons.eye_fill
                          : RemixIcons.eye_close_fill,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                validator: currentPasswordValidator,
              );
            },
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: 'Wah, lupa sandinya nih? ',
              style: theme.textTheme.bodySmall,
              children: [
                TextSpan(
                  text: 'Klik disini',
                  style: theme.textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.underline,
                    color: AppColors.primary,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onForgotPassword,
                ),
                const TextSpan(
                  text: ' untuk memulihkan kata sandi anda yang terlupa.',
                ),
              ],
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: controller.passwordController,
                    textInputAction: TextInputAction.next,
                    obscureText: controller.obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru',
                      suffixIcon: GestureDetector(
                        onTap: controller.togglePasswordVisibility,
                        child: Icon(
                          controller.obscurePassword
                              ? RemixIcons.eye_fill
                              : RemixIcons.eye_close_fill,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    validator: newPasswordValidator,
                  ),
                  PasswordMeterWidget(
                    passwordMeter: controller.passwordMeter,
                    password: controller.passwordController.text,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return TextFormField(
                controller: controller.confirmPasswordController,
                textInputAction: TextInputAction.done,
                obscureText: controller.obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi Baru',
                  suffixIcon: GestureDetector(
                    onTap: controller.toggleConfirmPasswordVisibility,
                    child: Icon(
                      controller.obscureConfirmPassword
                          ? RemixIcons.eye_fill
                          : RemixIcons.eye_close_fill,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                validator: confirmPasswordValidator,
                onFieldSubmitted: (_) => onSubmit(),
              );
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return ElevatedButton(
                  onPressed: controller.isLoading ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Ubah Kata Sandi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
