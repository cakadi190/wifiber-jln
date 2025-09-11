import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/models/area.dart';
import 'package:wifiber/providers/area_provider.dart';
import 'package:wifiber/screens/dashboard/areas/area_form_screen.dart';

class AreaListScreen extends StatefulWidget {
  const AreaListScreen({super.key});

  @override
  State<AreaListScreen> createState() => _AreaListScreenState();
}

class _AreaListScreenState extends State<AreaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AreaProvider>().loadAreas();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: AuthGuard(
        requiredPermissions: const ['area'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(title: const Text('Area')),
          floatingActionButton: PermissionWidget(
            permissions: const ['customer'],
            child: FloatingActionButton(
              onPressed: () => _openForm(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              tooltip: 'Tambah Pelanggan',
              child: const Icon(Icons.add),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Consumer<AreaProvider>(
                    builder: (context, provider, child) {
                      if (provider.state == AreaState.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.state == AreaState.error) {
                        return Center(child: Text(provider.error ?? 'Error'));
                      }
                      final areas = provider.areas;
                      if (areas.isEmpty) {
                        return const Center(child: Text('Tidak ada data'));
                      }
                      return RefreshIndicator(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: ListView.builder(
                            itemCount: areas.length,
                            itemBuilder: (context, index) {
                              final AreaModel area = areas[index];
                              return ListTile(
                                title: Text(
                                  area.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(area.code),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () =>
                                          _openForm(context, area: area),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          _delete(context, area.id),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        onRefresh: () => provider.loadAreas(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {AreaModel? area}) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AreaFormScreen(area: area)))
        .then((_) => context.read<AreaProvider>().loadAreas());
  }

  Future<void> _delete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Area'),
        content: const Text('Yakin ingin menghapus area ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<AreaProvider>().deleteArea(id);
    }
  }
}
