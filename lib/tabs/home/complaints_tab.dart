import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:wifiber/config/app_colors.dart';

class ComplaintsTab extends StatefulWidget {
  const ComplaintsTab({super.key});

  @override
  State<ComplaintsTab> createState() => _ComplaintsTabState();
}

class _ComplaintsTabState extends State<ComplaintsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(title: const Text('Pengaduan & Keluhan'), actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {},
        ),
      ]),
      body: const Center(child: Text('Halaman Pengaduan & Keluhan')),
    );
  }
}
