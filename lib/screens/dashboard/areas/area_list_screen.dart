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

                              return InkWell(
                                onLongPress: () => _showActionBottomSheet(area),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              area.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              area.code,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            _showActionBottomSheet(area),
                                        child: Icon(
                                          Icons.more_vert,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
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

  void _showActionBottomSheet(AreaModel area) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () => _openForm(context, area: area),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () => _delete(context, area.id),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {AreaModel? area}) {
    final mainContext = this.context;

    Navigator.pop(context);

    Future.delayed(Duration.zero, () {
      Navigator.of(mainContext)
          .push(MaterialPageRoute(builder: (_) => AreaFormScreen(area: area)))
          .then((_) => mainContext.read<AreaProvider>().loadAreas());
    });
  }

  Future<void> _delete(BuildContext context, String id) async {
    final mainContext = this.context;

    Navigator.pop(context);

    final confirmed = await showDialog<bool>(
      context: mainContext,
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
      await mainContext.read<AreaProvider>().deleteArea(id);
    }
  }
}
