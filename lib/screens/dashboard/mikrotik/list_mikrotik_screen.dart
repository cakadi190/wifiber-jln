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
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text('MikroTik'),
          actions: [
            PopupMenuButton<String>(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    onTap: () {},
                    child: Row(
                      children: const [
                        Icon(
                          Icons.power_settings_new,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text('Aktivasi Auto-Isolir'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {},
                    child: Row(
                      children: const [
                        Icon(
                          Icons.power_off,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text('Deaktivasi Auto-Isolir'),
                      ],
                    ),
                  ),
                ];
              },
            ),
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
          child: const Center(child: Text('List Mikrotik')),
        ),
      ),
    );
  }
}
