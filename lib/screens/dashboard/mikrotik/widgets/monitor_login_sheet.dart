import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/models/router.dart';
import 'package:wifiber/services/router_os_api_client.dart';

class MonitorLoginResult {
  final RouterOsApiClient client;
  final String username;
  final int port;
  final bool useSsl;

  MonitorLoginResult({
    required this.client,
    required this.username,
    required this.port,
    required this.useSsl,
  });
}

class MonitorLoginSheet extends StatefulWidget {
  final RouterModel router;

  const MonitorLoginSheet({super.key, required this.router});

  @override
  State<MonitorLoginSheet> createState() => _MonitorLoginSheetState();
}

class _MonitorLoginSheetState extends State<MonitorLoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController();
  final _portController = TextEditingController(text: '8728');

  bool _isPasswordVisible = false;
  bool _useSsl = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: viewInsets),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.router, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Masuk Ke RouterOS',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.router.host,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: 'Masukkan username',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Masukkan password',
                          icon: Icons.lock,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _portController,
                          label: 'Port API',
                          hint: 'Masukkan port (default: 8728)',
                          icon: Icons.settings_ethernet,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Port tidak boleh kosong';
                            }
                            final port = int.tryParse(value.trim());
                            if (port == null || port < 1 || port > 65535) {
                              return 'Port harus berada di rentang 1-65535';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    'Silakan periksa ke dalam router dengan mengetikkan ',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: '/ip service print',
                                style: GoogleFonts.jetBrainsMono(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' dan lihat pada bagian API itu port berapa.',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.security, color: Colors.grey),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Gunakan koneksi SSL/TLS (port 8729)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _useSsl,
                                onChanged: _isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _useSsl = value;
                                          _portController.text = value
                                              ? '8729'
                                              : '8728';
                                        });
                                      },
                                activeThumbColor: AppColors.primary,
                                activeTrackColor: AppColors.primary.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sambungkan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final port =
        int.tryParse(_portController.text.trim()) ?? (_useSsl ? 8729 : 8728);

    final client = RouterOsApiClient(
      host: widget.router.host,
      port: port,
      timeout: const Duration(seconds: 10),
      useSsl: _useSsl,
      allowSelfSigned: true,
    );

    var popInvoked = false;

    try {
      await client.connect();
      final isLoggedIn = await client.login(
        username: username,
        password: password,
      );

      if (!mounted) {
        client.close();
        return;
      }

      if (isLoggedIn) {
        popInvoked = true;
        Navigator.of(context).pop(
          MonitorLoginResult(
            client: client,
            username: username,
            port: port,
            useSsl: _useSsl,
          ),
        );
      } else {
        client.close();
        SnackBars.error(context, 'Login ke RouterOS gagal.');
      }
    } catch (error) {
      client.close();
      if (mounted) {
        SnackBars.error(
          context,
          'Gagal terhubung ke RouterOS: ${error.toString()}',
        );
      }
    } finally {
      if (!popInvoked && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
