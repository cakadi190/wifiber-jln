import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/components/widgets/customer_search_modal.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/bills.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/providers/bills_provider.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';

class BillsCreateScreen extends StatefulWidget {
  const BillsCreateScreen({super.key});

  @override
  State<BillsCreateScreen> createState() => _BillsCreateScreenState();
}

class _BillsCreateScreenState extends State<BillsCreateScreen>
    with BackendValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _paymentNoteController = TextEditingController();

  final _customerFieldKey = GlobalKey();
  final _periodFieldKey = GlobalKey();
  final _paymentMethodFieldKey = GlobalKey();
  final _paymentNoteFieldKey = GlobalKey();

  Customer? selectedCustomer;
  File? selectedPaymentProof;
  String? paymentProofFileName;

  final ImagePicker _picker = ImagePicker();

  bool _isPaid = false;
  bool _openIsolir = false;
  DateTime _paymentAt = DateTime.now();
  DateTime _selectedPeriod = DateTime.now();
  bool _isLoading = false;

  @override
  GlobalKey<FormState> get formKey => _formKey;

  @override
  void dispose() {
    _customerIdController.dispose();
    _paymentMethodController.dispose();
    _paymentNoteController.dispose();
    super.dispose();
  }

  Future<void> _selectPaymentDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _paymentAt) {
      setState(() {
        _paymentAt = picked;
      });
    }
  }

  Future<void> _selectPeriod() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPeriod,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Pilih Periode',
      fieldLabelText: 'Periode',
    );
    if (picked != null && picked != _selectedPeriod) {
      setState(() {
        _selectedPeriod = picked;
      });
    }
  }

  Future<void> _pickPaymentProofFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (!mounted) return;

      if (result != null) {
        setState(() {
          selectedPaymentProof = File(result.files.single.path!);
          paymentProofFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBars.error(
          context,
          "Gagal memilih berkas: ${e.toString()}",
        ).clearSnackBars();
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

      if (picked != null) {
        setState(() {
          selectedPaymentProof = File(picked.path);
          paymentProofFileName = picked.name;
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBars.error(
          context,
          "Gagal mengambil foto: ${e.toString()}",
        ).clearSnackBars();
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

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  String _formatPeriod(DateTime dateTime) {
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
    return "${months[dateTime.month - 1]} ${dateTime.year}";
  }

  String _getPeriodString(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}";
  }

  void _scrollToFirstError(Map<String, dynamic> errors) {
    final fieldKeys = {
      'customer_id': _customerFieldKey,
      'period': _periodFieldKey,
      'payment_method': _paymentMethodFieldKey,
      'payment_note': _paymentNoteFieldKey,
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

  String? _getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  Icon _getFileIcon(String fileName) {
    String? extension = _getFileExtension(fileName);
    switch (extension) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Icon(Icons.image, color: Colors.blue);
      default:
        return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  Future<void> _createBill() async {
    if (!_formKey.currentState!.validate()) return;

    clearBackendErrors();

    if (selectedCustomer == null) {
      SnackBars.error(
        context,
        "Silakan pilih pelanggan terlebih dahulu",
      ).clearSnackBars();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final billsProvider = context.read<BillsProvider>();

    final createBill = CreateBill(
      customerId: selectedCustomer!.customerId,
      period: _getPeriodString(_selectedPeriod),
      isPaid: _isPaid,
      openIsolir: _openIsolir,
      paymentMethod: _paymentMethodController.text.trim().isNotEmpty
          ? _paymentMethodController.text.trim()
          : null,
      paymentAt: _paymentAt,
      paymentProof: selectedPaymentProof,
      paymentNote: _paymentNoteController.text.trim().isNotEmpty
          ? _paymentNoteController.text.trim()
          : null,
    );

    try {
      final success = await billsProvider.createBill(createBill);

      if (success) {
        if (mounted) {
          final errorMsg = billsProvider.errorMessage;
          if (errorMsg.isNotEmpty && errorMsg.toLowerCase().contains('gagal')) {
            SnackBars.error(context, errorMsg).clearSnackBars();
          } else {
            SnackBars.success(
              context,
              'Tagihan berhasil dibuat!',
            ).clearSnackBars();
          }
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          final errorMsg = billsProvider.errorMessage;
          SnackBars.error(
            context,
            errorMsg.isNotEmpty
                ? errorMsg
                : 'Wah, Ada kesalahan waktu membuat tagihan!',
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
              : 'Wah, Ada kesalahan waktu membuat tagihan!',
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

  void _showCustomerSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          child: CustomerSearchModal(
            title: 'Pilih Pelanggan',
            selectedCustomer: selectedCustomer,
            onCustomerSelected: (customer) {
              setState(() {
                selectedCustomer = customer;
              });
            },
          ),
        );
      },
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
        requiredPermissions: const ['bill'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
            title: const Text('Buat Tagihan'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _createBill,
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
                      const Text(
                        'Pelanggan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        key: _customerFieldKey,
                        onTap: _isLoading ? null : _showCustomerSearchModal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: backendErrorFor('customer_id') != null
                                      ? Colors.red
                                      : _isLoading
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade300,
                                  width: backendErrorFor('customer_id') != null
                                      ? 2
                                      : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: _isLoading ? Colors.grey.shade50 : null,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedCustomer?.name ??
                                              'Pilih Pelanggan',
                                          style: TextStyle(
                                            color: selectedCustomer != null
                                                ? Colors.black
                                                : Colors.grey.shade600,
                                            fontSize: 16,
                                            fontWeight: selectedCustomer != null
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        if (selectedCustomer != null)
                                          Text(
                                            selectedCustomer!.phone,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: _isLoading
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                            if (backendErrorFor('customer_id') != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 12,
                                ),
                                child: Text(
                                  backendErrorFor('customer_id')!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Periode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        key: _periodFieldKey,
                        builder: (context) {
                          final periodError = backendErrorFor('period');
                          return InkWell(
                            onTap: _selectPeriod,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: periodError != null
                                          ? Colors.red
                                          : Colors.grey.shade300,
                                      width: periodError != null ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatPeriod(_selectedPeriod),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_month,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                if (periodError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 12,
                                    ),
                                    child: Text(
                                      periodError,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Tanggal Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectPaymentDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(_paymentAt),
                                style: const TextStyle(color: Colors.black87),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sudah Dibayar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Switch(
                            value: _isPaid,
                            onChanged: (value) {
                              setState(() {
                                _isPaid = value;
                              });
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Buka Isolir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Switch(
                            value: _openIsolir,
                            onChanged: (value) {
                              setState(() {
                                _openIsolir = value;
                              });
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
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
                        decoration: InputDecoration(
                          hintText: 'Contoh: Transfer Bank, Tunai, QRIS',
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
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: validator('payment_method'),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Bukti Pembayaran (Opsional)',
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
                                    onPressed: _removePaymentProofFile,
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
                                  color: Colors.grey.shade50,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Pilih File Bukti Pembayaran',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                      const SizedBox(height: 8),
                      Text(
                        'Format yang didukung: JPG, JPEG, PNG, PDF (Maks. 5MB)',
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
                        key: _paymentNoteFieldKey,
                        controller: _paymentNoteController,
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
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: validator('payment_note'),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createBill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                  'Buat Tagihan',
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
