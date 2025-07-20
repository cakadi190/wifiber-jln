import 'package:flutter/material.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';

class AddMikrotikScreen extends StatefulWidget {
  const AddMikrotikScreen({super.key});

  @override
  State<AddMikrotikScreen> createState() => _AddMikrotikScreenState();
}

class _AddMikrotikScreenState extends State<AddMikrotikScreen> {
  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(title: const Text('Tambah Mikrotik')),
      )
    );
  }
}