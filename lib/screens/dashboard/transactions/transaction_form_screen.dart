import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/models/transaction.dart';
import 'package:wifiber/providers/transaction_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String _type = 'income';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _type = widget.transaction?.type ?? 'income';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<TransactionProvider>();

    try {
      final amount = int.parse(_amountController.text.trim());
      final description = _descriptionController.text.trim();

      if (widget.transaction == null) {
        await provider.addTransaction(
          amount: amount,
          description: description,
          type: _type,
        );
      } else {
        await provider.updateTransaction(
          widget.transaction!.id,
          amount: amount,
          description: description,
          type: _type,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Transaksi' : 'Tambah Transaksi'),
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
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Nominal',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nominal belum diisi';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Nominal harus berupa angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi belum diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(
                          labelText: 'Jenis',
                          prefixIcon: Icon(Icons.swap_vert),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                          DropdownMenuItem(
                            value: 'expense',
                            child: Text('Pengeluaran'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _type = val);
                        },
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
                              ? const CircularProgressIndicator(color: Colors.white)
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
