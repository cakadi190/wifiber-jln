import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/controllers/forgot_password_controller.dart';
import 'package:wifiber/helpers/network_helper.dart';
import 'package:wifiber/layouts/auth_layout.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';
import 'package:wifiber/partials/forgot_password/forgot_password_body.dart';
import 'package:wifiber/partials/forgot_password/forgot_password_footer.dart';
import 'package:wifiber/partials/forgot_password/forgot_password_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with BackendValidationMixin {
  late ForgotPasswordController _controller;
  String _ipAddress = 'Unknown';
  bool _loadingIpAddress = true;

  @override
  GlobalKey<FormState> get formKey => _controller.formKey;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController(context);
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
      header: const ForgotPasswordHeader(),
      footer: ForgotPasswordFooter(
        ipAddress: _ipAddress,
        loading: _loadingIpAddress,
      ),
      child: ForgotPasswordBody(
        controller: _controller,
        onSubmit: _handleSubmit,
        emailValidator: validator('email', _controller.validateEmail),
        onBackToLogin: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _handleSubmit() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    clearBackendErrors();

    _controller.submitForm(
      onLoading: () => setState(() => _controller.formLoading = true),
      onComplete: () {
        setState(() => _controller.formLoading = false);
      },
      authProvider: authProvider,
      onValidationError: setBackendErrors,
    );
  }
}
