import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/alert.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'dart:convert';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.formName,
    required this.formLabel,
    required this.value,
  });

  final String formName;
  final String value;
  final String formLabel;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with BackendValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController(text: '');
  bool _isLoading = false;

  @override
  GlobalKey<FormState> get formKey => _formKey;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    clearBackendErrors();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user!;
    final token = user.accessToken;

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://wifiber.web.id/api/v1/profiles/${user.userId}',
      );

      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      };

      final Map<String, String> requestBody = {
        widget.formName: _controller.text,
      };

      final response = await http.post(
        url,
        headers: requestHeaders,
        body: _encodeFormData(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.formLabel} berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(_controller.text);
        }
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        final errors = data['errors'] ?? data['error']?['message'];
        if (errors is Map<String, dynamic>) {
          setBackendErrors(errors);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Data tidak valid'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal memperbarui ${widget.formLabel.toLowerCase()}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _encodeFormData(Map<String, String> data) {
    return data.keys
        .map((key) => '$key=${Uri.encodeQueryComponent(data[key]!)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: AuthGuard(
        requiredPermissions: const ['company-profile'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
          title: Text("Perbarui ${widget.formLabel}"),
          actions: [
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _isLoading ? null : _submitProfile,
                    child: const Icon(Icons.save, color: Colors.white),
                  ),
          ],
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Alert.opaque(
                    fullWidth: true,
                    child: const Text(
                      "Mohon isi formulir di bawah ini dengan lengkap dan benar untuk memperbarui data profil Anda.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _controller,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: widget.formLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: validator(
                      widget.formName,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi ${widget.formLabel.toLowerCase()}';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading
                            ? Colors.grey
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _submitProfile,
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Menyimpan...'),
                              ],
                            )
                          : const Text('Simpan'),
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
}
