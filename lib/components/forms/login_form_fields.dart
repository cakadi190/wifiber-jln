import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/auth_screen_controller.dart';

class LoginFormFields extends StatelessWidget {
  const LoginFormFields({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.usernameValidator,
    required this.passwordValidator,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
  });

  final LoginScreenController controller;
  final VoidCallback onSubmit;
  final FormFieldValidator<String>? usernameValidator;
  final FormFieldValidator<String>? passwordValidator;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            _UsernameField(
              controller: controller,
              validator: usernameValidator,
              onSubmit: onSubmit,
            ),
            _PasswordField(
              controller: controller,
              validator: passwordValidator,
              obscureText: obscurePassword,
              onToggleVisibility: onTogglePasswordVisibility,
              onSubmit: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class LoginFormActions extends StatelessWidget {
  const LoginFormActions({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final bool isLoading;
  final VoidCallback onSubmit;
  final Future<void> Function() onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : const Text(
                    'Masuk Sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => onForgotPassword(),
            child: Text(
              'Lupa Kata Sandi',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField({
    required this.controller,
    required this.validator,
    required this.onSubmit,
  });

  final LoginScreenController controller;
  final FormFieldValidator<String>? validator;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: TextFormField(
        controller: controller.usernameController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        enabled: !controller.formLoading,
        autofillHints: const [
          AutofillHints.username,
          AutofillHints.email,
        ],
        decoration: InputDecoration(
          labelText: 'Nama Pengguna',
          hintText: 'Masukkan nama pengguna anda',
          prefixIcon: Icon(
            RemixIcons.user_fill,
            color: AppColors.primary,
          ),
        ),
        validator: validator,
        onFieldSubmitted: (_) => onSubmit(),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.validator,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.onSubmit,
  });

  final LoginScreenController controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: TextFormField(
        controller: controller.passwordController,
        obscureText: obscureText,
        textInputAction: TextInputAction.done,
        enabled: !controller.formLoading,
        autofillHints: const [AutofillHints.password],
        decoration: InputDecoration(
          labelText: 'Kata Sandi',
          hintText: 'Masukkan kata sandi anda',
          prefixIcon: Icon(
            RemixIcons.lock_2_fill,
            color: AppColors.primary,
          ),
          suffixIcon: InkWell(
            onTap: onToggleVisibility,
            child: Icon(
              obscureText ? RemixIcons.eye_fill : RemixIcons.eye_close_fill,
              color: AppColors.primary,
            ),
          ),
        ),
        validator: validator,
        onFieldSubmitted: (_) => onSubmit(),
      ),
    );
  }
}
