import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/alert.dart';
import 'package:wifiber/components/widgets/password_meter.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/change_password_controller.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:remixicon/remixicon.dart';
import 'package:wifiber/providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late ChangePasswordController _controller;

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
    final theme = Theme.of(context);

    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Ubah Kata Sandi')),
        backgroundColor: AppColors.primary,
        body: SingleChildScrollView(
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
                  Alert.opaque(
                    fullWidth: true,
                    type: AlertType.info,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_rounded,
                          color: Colors.blue,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ubah Kata Sandi',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Kata sandi minimal 8 karakter, termasuk huruf besar, huruf kecil, angka, dan simbol. Dan pastikan kata sandi yang anda buat dapat anda dapat diingat dengan baik.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Form(
                    key: _controller.formKey,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return TextFormField(
                              controller: _controller.currentPasswordController,
                              textInputAction: TextInputAction.next,
                              obscureText: _controller.obscureCurrentPassword,
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi Sekarang',
                                suffixIcon: GestureDetector(
                                  onTap: _controller
                                      .toggleCurrentPasswordVisibility,
                                  child: Icon(
                                    _controller.obscureCurrentPassword
                                        ? RemixIcons.eye_fill
                                        : RemixIcons.eye_close_fill,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              validator: _controller.validateCurrentPassword,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _controller.passwordController,
                                  textInputAction: TextInputAction.next,
                                  obscureText: _controller.obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Kata Sandi Baru',
                                    suffixIcon: GestureDetector(
                                      onTap:
                                          _controller.togglePasswordVisibility,
                                      child: Icon(
                                        _controller.obscurePassword
                                            ? RemixIcons.eye_fill
                                            : RemixIcons.eye_close_fill,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  validator: _controller.validateNewPassword,
                                ),

                                PasswordMeterWidget(
                                  passwordMeter: _controller.passwordMeter,
                                  password: _controller.passwordController.text,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return TextFormField(
                              controller: _controller.confirmPasswordController,
                              textInputAction: TextInputAction.done,
                              obscureText: _controller.obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Konfirmasi Kata Sandi Baru',
                                suffixIcon: GestureDetector(
                                  onTap: _controller
                                      .toggleConfirmPasswordVisibility,
                                  child: Icon(
                                    _controller.obscureConfirmPassword
                                        ? RemixIcons.eye_fill
                                        : RemixIcons.eye_close_fill,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              validator: _controller.validateConfirmPassword,
                              onFieldSubmitted: (_) => _handleSubmit(),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return ElevatedButton(
                                onPressed: _controller.isLoading
                                    ? null
                                    : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _controller.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                  ),
                ],
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

    final success = await _controller.changePassword(context, user);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}