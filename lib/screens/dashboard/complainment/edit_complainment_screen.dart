import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/models/complaint.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/providers/complaint_provider.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';

class EditComplaintScreen extends StatefulWidget {
  const EditComplaintScreen({super.key, required this.complaint});

  final Complaint complaint;

  @override
  State<EditComplaintScreen> createState() => _EditComplaintScreenState();
}

class _EditComplaintScreenState extends State<EditComplaintScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController detailController;
  bool _isLoading = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    detailController = TextEditingController();
  }

  @override
  void dispose() {
    detailController.dispose();
    super.dispose();
  }

  void _onChanged(bool? value) {
    setState(() {
      _isDone = value ?? false;
    });
  }

  void _onSubmit() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final complaintProvider = Provider.of<ComplaintProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final response = await complaintProvider.updateComplaint(
          int.parse(widget.complaint.id),
          UpdateComplaint(
            id: int.parse(widget.complaint.id),
            detail: detailController.text,
            name: authProvider.user!.name,
            ticketIsDone: _isDone,
          ),
        );

        if (response) {
          SnackBars.success(
            context,
            "Berhasil menindaklanjuti laporan #${widget.complaint.number}!",
          ).clearSnackBars();
          Navigator.pop(context);
        } else {
          SnackBars.error(
            context,
            "Gagal menindaklanjuti laporan #${widget.complaint.number}! Coba lagi beberapa saat.",
          ).clearSnackBars();

          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        SnackBars.error(
          context,
          "Gagal menindaklanjuti laporan #${widget.complaint.number}! Coba lagi beberapa saat.",
        ).clearSnackBars();

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      child: AuthGuard(
        requiredPermissions: const ['ticket'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
          title: const Text('Tindak Lanjut Pengaduan'),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _onSubmit),
          ],
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
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: detailController,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan detail pembaruan tindak lanjut',
                            border: OutlineInputBorder(),
                            labelText: 'Detail tindak lanjut',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          maxLines: 8,
                          minLines: 3,
                          keyboardType: TextInputType.multiline,
                          enabled: !_isLoading,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Deskripsi pengaduan tidak boleh kosong';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Checkbox(
                              value: _isDone,
                              onChanged: _isLoading ? null : _onChanged,
                            ),
                            const Expanded(
                              child: Text(
                                'Tandai penanganannya sudah selesai',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.white),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Menyimpan...'),
                          ],
                        )
                      : const Text(
                          'Simpan Tindak Lanjut',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
