import 'package:flutter/material.dart';
import 'package:wifiber/components/forms/login_form_fields.dart';
import 'package:wifiber/controllers/auth_screen_controller.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({
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
    return Column(
      children: [
        LoginFormFields(
          controller: controller,
          onSubmit: onSubmit,
          usernameValidator: usernameValidator,
          passwordValidator: passwordValidator,
          obscurePassword: obscurePassword,
          onTogglePasswordVisibility: onTogglePasswordVisibility,
        ),
        LoginFormActions(
          isLoading: controller.formLoading,
          onSubmit: onSubmit,
          onForgotPassword: controller.navigateToForgotPassword,
        ),
      ],
    );
  }
}
