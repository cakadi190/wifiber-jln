import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';
import 'package:wifiber/components/reusables/options_bottom_sheet.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/models/router.dart';
import 'package:wifiber/providers/router_provider.dart';

class MikrotikFormSheet extends StatefulWidget {
  final RouterModel? router;

  const MikrotikFormSheet({super.key, this.router});

  bool get isEdit => router != null;

  @override
  State<MikrotikFormSheet> createState() => _MikrotikFormSheetState();
}

class _MikrotikFormSheetState extends State<MikrotikFormSheet>
    with BackendValidationMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _hostnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _portController = TextEditingController();
  final _toleranceDaysController = TextEditingController();
  final _isolateProfileController = TextEditingController();

  String _isolateAction = '';
  bool _isAutoIsolate = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final Map<String, String> _isolateActions = const {
    'toggle': 'Enable/Disable Secret PPPoE',
    'change-profile': 'Ganti Profil PPPoE',
  };

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    if (widget.isEdit) {
      final router = widget.router!;
      _nameController.text = router.name;
      _hostnameController.text = router.host;
      _toleranceDaysController.text = router.toleranceDays.toString();

      if (router.action.isNotEmpty) {
        _isolateAction = router.action;
      }

      if (router.isolirProfile.isNotEmpty) {
        _isolateProfileController.text = router.isolirProfile;
      }
    } else {
      _portController.text = '8728';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _portController.dispose();
    _toleranceDaysController.dispose();
    _isolateProfileController.dispose();
    super.dispose();
  }

  @override
  GlobalKey<FormState> get formKey => _formKey;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isolateAction.isEmpty) {
      SnackBars.error(context, 'Pilih aksi isolasi terlebih dahulu');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    clearBackendErrors();

    final routerProvider = context.read<RouterProvider>();

    final toleranceDays =
        int.tryParse(_toleranceDaysController.text.trim()) ?? 0;

    try {
      final success = widget.isEdit
          ? await routerProvider.updateRouter(
              widget.router!.id,
              UpdateRouterModel(
                name: _nameController.text.trim(),
                hostname: _hostnameController.text.trim(),
                username: _usernameController.text.trim(),
                password: _passwordController.text.trim(),
                port: _portController.text.trim(),
                toleranceDays: toleranceDays,
                isolateAction: _isolateAction,
                isolateProfile:
                    _isolateAction == 'change-profile' &&
                        _isolateProfileController.text.trim().isNotEmpty
                    ? _isolateProfileController.text.trim()
                    : null,
                isAutoIsolate: _isAutoIsolate,
              ),
            )
          : await routerProvider.addRouter(
              AddRouterModel(
                name: _nameController.text.trim(),
                hostname: _hostnameController.text.trim(),
                username: _usernameController.text.trim(),
                password: _passwordController.text.trim(),
                port: _portController.text.trim(),
                toleranceDays: toleranceDays,
                isolateAction: _isolateAction,
                isolateProfile:
                    _isolateAction == 'change-profile' &&
                        _isolateProfileController.text.trim().isNotEmpty
                    ? _isolateProfileController.text.trim()
                    : null,
                isAutoIsolate: _isAutoIsolate,
              ),
            );

      if (!mounted) {
        return;
      }

      if (success) {
        SnackBars.success(
          context,
          widget.isEdit
              ? 'Router berhasil diperbarui'
              : 'Router berhasil ditambahkan',
        );
        Navigator.of(context).pop(true);
      } else {
        SnackBars.error(
          context,
          widget.isEdit
              ? 'Gagal memperbarui router'
              : 'Gagal menambahkan router',
        );
      }
    } on ValidationException catch (error) {
      setBackendErrors(error.errors);
      if (mounted) {
        SnackBars.error(context, error.message);
      }
    } catch (error) {
      if (mounted) {
        SnackBars.error(context, 'Terjadi kesalahan: ${error.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
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
                      Icon(
                        widget.isEdit ? Icons.edit : Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.isEdit ? 'Perbarui Router' : 'Tambah Router',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
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
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          field: 'name',
                          controller: _nameController,
                          label: 'Nama Router',
                          hint: 'Masukkan nama router',
                          icon: Icons.router,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama router tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          field: 'hostname',
                          controller: _hostnameController,
                          label: 'Hostname/IP Address',
                          hint: 'Masukkan hostname atau IP address',
                          icon: Icons.dns,
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Hostname tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          field: 'username',
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
                          field: 'password',
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
                            if (value == null || value.trim().isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          field: 'port',
                          controller: _portController,
                          label: 'Port',
                          hint: 'Masukkan port (default: 8728)',
                          icon: Icons.settings_input_composite,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Port tidak boleh kosong';
                            }
                            final port = int.tryParse(value.trim());
                            if (port == null || port < 1 || port > 65535) {
                              return 'Port harus berupa angka antara 1-65535';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          field: 'tolerance_days',
                          controller: _toleranceDaysController,
                          label: 'Tenggat Toleransi (hari)',
                          hint: 'Masukkan jumlah hari toleransi',
                          icon: Icons.timer,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Tenggat toleransi tidak boleh kosong';
                            }
                            final days = int.tryParse(value.trim());
                            if (days == null || days < 0) {
                              return 'Masukkan angka yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _showIsolateActionBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isolateAction.isEmpty
                                    ? Colors.grey.shade300
                                    : AppColors.primary.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shuffle, color: Colors.grey),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Aksi Isolasi',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isolateAction.isEmpty
                                            ? '- Pilih -'
                                            : _isolateActions[_isolateAction]!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _isolateAction.isEmpty
                                              ? Colors.grey.shade600
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isolateAction == 'change-profile') ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            field: 'isolate_profile',
                            controller: _isolateProfileController,
                            label: 'Profil Isolasi',
                            hint: 'Masukkan profil isolasi',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (_isolateAction == 'change-profile' &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Profil isolasi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Auto Isolasi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Aktifkan isolasi otomatis',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isAutoIsolate,
                                onChanged: (value) {
                                  setState(() {
                                    _isAutoIsolate = value;
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
                              : Text(
                                  widget.isEdit
                                      ? 'Perbarui Router'
                                      : 'Tambah Router',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
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

  void _showIsolateActionBottomSheet() {
    showOptionModalBottomSheet(
      context: context,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Pilih Aksi Isolasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
        ],
      ),
      items: _isolateActions.entries.map((entry) {
        final isSelected = _isolateAction == entry.key;
        return OptionMenuItem(
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          title: entry.value,
          trailing: null,
          onTap: () {
            setState(() {
              _isolateAction = entry.key;
              if (entry.key == 'toggle') {
                _isolateProfileController.clear();
              }
            });
            Navigator.of(context).pop();
          },
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required String field,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: this.validator(field, validator),
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
