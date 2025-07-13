import 'package:flutter/material.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/widgets/customer_search_modal.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/customer.dart';

class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Customer? selectedCustomer;
  String? complaintDescription;
  DateTime? selectedDate;

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

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.background,
        navigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: const Text('Tambah Data Pengaduan'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
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
                              onTap: _showCustomerSearchModal,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
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
                                              fontWeight:
                                                  selectedCustomer != null
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
                                      color: Colors.grey.shade600,
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
                              maxLines: null,
                              minLines: 3,
                              keyboardType: TextInputType.multiline,
                              onChanged: (value) {
                                complaintDescription = value;
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
                              onTap: _selectDate,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
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
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (selectedCustomer != null &&
                                      complaintDescription != null &&
                                      complaintDescription!.isNotEmpty &&
                                      selectedDate != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Pengaduan untuk ${selectedCustomer!.name} berhasil dibuat!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Mohon lengkapi semua field!',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Buat Pengaduan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
