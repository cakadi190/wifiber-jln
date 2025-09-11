import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/auth_screen_controller.dart';
import 'package:wifiber/helpers/network_helper.dart';
import 'package:wifiber/layouts/auth_layout.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with BackendValidationMixin {
  late LoginScreenController _controller;
  String _ipAddress = 'Unknown';
  bool _loadingIpAddress = true;

  @override
  GlobalKey<FormState> get formKey => _controller.formKey;

  @override
  void initState() {
    super.initState();
    _controller = LoginScreenController(context);
    _getPublicIp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getPublicIp() async {
    final ip = await NetworkHelper.getPublicIp();
    setState(() {
      _ipAddress = ip ?? 'Unknown';
      _loadingIpAddress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      header: _buildHeader(context),
      footer: _buildFooter(),
      child: _buildBody(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args?['showLogoutMessage'] == true) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil mengeluarkan anda dari sesi sebelumnya!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  Widget _buildBody() {
    return Column(
      children: [
        AutofillGroup(
          child: Form(
            key: _controller.formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: TextFormField(
                    controller: _controller.usernameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    enabled: !_controller.formLoading,

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
                    validator: validator(
                      'username',
                      _controller.validateUsername,
                    ),
                    onFieldSubmitted: (_) => _handleSubmit(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: TextFormField(
                    controller: _controller.passwordController,
                    obscureText: _controller.obscurePassword,
                    textInputAction: TextInputAction.done,
                    enabled: !_controller.formLoading,

                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      hintText: 'Masukkan kata sandi anda',
                      prefixIcon: Icon(
                        RemixIcons.lock_2_fill,
                        color: AppColors.primary,
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            _controller.obscurePassword =
                                !_controller.obscurePassword;
                          });
                        },
                        child: Icon(
                          _controller.obscurePassword
                              ? RemixIcons.eye_fill
                              : RemixIcons.eye_close_fill,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    validator: validator(
                      'password',
                      _controller.validatePassword,
                    ),
                    onFieldSubmitted: (_) => _handleSubmit(),
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
            onPressed: _controller.formLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _controller.formLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : const Text(
                    "Masuk Sekarang",
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
            onPressed: () => _controller.navigateToForgotPassword(),
            child: Text(
              "Lupa Kata Sandi",
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

  void _handleSubmit() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    clearBackendErrors();

    _controller.submitForm(
      onLoading: () => setState(() => _controller.formLoading = true),
      onComplete: () {
        setState(() => _controller.formLoading = false);
        _saveCredentialsToPasswordManager();
      },
      authProvider: authProvider,
      onValidationError: setBackendErrors,
    );
  }

  void _saveCredentialsToPasswordManager() {
    TextInput.finishAutofillContext(shouldSave: true);
  }

  Widget _buildHeader(BuildContext context) {
    final appTheme = Theme.of(context);

    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            "Selamat Datang!",
            style: appTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "Silahkan masuk dengan akun anda untuk melanjutkan ke dalam sistem.",
            style: appTheme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Skeletonizer(
      enabled: _loadingIpAddress,
      child: Text("Diakses dari $_ipAddress", textAlign: TextAlign.center),
    );
  }
}
