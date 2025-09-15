import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/components/reusables/options_bottom_sheet.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/models/employee.dart';
import 'package:wifiber/providers/employee_provider.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;
  final bool isEdit;
  const EmployeeFormScreen({super.key, this.employee, this.isEdit = false});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();

  bool _isLoading = false;
  String? _selectedRoleValue;
  final Map<String, String> _fieldErrors = {}; // Untuk menyimpan error per field

  // Mapping role untuk konversi
  final Map<String, String> _roleMapping = {
    '1': 'Super Administrator',
    '2': 'Admin',
    '3': 'Teknisi',
  };

  final Map<String, String> _reverseRoleMapping = {
    'Super Administrator': '1',
    'Admin': '2',
    'Teknisi': '3',
  };

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _emailController.text = widget.employee!.email ?? '';
      _usernameController.text = widget.employee!.username ?? '';

      // Handle role initialization
      final employeeRole = widget.employee!.role ?? '';
      if (_roleMapping.containsKey(employeeRole)) {
        _selectedRoleValue = employeeRole;
        _roleController.text = _roleMapping[employeeRole]!;
      } else if (_reverseRoleMapping.containsKey(employeeRole)) {
        _selectedRoleValue = _reverseRoleMapping[employeeRole];
        _roleController.text = employeeRole;
      } else {
        _roleController.text = employeeRole;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _clearFieldErrors() {
    setState(() {
      _fieldErrors.clear();
    });
  }

  void _parseErrorMessage(String errorMessage) {
    _fieldErrors.clear();

    // Contoh parsing untuk berbagai format error
    if (errorMessage.contains('validation')) {
      // Format: "Validation failed: field_name is required"
      final regex = RegExp(r'(\w+)\s+(is\s+\w+|sudah\s+\w+|wajib\s+\w+|tidak\s+\w+)');
      final matches = regex.allMatches(errorMessage.toLowerCase());

      for (final match in matches) {
        final field = match.group(1);
        final message = match.group(0);
        if (field != null && message != null) {
          _fieldErrors[field] = message;
        }
      }
    } else if (errorMessage.contains('email')) {
      _fieldErrors['email'] = 'Format email tidak valid';
    } else if (errorMessage.contains('username')) {
      _fieldErrors['username'] = 'Username sudah digunakan';
    } else if (errorMessage.contains('name')) {
      _fieldErrors['name'] = 'Nama tidak valid';
    }

    // Jika tidak ada field error yang spesifik, tampilkan error umum
    if (_fieldErrors.isEmpty) {
      _fieldErrors['general'] = errorMessage;
    }
  }

  String? _getFieldError(String fieldName) {
    return _fieldErrors[fieldName];
  }

  Future<void> _submit() async {
    // Clear previous errors
    _clearFieldErrors();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<EmployeeProvider>();
    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'username': _usernameController.text.trim(),
      'role': _selectedRoleValue ?? '3',
    };

    if (_passwordController.text.trim().isNotEmpty) {
      data['password'] = _passwordController.text.trim();
    }

    bool success = false;
    if (widget.isEdit && widget.employee != null) {
      success = await provider.updateEmployee(widget.employee!.id, data);
    } else {
      success = await provider.createEmployee(data);
    }

    if (!mounted) return;

    if (success) {
      SnackBars.success(
        context,
        widget.isEdit ? 'Karyawan berhasil diperbarui' : 'Karyawan berhasil ditambahkan',
      );
      Navigator.pop(context, true);
    } else {
      // Parse error untuk menampilkan detail error
      final errorMessage = provider.error ?? 'Terjadi kesalahan yang tidak diketahui';
      _parseErrorMessage(errorMessage);

      // Tampilkan snackbar dengan error umum
      SnackBars.error(
        context,
        _fieldErrors['general'] ?? (widget.isEdit
            ? 'Gagal memperbarui karyawan'
            : 'Gagal menambahkan karyawan'),
      );

      // Trigger form validation ulang untuk menampilkan field errors
      _formKey.currentState!.validate();
    }

    setState(() => _isLoading = false);
  }

  void _showRolePicker() {
    showOptionModalBottomSheet(
      context: context,
      header: const Text(
        'Pilih Role',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      items: [
        OptionMenuItem(
          icon: Icons.supervisor_account,
          title: 'Super Administrator',
          onTap: () {
            setState(() {
              _selectedRoleValue = '1';
              _roleController.text = 'Super Administrator';
              _fieldErrors.remove('role'); // Clear role error
            });
            Navigator.pop(context);
          },
        ),
        OptionMenuItem(
          icon: Icons.admin_panel_settings,
          title: 'Admin',
          onTap: () {
            setState(() {
              _selectedRoleValue = '2';
              _roleController.text = 'Admin';
              _fieldErrors.remove('role'); // Clear role error
            });
            Navigator.pop(context);
          },
        ),
        OptionMenuItem(
          icon: Icons.build,
          title: 'Teknisi',
          onTap: () {
            setState(() {
              _selectedRoleValue = '3';
              _roleController.text = 'Teknisi';
              _fieldErrors.remove('role'); // Clear role error
            });
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: AuthGuard(
        requiredPermissions: const ['employee'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
            title: Text(widget.isEdit ? 'Edit Karyawan' : 'Tambah Karyawan'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                          _buildTextField(
                            controller: _nameController,
                            label: 'Nama',
                            hint: 'Masukkan nama karyawan',
                            icon: Icons.person,
                            fieldName: 'name',
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Nama wajib diisi';
                              }
                              if (v.trim().length < 2) {
                                return 'Nama minimal 2 karakter';
                              }
                              return _getFieldError('name');
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Masukkan email',
                            icon: Icons.email,
                            fieldName: 'email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v != null && v.trim().isNotEmpty) {
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(v.trim())) {
                                  return 'Format email tidak valid';
                                }
                              }
                              return _getFieldError('email');
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _usernameController,
                            label: 'Username',
                            hint: 'Masukkan username',
                            icon: Icons.person_outline,
                            fieldName: 'username',
                            validator: (v) {
                              if (v != null && v.trim().isNotEmpty) {
                                if (v.trim().length < 3) {
                                  return 'Username minimal 3 karakter';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                                  return 'Username hanya boleh mengandung huruf, angka, dan underscore';
                                }
                              }
                              return _getFieldError('username');
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            label: widget.isEdit ? 'Password (kosongkan jika tidak ingin mengubah)' : 'Password',
                            hint: 'Masukkan password',
                            icon: Icons.lock,
                            fieldName: 'password',
                            obscureText: true,
                            validator: (v) {
                              if (!widget.isEdit && (v == null || v.trim().isEmpty)) {
                                return 'Password wajib diisi';
                              }
                              if (v != null && v.trim().isNotEmpty && v.trim().length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return _getFieldError('password');
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _roleController,
                            label: 'Role / Grup Karyawan',
                            hint: 'Pilih role',
                            icon: Icons.badge,
                            fieldName: 'role',
                            readOnly: true,
                            onTap: _showRolePicker,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Role wajib dipilih';
                              }
                              return _getFieldError('role');
                            },
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
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
                                : Text(
                              widget.isEdit
                                  ? 'Simpan Perubahan'
                                  : 'Tambah Karyawan',
                              style: const TextStyle(
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String fieldName,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: (value) {
        // Clear field error saat user mengetik
        if (_fieldErrors.containsKey(fieldName)) {
          setState(() {
            _fieldErrors.remove(fieldName);
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        errorMaxLines: 2,
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
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}