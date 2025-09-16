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

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final provider = context.read<CompanyProvider>();
    await provider.loadCompany();

    if (mounted) {
      final company = provider.company;
      if (company != null) {
        setState(() {
          _nameController.text = company.name;
          _shortNameController.text = company.shortName;
          _sloganController.text = company.slogan;
          _emailController.text = company.email;
          _addressController.text = company.address;
          _csPhoneController.text = company.csPhone;
        });
      }
    }
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
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        setState(() => _logoFile = picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear previous error
    final provider = context.read<CompanyProvider>();
    provider.clearError();

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'short-name': _shortNameController.text.trim(),
      'slogan': _sloganController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'cs-phone': _csPhoneController.text.trim(),
    };

    // Hanya tambahkan logo jika ada file baru yang dipilih
    if (_logoFile != null) {
      data['logo'] = _logoFile;
    }

    try {
      final success = await provider.saveCompany(data);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data perusahaan berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Gagal menyimpan data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Detail Perusahaan'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CompanyProvider>(
        builder: (context, provider, child) {
          // Tampilkan loading indicator saat pertama kali load
          if (provider.state == CompanyState.loading && provider.company == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Column(
            children: [
              Expanded(
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
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildLogoWidget(provider),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Perusahaan',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Nama perusahaan wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _shortNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Singkat',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Nama singkat wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _sloganController,
                            decoration: const InputDecoration(
                              labelText: 'Slogan',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email wajib diisi';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _addressController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Alamat',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _csPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Nomor CS',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Nomor CS wajib diisi' : null,
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
                              onPressed: provider.isSubmitting ? null : _save,
                              child: provider.isSubmitting
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                                  : Text(provider.company == null ? 'Buat Profil' : 'Perbarui Profil'),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogoWidget(CompanyProvider provider) {
    Widget image;

    if (_logoFile != null) {
      // Tampilkan gambar baru yang dipilih user
      image = Image.file(
        File(_logoFile!.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (provider.company?.logo != null && provider.company!.logo!.isNotEmpty) {
      // Tampilkan logo existing dari server
      image = Image.network(
        provider.company!.logo!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.business, size: 50, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    } else {
      // Placeholder jika belum ada logo
      image = Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.business, size: 50, color: Colors.grey),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickLogo,
          icon: const Icon(Icons.photo_camera),
          label: const Text('Pilih Logo'),
        ),
        if (_logoFile != null)
          TextButton(
            onPressed: () => setState(() => _logoFile = null),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }
}