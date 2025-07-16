import 'package:flutter/material.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';

class ListMikrotikScreen extends StatefulWidget {
  const ListMikrotikScreen({super.key});

  @override
  State<ListMikrotikScreen> createState() => _ListMikrotikScreenState();
}

class _ListMikrotikScreenState extends State<ListMikrotikScreen> {
  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(title: const Text('Daftar Mikrotik')),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: const Center(child: Text('List Mikrotik')),
        ),
      ),
    );
  }
}
