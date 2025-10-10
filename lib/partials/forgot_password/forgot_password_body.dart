import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/forgot_password_controller.dart';
import 'package:wifiber/partials/forgot_password/forgot_password_info_footer.dart';

class ForgotPasswordBody extends StatelessWidget {
  const ForgotPasswordBody({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.emailValidator,
    required this.onBackToLogin,
  });

  final ForgotPasswordController controller;
  final VoidCallback onSubmit;
  final FormFieldValidator<String>? emailValidator;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AutofillGroup(
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: TextFormField(
                    controller: controller.emailController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !controller.formLoading,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: 'Surel',
                      hintText: 'Masukkan surel anda',
                      prefixIcon: Icon(
                        RemixIcons.mail_fill,
                        color: AppColors.primary,
                      ),
                    ),
                    validator: emailValidator,
                    onFieldSubmitted: (_) => onSubmit(),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: controller.formLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: controller.formLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : const Text(
                    'Kirim Instruksinya!',
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
            onPressed: controller.formLoading ? null : onBackToLogin,
            child: Text(
              'Kembali ke Login',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const ForgotPasswordInfoFooter(),
      ],
    );
  }
}
