import 'package:flutter/material.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/widgets/customer_search_modal.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/complaint_tab_controller.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';

class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final ComplaintTabController _complaintController;

  Customer? selectedCustomer;
  String? complaintDescription;
  DateTime? selectedDate;
  bool _isLoading = false;

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
        return CustomerSearchModal(
          title: 'Pilih Pelanggan',
          selectedCustomer: selectedCustomer,
          onCustomerSelected: (customer) {
            setState(() {
              selectedCustomer = customer;
            });
          },
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) {
      _complaintController.showErrorMessage('Mohon lengkapi semua field!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _complaintController.addComplaint(
        subject: selectedCustomer!.customerId,
        topic: complaintDescription!,
        date: selectedDate!,
      );

      if (success) {
        _complaintController.showSuccessMessage(
          'Pengaduan untuk ${selectedCustomer!.name} berhasil dibuat!',
        );
        Navigator.pop(context, true);
      } else {
        _complaintController.showErrorMessage('Gagal membuat pengaduan!');
      }
    } catch (e) {
      _complaintController.showErrorMessage(
        'Terjadi kesalahan: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateForm() {
    return selectedCustomer != null &&
        complaintDescription != null &&
        complaintDescription!.trim().isNotEmpty &&
        selectedDate != null;
  }

  @override
  void initState() {
    super.initState();
    _complaintController = ComplaintTabController(context);
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.background,
        navigationBarColor: Colors.white,
      ),
      child: AuthGuard(
        requiredPermissions: const ['ticket'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
            title: const Text('Tambah Data Pengaduan'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          const Text(
                            'Pelanggan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _isLoading ? null : _showCustomerSearchModal,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _isLoading
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade300,
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
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Masukkan topik pengaduan',
                              border: OutlineInputBorder(),
                              labelText: 'Topik / Deskripsi Pengaduan',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            maxLines: 8,
                            minLines: 3,
                            keyboardType: TextInputType.multiline,
                            enabled: !_isLoading,
                            onChanged: (value) {
                              setState(() {
                                complaintDescription = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Deskripsi pengaduan tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Tanggal Pengaduan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _isLoading ? null : _selectDate,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _isLoading
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: _isLoading ? Colors.grey.shade50 : null,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedDate != null
                                        ? _formatDate(selectedDate!)
                                        : 'Pilih Tanggal',
                                    style: TextStyle(
                                      color: selectedDate != null
                                          ? Colors.black
                                          : Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: _isLoading
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isLoading
                                    ? Colors.grey.shade400
                                    : AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Buat Pengaduan',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
