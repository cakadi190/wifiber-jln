import 'package:flutter/material.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/models/complaint.dart';

class EditComplaintScreen extends StatefulWidget {
  const EditComplaintScreen({super.key, required this.complaint});

  final Complaint complaint;

  @override
  State<EditComplaintScreen> createState() => _EditComplaintScreenState();
}

class _EditComplaintScreenState extends State<EditComplaintScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Tindak Lanjut Pengaduan'),
          actions: [IconButton(icon: const Icon(Icons.save), onPressed: () {})],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
