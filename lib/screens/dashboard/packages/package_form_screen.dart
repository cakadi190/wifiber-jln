import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/models/package.dart';
import 'package:wifiber/providers/package_provider.dart';

class PackageFormScreen extends StatefulWidget {
  final PackageModel? package;
  const PackageFormScreen({super.key, this.package});

  @override
  State<PackageFormScreen> createState() => _PackageFormScreenState();
}

class _PackageFormScreenState extends State<PackageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ppnController = TextEditingController();
  String _status = 'active';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final pkg = widget.package;
    if (pkg != null) {
      _nameController.text = pkg.name;
      _descController.text = pkg.description ?? '';
      _priceController.text = pkg.price.toString();
      _ppnController.text = pkg.ppnPercent.toString();
      _status = pkg.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.package != null;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(title: Text(isEdit ? 'Edit Paket' : 'Tambah Paket')),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Harga'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Harga wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _ppnController,
                    decoration: const InputDecoration(labelText: 'PPN %'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'PPN wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Aktif')),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Tidak Aktif'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _status = v ?? 'active';
                      });
                    },
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
                      onPressed: _isSubmitting ? null : () => _save(context),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(isEdit ? 'Perbarui' : 'Simpan'),
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

  Future<void> _save(BuildContext context) async {
    if (_formKey.currentState?.validate() != true) return;
    final data = {
      'name': _nameController.text,
      'description': _descController.text,
      'price': _priceController.text,
      'ppn_percentage': _ppnController.text,
      'status': _status,
    };
    final provider = context.read<PackageProvider>();
    final navigator = Navigator.of(context);
    bool success;
    setState(() => _isSubmitting = true);
    if (widget.package == null) {
      success = await provider.addPackage(data);
    } else {
      success = await provider.updatePackage(widget.package!.id, data);
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (success) {
      navigator.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _ppnController.dispose();
    super.dispose();
  }
}
