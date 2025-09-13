import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/alert.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/exceptions/string_exceptions.dart';

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
  final _httpService = HttpService();
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

    setState(() {
      _isLoading = true;
    });

    try {
      await _httpService.postForm(
        '/profiles/${user.userId}',
        fields: {widget.formName: _controller.text},
        requiresAuth: true,
      );

      await auth.reinitialize(force: true);

      if (mounted) {
        _showSuccessMessage('${widget.formLabel} berhasil diperbarui');
        Navigator.of(context).pop(_controller.text);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        _handleValidationErrors(e);
      }
    } on StringException catch (e) {
      if (mounted) {
        _showErrorMessage(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Terjadi kesalahan tidak terduga: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleValidationErrors(ValidationException exception) {
    setBackendErrors(exception.errors);

    _showErrorMessage(exception.message);

    _showValidationErrorDialog(exception.errors);
  }

  void _showValidationErrorDialog(Map<String, dynamic> errors) {
    final errorMessages = <String>[];

    errors.forEach((field, messages) {
      if (messages is List) {
        for (final message in messages) {
          errorMessages.add('• $message');
        }
      } else if (messages is String) {
        errorMessages.add('• $messages');
      }
    });

    if (errorMessages.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Error Validasi'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mohon perbaiki error berikut:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ...errorMessages.map(
                  (message) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(message, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
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
                      prefixIcon: _getFieldIcon(widget.formName),
                    ),
                    validator: validator(widget.formName, (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi ${widget.formLabel.toLowerCase()}';
                      }
                      return null;
                    }),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                          : Text(
                              'Simpan ${widget.formLabel}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  Widget? _getFieldIcon(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'name':
      case 'full_name':
      case 'nama':
        return const Icon(Icons.person);
      case 'email':
        return const Icon(Icons.email);
      case 'phone':
      case 'phone_number':
      case 'telepon':
        return const Icon(Icons.phone);
      case 'address':
      case 'alamat':
        return const Icon(Icons.location_on);
      case 'company':
      case 'perusahaan':
        return const Icon(Icons.business);
      default:
        return const Icon(Icons.edit);
    }
  }
}
