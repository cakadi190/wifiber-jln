import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/forgot_password_controller.dart';
import 'package:wifiber/helpers/network_helper.dart';
import 'package:wifiber/layouts/auth_layout.dart';
import 'package:wifiber/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late ForgotPasswordController _controller;
  String _ipAddress = 'Unknown';
  bool _loadingIpAddress = true;

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
      header: _buildHeader(context),
      footer: _buildFooter(),
      child: _buildBody(),
    );
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
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: TextFormField(
                    controller: _controller.emailController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_controller.formLoading,
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Surel',
                      hintText: 'Masukkan surel anda',
                      prefixIcon: Icon(
                        RemixIcons.mail_fill,
                        color: AppColors.primary,
                      ),
                    ),
                    validator: _controller.validateEmail,
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
              "Kirim Instruksinya!",
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
            onPressed: _controller.formLoading
                ? null
                : () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Kembali ke Login",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        _buildInfoFooter(),
      ],
    );
  }

  void _handleSubmit() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _controller.submitForm(
      onLoading: () => setState(() => _controller.formLoading = true),
      onComplete: () {
        setState(() => _controller.formLoading = false);
      },
      authProvider: authProvider,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final appTheme = Theme.of(context);

    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            "Lupa Kata Sandi?",
            style: appTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "Masukkan email Anda dan kami akan mengirimkan instruksi reset kata sandi ke email Anda.",
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

  Widget _buildInfoFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "Butuh bantuan?"),
            TextSpan(
              text: " Silahkan Hubungi Kami di WhatsApp.",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}