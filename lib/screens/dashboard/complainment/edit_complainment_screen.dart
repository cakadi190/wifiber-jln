import 'package:flutter/material.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';

class EditComplaintScreen extends StatefulWidget {
  const EditComplaintScreen({super.key});

  @override
  State<EditComplaintScreen> createState() => _EditComplaintScreenState();
}

class _EditComplaintScreenState extends State<EditComplaintScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Variables untuk menyimpan data form
  String? selectedUser;
  String? complaintDescription;
  DateTime? selectedDate;

  // Dummy data untuk user target
  final List<String> userTargets = [
    'Admin Jaringan',
    'Teknisi Lapangan',
    'Customer Service',
    'Supervisor',
    'Manager IT',
  ];

  // Function untuk menampilkan modal bottom sheet
  void _showUserTargetModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // Handle bar untuk drag
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pilih Pelanggan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Cari Pelanggan',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...userTargets.map((user) {
                            return ListTile(
                              title: Text(user),
                              leading: const Icon(Icons.person),
                              onTap: () {
                                setState(() {
                                  selectedUser = user;
                                });
                                Navigator.pop(context);
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Function untuk menampilkan date picker
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

  // Function untuk format tanggal
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

                            // User Target Selection
                            const Text(
                              'Pelanggan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _showUserTargetModal,
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
                                      selectedUser ?? 'Pilih Pelanggan',
                                      style: TextStyle(
                                        color: selectedUser != null
                                            ? Colors.black
                                            : Colors.grey.shade600,
                                        fontSize: 16,
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

                            // Topic / Description of Complaint
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

                            // Date Picker
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

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Validasi form nanti ditambahkan
                                  if (selectedUser != null &&
                                      complaintDescription != null &&
                                      complaintDescription!.isNotEmpty &&
                                      selectedDate != null) {
                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Pengaduan berhasil dibuat!',
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
