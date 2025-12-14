import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/models/transaction.dart';
import 'package:wifiber/providers/transaction_provider.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen>
    with BackendValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nominalController;
  late TextEditingController _descriptionController;
  late TextEditingController _createdByController;
  late TextEditingController _createdAtController;
  DateTime _createdAt = DateTime.now();
  String _type = 'income';
  bool _isLoading = false;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nominalController = TextEditingController(
      text: widget.transaction?.nominal.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _createdByController = TextEditingController(
      text: widget.transaction?.createdBy ?? '',
    );
    _createdAt = widget.transaction?.createdAt ?? DateTime.now();
    _createdAtController = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm:ss').format(_createdAt),
    );
    _type = widget.transaction?.type ?? 'income';
  }

  @override
  GlobalKey<FormState> get formKey => _formKey;

  @override
  void dispose() {
    _nominalController.dispose();
    _descriptionController.dispose();
    _createdByController.dispose();
    _createdAtController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _createdAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_createdAt),
    );
    if (time == null) return;
    if (!mounted) return;
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      _createdAt = selected;
      _createdAtController.text = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(selected);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _imageFile = picked);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Ambil dengan Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    clearBackendErrors();
    setState(() => _isLoading = true);
    final provider = context.read<TransactionProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final nominal = int.parse(_nominalController.text.trim());
      final description = _descriptionController.text.trim();
      final createdBy = _createdByController.text.trim();
      final imageFile = _imageFile != null ? File(_imageFile!.path) : null;

      if (widget.transaction == null) {
        await provider.addTransaction(
          nominal: nominal,
          description: description,
          type: _type,
          createdAt: _createdAt,
          createdBy: createdBy,
          image: imageFile,
        );
      } else {
        await provider.updateTransaction(
          widget.transaction!.id,
          nominal: nominal,
          description: description,
          type: _type,
          createdAt: _createdAt,
          createdBy: createdBy,
          image: imageFile,
        );
      }

      if (!mounted) return;
      navigator.pop(true);
    } on ValidationException catch (e) {
      if (!mounted) return;
      setBackendErrors(e.errors);
      messenger.showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Ubah Transaksi Keuangan' : 'Tambah Transaksi Keuangan',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: constraints.maxHeight.isFinite
                  ? BoxConstraints(minHeight: constraints.maxHeight)
                  : const BoxConstraints(),
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nominalController,
                        decoration: const InputDecoration(
                          labelText: 'Nominal',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: validator('nominal', (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nominal belum diisi';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Nominal harus berupa angka';
                          }
                          return null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: validator('description', (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi belum diisi';
                          }
                          return null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _createdByController,
                        decoration: const InputDecoration(
                          labelText: 'Dibuat Oleh',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: validator('created_by', (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pembuat belum diisi';
                          }
                          return null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _createdAtController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: validator('created_at'),
                        onTap: _selectDateTime,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _showImagePicker,
                        icon: const Icon(Icons.image),
                        label: Text(
                          _imageFile != null
                              ? _imageFile!.name
                              : 'Pilih Gambar (opsional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(
                          labelText: 'Jenis',
                          prefixIcon: Icon(Icons.swap_vert),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'income',
                            child: Text('Pemasukan'),
                          ),
                          DropdownMenuItem(
                            value: 'expense',
                            child: Text('Pengeluaran'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _type = val);
                        },
                        validator: validator('type'),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(isEdit ? 'Perbarui' : 'Simpan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
