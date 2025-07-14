import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(title: const Text('Daftar Tagihan')),
      body: Center(
        child: Text('Halaman Daftar Tagihan'),
      ),
    );
  }
}