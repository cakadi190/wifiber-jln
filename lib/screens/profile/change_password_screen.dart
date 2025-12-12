import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/change_password_controller.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/forgot_password_screen.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';
import 'package:wifiber/partials/profile/change_password_form.dart';
import 'package:wifiber/partials/profile/change_password_info.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with BackendValidationMixin {
  late ChangePasswordController _controller;

  @override
  GlobalKey<FormState> get formKey => _controller.formKey;

  @override
  void initState() {
    super.initState();
    _controller = ChangePasswordController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Ubah Kata Sandi')),
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Container(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const ChangePasswordInfo(),

                    const SizedBox(height: 32),

                    ChangePasswordForm(
                      controller: _controller,
                      onSubmit: _handleSubmit,
                      onForgotPassword: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      currentPasswordValidator: validator(
                        'existing_password',
                        _controller.validateCurrentPassword,
                      ),
                      newPasswordValidator: validator(
                        'new_password',
                        _controller.validateNewPassword,
                      ),
                      confirmPasswordValidator: validator(
                        'new_password_confirmation',
                        _controller.validateConfirmPassword,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    clearBackendErrors();

    final success = await _controller.changePassword(
      context,
      user,
      onValidationError: setBackendErrors,
    );
    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
