import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/controllers/auth_screen_controller.dart';
import 'package:wifiber/helpers/network_helper.dart';
import 'package:wifiber/layouts/auth_layout.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/partials/login/login_body.dart';
import 'package:wifiber/partials/login/login_footer.dart';
import 'package:wifiber/partials/login/login_header.dart';

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
    if (!mounted) return;
    setState(() {
      _ipAddress = ip ?? 'Unknown';
      _loadingIpAddress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      header: const LoginHeader(),
      footer: LoginFooter(ipAddress: _ipAddress, loading: _loadingIpAddress),
      child: LoginBody(
        controller: _controller,
        onSubmit: _handleSubmit,
        usernameValidator: validator('username', _controller.validateUsername),
        passwordValidator: validator('password', _controller.validatePassword),
        obscurePassword: _controller.obscurePassword,
        onTogglePasswordVisibility: () {
          setState(() {
            _controller.obscurePassword = !_controller.obscurePassword;
          });
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args?['showLogoutMessage'] == true) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        SnackBars.success(
          context,
          'Berhasil mengeluarkan anda dari sesi sebelumnya!',
        );
      });
    }
  }

  void _handleSubmit() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    clearBackendErrors();

    _controller.submitForm(
      onLoading: () {
        if (!mounted) return;
        setState(() => _controller.formLoading = true);
      },
      onComplete: () {
        if (!mounted) return;
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
}
