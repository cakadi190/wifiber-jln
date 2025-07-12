import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/screens/dashboard/complainment/create_complainment_screen.dart';

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
      appBar: AppBar(
        title: const Text('Pengaduan & Keluhan'),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateComplaintScreen(),
            ),
          )
        })],
      ),
      body: Column(
        children: [
          _buildFilter(context),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(BuildContext context) {
    return Container();
  }
}
