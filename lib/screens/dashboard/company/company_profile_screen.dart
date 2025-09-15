import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/providers/company_provider.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _sloganController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _csPhoneController = TextEditingController();
  XFile? _logoFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CompanyProvider>();
    provider.loadCompany().then((_) {
      final company = provider.company;
      if (company != null) {
        _nameController.text = company.name;
        _shortNameController.text = company.shortName;
        _sloganController.text = company.slogan;
        _emailController.text = company.email;
        _addressController.text = company.address;
        _csPhoneController.text = company.csPhone;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _sloganController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _csPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _logoFile = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text,
      'short-name': _shortNameController.text,
      'slogan': _sloganController.text,
      'email': _emailController.text,
      'address': _addressController.text,
      'cs-phone': _csPhoneController.text,
      if (_logoFile != null) 'logo': _logoFile,
    };

    final provider = context.read<CompanyProvider>();
    bool success;
    setState(() => _isSubmitting = true);
    if (provider.company == null) {
      success = await provider.createCompany(data);
    } else {
      success = await provider.updateCompany(data);
    }
    if (mounted) setState(() => _isSubmitting = false);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyProvider>();
    final logoWidget = _buildLogoWidget(provider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(title: const Text('Detail Perusahaan')),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                logoWidget,
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _shortNameController,
                  decoration: const InputDecoration(labelText: 'Nama Singkat'),
                  validator: (v) => v == null || v.isEmpty ? 'Nama singkat wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _sloganController,
                  decoration: const InputDecoration(labelText: 'Slogan'),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v == null || v.isEmpty ? 'Email wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _csPhoneController,
                  decoration: const InputDecoration(labelText: 'Nomor CS'),
                  validator: (v) => v == null || v.isEmpty ? 'Nomor CS wajib diisi' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _save,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoWidget(CompanyProvider provider) {
    Widget image;
    if (_logoFile != null) {
      image = Image.file(
        File(_logoFile!.path),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    } else if (provider.company?.logo != null && provider.company!.logo!.isNotEmpty) {
      image = Image.network(
        provider.company!.logo!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    } else {
      image = Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 40, color: Colors.grey),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image,
        ),
        TextButton(
          onPressed: _pickLogo,
          child: const Text('Pilih Logo'),
        ),
      ],
    );
  }
}

