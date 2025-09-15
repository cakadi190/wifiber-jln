import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/components/reusables/options_bottom_sheet.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/router.dart';
import 'package:wifiber/providers/router_provider.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';

class EditMikrotikScreen extends StatefulWidget {
  final RouterModel router;

  const EditMikrotikScreen({super.key, required this.router});

  @override
  State<EditMikrotikScreen> createState() => _EditMikrotikScreenState();
}

class _EditMikrotikScreenState extends State<EditMikrotikScreen>
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

  final Map<String, String> _isolateActions = {
    'toggle': 'Enable/Disable Secret PPPoE',
    'change-profile': 'Ganti Profil PPPoE',
  };

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    _nameController.text = widget.router.name;
    _hostnameController.text = widget.router.host;
    _toleranceDaysController.text = widget.router.toleranceDays.toString();
  }

  @override
  GlobalKey<FormState> get formKey => _formKey;

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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_isolateAction.isEmpty) {
        SnackBars.error(context, 'Pilih aksi isolasi terlebih dahulu');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final routerProvider = Provider.of<RouterProvider>(
        context,
        listen: false,
      );

      final updateRouterModel = UpdateRouterModel(
        name: _nameController.text.trim(),
        hostname: _hostnameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        port: _portController.text.trim(),
        toleranceDays: int.parse(_toleranceDaysController.text.trim()),
        isolateAction: _isolateAction,
        isolateProfile:
        _isolateAction == 'change-profile' &&
            _isolateProfileController.text.trim().isNotEmpty
            ? _isolateProfileController.text.trim()
            : null,
        isAutoIsolate: _isAutoIsolate,
      );

      clearBackendErrors();

      try {
        final success = await routerProvider.updateRouter(
          widget.router.id,
          updateRouterModel,
        );

        if (mounted && success) {
          SnackBars.success(context, 'Router berhasil diperbarui');
          Navigator.pop(context, true);
        }

        if (mounted && !success) {
          SnackBars.error(context, 'Gagal memperbarui router');
        }
      } on ValidationException catch (e) {
        setBackendErrors(e.errors);
        if (mounted) {
          SnackBars.error(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui router: ${e.toString()}'),
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
  }

  void _showDeleteConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200, width: 2),
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 40,
                color: Colors.red.shade600,
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Hapus Router',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.router, color: Colors.grey.shade600, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    widget.router.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Apakah Anda yakin ingin menghapus router ini?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Tindakan ini tidak dapat dibatalkan dan semua data terkait akan hilang permanen.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.pop(context);
                        _deleteRouter();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Ya, Hapus Router',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _deleteRouter() async {
    setState(() {
      _isLoading = true;
    });

    final routerProvider = Provider.of<RouterProvider>(context, listen: false);

    try {
      final success = await routerProvider.deleteRouter(widget.router.id);

      if (mounted && success) {
        SnackBars.success(context, 'Router berhasil dihapus');
        Navigator.pop(context, true);
      }

      if (mounted && !success) {
        SnackBars.error(context, 'Gagal menghapus router');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus router: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: AuthGuard(
        requiredPermissions: const ['integration'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
            title: const Text('Edit Mikrotik'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _showDeleteConfirmation,
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                  BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),

                          _buildTextFormField(
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

                          _buildTextFormField(
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

                          _buildTextFormField(
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

                          _buildTextFormField(
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

                          _buildTextFormField(
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

                          _buildTextFormField(
                            field: 'tolerance_days',
                            controller: _toleranceDaysController,
                            label: 'Hari Toleransi',
                            hint: 'Masukkan jumlah hari toleransi',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Hari toleransi tidak boleh kosong';
                              }
                              final days = int.tryParse(value.trim());
                              if (days == null || days < 0) {
                                return 'Hari toleransi harus berupa angka positif';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () => _showIsolateActionBottomSheet(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.block, color: Colors.grey),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Aksi Isolasi',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
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
                                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),

                          if (_isolateAction == 'change-profile') ...[
                            const SizedBox(height: 16),
                            _buildTextFormField(
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
                                const Icon(Icons.auto_awesome, color: Colors.grey),
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
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Perbarui Router',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showIsolateActionBottomSheet() {
    showOptionModalBottomSheet(
      context: context,
      header: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Aksi Isolasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
        ],
      ),
      items: _isolateActions.entries.map((entry) {
        final selected = _isolateAction == entry.key;
        return OptionMenuItem(
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: selected
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
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  Widget _buildTextFormField({
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}