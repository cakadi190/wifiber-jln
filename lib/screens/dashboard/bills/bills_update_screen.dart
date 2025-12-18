import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/bills.dart';
import 'package:wifiber/providers/bills_provider.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';
import 'package:wifiber/utils/file_picker_validator.dart';

class BillsUpdateScreen extends StatefulWidget {
  final Bills bill;

  const BillsUpdateScreen({super.key, required this.bill});

  @override
  State<BillsUpdateScreen> createState() => _BillsUpdateScreenState();
}

class _BillsUpdateScreenState extends State<BillsUpdateScreen>
    with BackendValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _paymentMethodController = TextEditingController();
  final _additionalNoteController = TextEditingController();

  final _paymentMethodFieldKey = GlobalKey();
  final _additionalNoteFieldKey = GlobalKey();

  File? selectedPaymentProof;
  String? paymentProofFileName;

  final ImagePicker _picker = ImagePicker();

  bool _openIsolir = false;
  DateTime _paymentAt = DateTime.now();
  bool _isLoading = false;

  @override
  GlobalKey<FormState> get formKey => _formKey;

  @override
  void initState() {
    super.initState();

    if (widget.bill.paymentMethod != null &&
        widget.bill.paymentMethod!.isNotEmpty) {
      _paymentMethodController.text = widget.bill.paymentMethod!;
    }
    if (widget.bill.paymentAt != null) {
      _paymentAt = widget.bill.paymentAt!;
    }
    if (widget.bill.additionalInfo != null &&
        widget.bill.additionalInfo!.isNotEmpty) {
      _additionalNoteController.text = widget.bill.additionalInfo!;
    }
  }

  @override
  void dispose() {
    _paymentMethodController.dispose();
    _additionalNoteController.dispose();
    super.dispose();
  }

  Future<void> _selectPaymentDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _paymentAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_paymentAt),
    );

    if (pickedTime != null) {
      setState(() {
        _paymentAt = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _pickPaymentProofFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (picked == null) {
        // User membatalkan pemilihan
        return;
      }

      // Validasi file menggunakan FilePickerValidator
      final xFile = XFile(picked.path);
      final validationResult = await FilePickerValidator.validate(
        xFile,
        FilePickerConfig.paymentProof,
      );

      if (!mounted) return;

      if (!validationResult.isValid) {
        // Tampilkan error dengan snackbar yang informatif
        validationResult.showErrorIfInvalid(context);
        return;
      }

      setState(() {
        selectedPaymentProof = File(picked.path);
        paymentProofFileName = picked.name;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gagal memilih berkas: ${e.toString().replaceAll('Exception: ', '')}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
      }
    }
  }

  Future<void> _capturePaymentProofWithCamera() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (picked == null) {
        // User membatalkan pemilihan
        return;
      }

      // Validasi file menggunakan FilePickerValidator
      final xFile = XFile(picked.path);
      final validationResult = await FilePickerValidator.validate(
        xFile,
        FilePickerConfig.paymentProof,
      );

      if (!mounted) return;

      if (!validationResult.isValid) {
        // Tampilkan error dengan snackbar yang informatif
        validationResult.showErrorIfInvalid(context);
        return;
      }

      setState(() {
        selectedPaymentProof = File(picked.path);
        paymentProofFileName = picked.name;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gagal mengambil foto: ${e.toString().replaceAll('Exception: ', '')}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
      }
    }
  }

  void _showPaymentProofPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPaymentProofFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Ambil dengan Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _capturePaymentProofWithCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removePaymentProofFile() {
    setState(() {
      selectedPaymentProof = null;
      paymentProofFileName = null;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String _formatPeriod(String period) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    try {
      // Period format: YYYY-MM
      final parts = period.split('-');
      if (parts.length == 2) {
        final year = parts[0];
        final monthIndex = int.parse(parts[1]) - 1;
        if (monthIndex >= 0 && monthIndex < 12) {
          return 'bulan ${months[monthIndex]} $year';
        }
      }
    } catch (e) {
      // Fallback jika parsing gagal
    }
    return period;
  }

  void _scrollToFirstError(Map<String, dynamic> errors) {
    final fieldKeys = {
      'payment_method': _paymentMethodFieldKey,
      'payment_at': _additionalNoteFieldKey,
    };

    for (final fieldName in errors.keys) {
      final key = fieldKeys[fieldName];
      if (key != null && key.currentContext != null) {
        final fieldContext = key.currentContext;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          if (fieldContext != null && fieldContext.mounted) {
            Scrollable.ensureVisible(
              fieldContext,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.2,
            );
          }
        });
        break;
      }
    }
  }

  Icon _getFileIcon(String fileName) {
    String? extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Icon(Icons.image, color: Colors.blue);
      default:
        return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  Future<void> _updateBill() async {
    if (!_formKey.currentState!.validate()) return;

    clearBackendErrors();

    setState(() {
      _isLoading = true;
    });

    final billsProvider = context.read<BillsProvider>();

    final updateBill = UpdateBill(
      paymentMethod: _paymentMethodController.text.trim().isNotEmpty
          ? _paymentMethodController.text.trim()
          : null,
      paymentAt: _paymentAt,
      paymentProof: selectedPaymentProof,
      additionalNote: _additionalNoteController.text.trim().isNotEmpty
          ? _additionalNoteController.text.trim()
          : null,
      openIsolir: _openIsolir,
    );

    try {
      final success = await billsProvider.updateBill(
        widget.bill.id,
        updateBill,
      );

      if (success) {
        if (mounted) {
          final errorMsg = billsProvider.errorMessage;
          if (errorMsg.isNotEmpty && errorMsg.toLowerCase().contains('gagal')) {
            SnackBars.error(context, errorMsg).clearSnackBars();
          } else {
            SnackBars.success(
              context,
              'Tagihan berhasil diperbarui!',
            ).clearSnackBars();
          }
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          final errorMsg = billsProvider.errorMessage;
          SnackBars.error(
            context,
            errorMsg.isNotEmpty
                ? errorMsg
                : 'Wah, Ada kesalahan waktu memperbarui tagihan!',
          ).clearSnackBars();
        }
      }
    } on SocketException catch (_) {
      if (mounted) {
        SnackBars.error(
          context,
          'Sepertinya ada masalah koneksi internet atau kamu tidak sedang terhubung ke internet?',
        ).clearSnackBars();
      }
    } on ValidationException catch (e) {
      setBackendErrors(e.errors);
      _scrollToFirstError(e.errors);
      if (mounted) {
        if (e.message.contains("validation error")) {
          SnackBars.error(
            context,
            "Terjadi kesalahan validasi. Silakan periksa form!",
          ).clearSnackBars();
        } else {
          SnackBars.error(context, e.message).clearSnackBars();
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBars.error(
          context,
          e.toString().contains('Internal server error')
              ? 'Terjadi kesalahan pada server. Silakan coba lagi.'
              : 'Wah, Ada kesalahan waktu memperbarui tagihan!',
        ).clearSnackBars();
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
        requiredPermissions: const ['bill'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
            title: const Text('Update Tagihan'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _updateBill,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
              ),
            ],
          ),
          body: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bill.invoice,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                            Text(
                              "a/n ${widget.bill.name} periode ${_formatPeriod(widget.bill.period)}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Metode Pembayaran (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: _paymentMethodFieldKey,
                        controller: _paymentMethodController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Gopay, Transfer Bank, Cash, dll',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: _isLoading
                              ? Colors.grey.shade50
                              : Colors.grey.shade50,
                        ),
                        validator: (value) {
                          final backendError = validator('payment_method')(
                            value,
                          );
                          if (backendError != null) {
                            return 'Metode pembayaran: $backendError';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Tanggal dan Waktu Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _isLoading ? null : _selectPaymentDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: _isLoading
                                ? Colors.grey.shade100
                                : Colors.grey.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDateTime(_paymentAt),
                                style: const TextStyle(color: Colors.black87),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: _isLoading
                                    ? Colors.grey.shade400
                                    : AppColors.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Bukti Pembayaran (Gambar)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      selectedPaymentProof != null
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.green.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.green.shade50,
                              ),
                              child: Row(
                                children: [
                                  _getFileIcon(paymentProofFileName!),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          paymentProofFileName!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Berkas terpilih',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _removePaymentProofFile,
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: _isLoading
                                  ? null
                                  : _showPaymentProofPicker,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: _isLoading
                                      ? Colors.grey.shade100
                                      : Colors.grey.shade50,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      color: _isLoading
                                          ? Colors.grey.shade400
                                          : AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Pilih Gambar Bukti Pembayaran',
                                      style: TextStyle(
                                        color: _isLoading
                                            ? Colors.grey.shade400
                                            : AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                      const SizedBox(height: 8),
                      Text(
                        'Format yang didukung: JPG, JPEG, PNG (Maks. 5MB)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Catatan Pembayaran (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: _additionalNoteFieldKey,
                        controller: _additionalNoteController,
                        enabled: !_isLoading,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Catatan tambahan untuk pembayaran',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: _isLoading
                              ? Colors.grey.shade50
                              : Colors.grey.shade50,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Buka Isolir Otomatis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Switch(
                            value: _openIsolir,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _openIsolir = value;
                                    });
                                  },
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateBill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Memproses...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Update Tagihan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
