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

class CreateMikrotikScreen extends StatefulWidget {
  const CreateMikrotikScreen({super.key});

  @override
  State<CreateMikrotikScreen> createState() => _CreateMikrotikScreenState();
}

class _CreateMikrotikScreenState extends State<CreateMikrotikScreen>
    with BackendValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _portController = TextEditingController(text: '8728');
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

      final addRouterModel = AddRouterModel(
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
        final success = await routerProvider.addRouter(addRouterModel);

        if (mounted && success) {
          SnackBars.success(context, 'Router berhasil ditambahkan');
          Navigator.pop(context, true);
        }

        if (mounted && !success) {
          SnackBars.error(context, 'Gagal menambahkan router');
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
              content: Text('Gagal menambahkan router: ${e.toString()}'),
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
            title: const Text('Tambah Mikrotik'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
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
                    decoration: BoxDecoration(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.grey),
                            SizedBox(width: 12),
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
                                  SizedBox(height: 4),
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
                            Icon(Icons.arrow_drop_down, color: Colors.grey),
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
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.grey),
                          SizedBox(width: 12),
                          Expanded(
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
                                    color: Colors.grey.shade600,
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
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Tambah Router',
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
          );
        },
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
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
