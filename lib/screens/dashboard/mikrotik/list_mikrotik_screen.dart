import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/screens/dashboard/mikrotik/add_mikrotik_screen.dart';
import 'package:wifiber/providers/router_provider.dart';
import 'package:wifiber/models/router.dart';

class ListMikrotikScreen extends StatefulWidget {
  const ListMikrotikScreen({super.key});

  @override
  State<ListMikrotikScreen> createState() => _ListMikrotikScreenState();
}

class _ListMikrotikScreenState extends State<ListMikrotikScreen> {
  @override
  void initState() {
    super.initState();
    // Load data saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouterProvider>().getAllRouters();
    });
  }

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
          backgroundColor: AppColors.primary,
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddMikrotikScreen(),
              ),
            );

            // Refresh list setelah menambah router baru
            if (result == true) {
              if (mounted) {
                context.read<RouterProvider>().refresh();
              }
            }
          },
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text('MikroTik'),
          actions: [
            Consumer<RouterProvider>(
              builder: (context, provider, child) {
                return PopupMenuButton<String>(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<String>(
                        onTap: () => _toggleAllAutoIsolate(true),
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
                        onTap: () => _toggleAllAutoIsolate(false),
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
                );
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
          child: Consumer<RouterProvider>(
            builder: (context, provider, child) {
              return RefreshIndicator(
                onRefresh: () => provider.refresh(),
                child: _buildBody(provider),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(RouterProvider provider) {
    switch (provider.state) {
      case RouterState.loading:
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );

      case RouterState.error:
        return _buildErrorState(provider);

      case RouterState.success:
      case RouterState.initial:
        return _buildRouterList(provider);
    }
  }

  Widget _buildErrorState(RouterProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              provider.clearError();
              provider.getAllRouters();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildRouterList(RouterProvider provider) {
    if (provider.routers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.router,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada router MikroTik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tambahkan router pertama Anda',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.routers.length,
      itemBuilder: (context, index) {
        final router = provider.routers[index];
        return _buildRouterTile(router, provider);
      },
    );
  }

  Widget _buildRouterTile(RouterModel router, RouterProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRouterDetails(router),
        onLongPress: () => _showActionBottomSheet(router, provider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getStatusColor(router.status),
                child: const Icon(
                  Icons.router,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      router.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'IP: ${router.ip}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Host: ${router.host}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip(router.status),
                        const SizedBox(width: 8),
                        _buildActionChip(router.action),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.more_vert,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
        color = Colors.green;
        label = 'Aktif';
        break;
      case 'inactive':
      case 'offline':
        color = Colors.red;
        label = 'Tidak Aktif';
        break;
      default:
        color = Colors.orange;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionChip(String action) {
    Color color;
    String label;

    switch (action.toLowerCase()) {
      case 'enable':
        color = Colors.blue;
        label = 'Auto-Isolir';
        break;
      case 'disable':
        color = Colors.grey;
        label = 'Nonaktif';
        break;
      default:
        color = Colors.orange;
        label = action;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
        return Colors.green;
      case 'inactive':
      case 'offline':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _handleMenuAction(String action, RouterModel router, RouterProvider provider) {
    switch (action) {
      case 'test':
        _testConnection(router, provider);
        break;
      case 'edit':
        _editRouter(router);
        break;
      case 'toggle_isolate':
        _toggleAutoIsolate(router, provider);
        break;
      case 'delete':
        _showDeleteConfirmation(router, provider);
        break;
    }
  }

  Future<void> _testConnection(RouterModel router, RouterProvider provider) async {
    try {
      final success = await provider.testRouterConnection(router.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success
                    ? 'Koneksi ke ${router.name} berhasil'
                    : 'Koneksi ke ${router.name} gagal'
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
        return 'Online';
      case 'inactive':
      case 'offline':
        return 'Offline';
      default:
        return status;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _editRouter(RouterModel router) {
    // Navigate to edit screen
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => EditMikrotikScreen(router: router),
    //   ),
    // );
  }

  Future<void> _toggleAutoIsolate(RouterModel router, RouterProvider provider) async {
    try {
      // Show dialog to get ppoeSecret
      final ppoeSecret = await _showPpoeSecretDialog();
      if (ppoeSecret == null || ppoeSecret.isEmpty) return;

      final newAction = router.action == 'enable' ? 'disable' : 'enable';
      final toggleModel = ToggleRouterModel(
        ppoeSecret: ppoeSecret,
        routerId: router.id.toString(),
        action: newAction,
      );

      final success = await provider.toggleAutoIsolate(router.id, toggleModel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success
                    ? 'Auto-isolir ${router.name} ${newAction == 'enable' ? 'diaktifkan' : 'dinonaktifkan'}'
                    : 'Gagal mengubah pengaturan auto-isolir'
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showPpoeSecretDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PPPoE Secret'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Masukkan PPPoE Secret',
            hintText: 'contoh: user123',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(RouterModel router, RouterProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Router'),
        content: Text('Apakah Anda yakin ingin menghapus router "${router.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRouter(router, provider);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRouter(RouterModel router, RouterProvider provider) async {
    try {
      final success = await provider.deleteRouter(router.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success
                    ? 'Router ${router.name} berhasil dihapus'
                    : 'Gagal menghapus router ${router.name}'
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRouterDetails(RouterModel router) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _getStatusColor(router.status),
                        child: const Icon(
                          Icons.router,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              router.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildStatusChip(router.status),
                                const SizedBox(width: 8),
                                _buildActionChip(router.action),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Details Section
                  _buildDetailSection('Informasi Dasar', [
                    _buildDetailItem(Icons.computer, 'Nama Router', router.name),
                    _buildDetailItem(Icons.language, 'Alamat IP', router.ip),
                    _buildDetailItem(Icons.dns, 'Host', router.host),
                    _buildDetailItem(Icons.access_time, 'Toleransi Hari', '${router.toleranceDays} hari'),
                  ]),

                  const SizedBox(height: 24),

                  _buildDetailSection('Status & Konfigurasi', [
                    _buildDetailItem(
                      Icons.circle,
                      'Status Koneksi',
                      _getStatusDisplayText(router.status),
                      statusColor: _getStatusColor(router.status),
                    ),
                    _buildDetailItem(
                      router.action == 'enable' ? Icons.security : Icons.visibility,
                      'Auto-Isolir',
                      router.action == 'enable' ? 'Aktif' : 'Nonaktif',
                      statusColor: router.action == 'enable' ? Colors.blue : Colors.grey,
                    ),
                    if (router.isolirProfile.isNotEmpty)
                      _buildDetailItem(
                        Icons.shield,
                        'Profile Isolir',
                        router.isolirProfile,
                        statusColor: Colors.orange,
                      ),
                  ]),

                  const SizedBox(height: 24),

                  _buildDetailSection('Informasi Sistem', [
                    _buildDetailItem(Icons.tag, 'Router ID', router.id.toString()),
                    _buildDetailItem(Icons.calendar_today, 'Dibuat', _formatDate(router.createdAt)),
                  ]),

                  const SizedBox(height: 32),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _testConnection(router, context.read<RouterProvider>());
                          },
                          icon: const Icon(Icons.network_check),
                          label: const Text('Test Koneksi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showActionBottomSheet(router, context.read<RouterProvider>());
                          },
                          icon: const Icon(Icons.more_horiz),
                          label: const Text('Aksi Lain'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {Color? statusColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: statusColor ?? Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showActionBottomSheet(RouterModel router, RouterProvider provider) {
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
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getStatusColor(router.status),
                    child: const Icon(
                      Icons.router,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          router.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          router.ip,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Items
            _buildActionItem(
              icon: Icons.network_check,
              title: 'Test Koneksi',
              subtitle: 'Cek status koneksi router',
              onTap: () {
                Navigator.pop(context);
                _testConnection(router, provider);
              },
            ),

            _buildActionItem(
              icon: Icons.edit,
              title: 'Edit Router',
              subtitle: 'Ubah pengaturan router',
              onTap: () {
                Navigator.pop(context);
                _editRouter(router);
              },
            ),

            _buildActionItem(
              icon: router.action == 'enable'
                  ? Icons.power_off
                  : Icons.power_settings_new,
              title: router.action == 'enable'
                  ? 'Deaktivasi Auto-Isolir'
                  : 'Aktivasi Auto-Isolir',
              subtitle: router.action == 'enable'
                  ? 'Matikan mode auto-isolir'
                  : 'Nyalakan mode auto-isolir',
              onTap: () {
                Navigator.pop(context);
                _toggleAutoIsolate(router, provider);
              },
            ),

            _buildActionItem(
              icon: Icons.delete,
              title: 'Hapus Router',
              subtitle: 'Hapus router dari daftar',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(router, provider);
              },
            ),

            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAllAutoIsolate(bool enable) {
    // Implement bulk toggle auto isolate
    final provider = context.read<RouterProvider>();
    final action = enable ? 'isolate' : 'monitor';

    // You can implement this by iterating through all routers
    // and calling toggleAutoIsolate for each one
  }
}