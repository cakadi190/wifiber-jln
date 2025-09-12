import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/models/area.dart';
import 'package:wifiber/providers/area_provider.dart';

class AreaFormScreen extends StatefulWidget {
  final AreaModel? area;
  const AreaFormScreen({super.key, this.area});

  @override
  State<AreaFormScreen> createState() => _AreaFormScreenState();
}

class _AreaFormScreenState extends State<AreaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _status = 'active';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final area = widget.area;
    if (area != null) {
      _codeController.text = area.code;
      _nameController.text = area.name;
      _descController.text = area.description ?? '';
      _status = area.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.area != null;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(title: Text(isEdit ? 'Edit Area' : 'Tambah Area')),
      body: Container(
        padding: EdgeInsets.all(16),
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
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Kode'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Kode wajib diisi' : null,
              ),
              const SizedBox(height: 24),
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
              DropdownButtonFormField<String>(
                value: _status,
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
    );
  }

  Future<void> _save(BuildContext context) async {
    if (_formKey.currentState?.validate() != true) return;
    final data = {
      'code': _codeController.text,
      'name': _nameController.text,
      'description': _descController.text,
      'status': _status,
    };
    final provider = context.read<AreaProvider>();
    bool success;
    setState(() => _isSubmitting = true);
    if (widget.area == null) {
      success = await provider.addArea(data);
    } else {
      success = await provider.updateArea(widget.area!.id, data);
    }
    if (mounted) setState(() => _isSubmitting = false);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
