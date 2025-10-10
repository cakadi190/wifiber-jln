import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/components/forms/login_form_fields.dart';
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
        LoginFormFields(
          controller: _controller,
          onSubmit: _handleSubmit,
          usernameValidator: validator(
            'username',
            _controller.validateUsername,
          ),
          passwordValidator: validator(
            'password',
            _controller.validatePassword,
          ),
          obscurePassword: _controller.obscurePassword,
          onTogglePasswordVisibility: () {
            setState(() {
              _controller.obscurePassword = !_controller.obscurePassword;
            });
          },
        ),
        LoginFormActions(
          isLoading: _controller.formLoading,
          onSubmit: _handleSubmit,
          onForgotPassword: () => _controller.navigateToForgotPassword(),
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
