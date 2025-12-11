import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/components/reusables/options_bottom_sheet.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/router.dart';
import 'package:wifiber/models/router_pppoe.dart';
import 'package:wifiber/providers/router_provider.dart';
import 'package:wifiber/screens/dashboard/mikrotik/monitor_mikrotik_screen.dart';
import 'package:wifiber/screens/dashboard/mikrotik/widgets/mikrotik_form_sheet.dart';
import 'package:wifiber/screens/dashboard/mikrotik/widgets/monitor_login_sheet.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';

class ListMikrotikScreen extends StatefulWidget {
  const ListMikrotikScreen({super.key});

  @override
  State<ListMikrotikScreen> createState() => _ListMikrotikScreenState();
}

class _ListMikrotikScreenState extends State<ListMikrotikScreen> {
  @override
  void initState() {
    super.initState();

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
      child: AuthGuard(
        requiredPermissions: const ['integration'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          floatingActionButton: PermissionWidget(
            permissions: const ['integration'],
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () async {
                await _openMikrotikForm();
              },
              child: const Icon(Icons.add),
            ),
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
      ),
    );
  }

  Widget _buildBody(RouterProvider provider) {
    switch (provider.state) {
      case RouterState.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
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
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            "Ada kesalahan pada sistem, coba muat ulang lagi beberapa saat.",
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              provider.clearError();
              provider.getAllRouters();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
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
            Icon(Icons.router, size: 64, color: Colors.grey),
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
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: provider.routers.length,
      itemBuilder: (context, index) {
        final router = provider.routers[index];
        return _buildRouterTile(router, provider);
      },
    );
  }

  Widget _buildRouterTile(RouterModel router, RouterProvider provider) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                child: const Icon(Icons.router, color: Colors.white),
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
                      router.host,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showActionBottomSheet(router, provider),
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
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
      return DateHelper.formatDate(DateTime.parse(dateString), format: 'full');
    } catch (e) {
      return dateString;
    }
  }

  void _editRouter(RouterModel router) {
    _openMikrotikForm(router: router);
  }

  void _showDeleteConfirmation(RouterModel router, RouterProvider provider) {
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

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hapus Router',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apakah Anda yakin ingin menghapus router "${router.name}"?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tindakan ini tidak dapat dibatalkan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteRouter(router, provider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ya, Hapus Router',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRouter(
    RouterModel router,
    RouterProvider provider,
  ) async {
    try {
      final success = await provider.deleteRouter(router.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Router ${router.name} berhasil dihapus'
                  : 'Gagal menghapus router ${router.name}',
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
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,

          snap: true,

          snapSizes: const [0.4, 0.6, 0.8],

          builder: (context, scrollController) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.jumpTo(0);
              }
            });

            return SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),

              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {},

                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    _buildDetailSection('Informasi Dasar', [
                      _buildDetailItem(
                        Icons.computer,
                        'Nama Router',
                        router.name,
                      ),
                      _buildDetailItem(Icons.dns, 'Host', router.host),
                      _buildDetailItem(
                        Icons.access_time,
                        'Toleransi Keterlambatan',
                        '${router.toleranceDays} hari',
                      ),
                    ]),

                    const SizedBox(height: 24),

                    _buildDetailSection('Status & Konfigurasi', [
                      _buildDetailItem(
                        Icons.circle,
                        'Status Auto-Isolir',
                        _getStatusDisplayText(router.status),
                        statusColor: _getStatusColor(router.status),
                      ),
                      _buildDetailItem(
                        router.action == 'enable'
                            ? Icons.security
                            : Icons.visibility,
                        'Auto-Isolir',
                        router.action == 'enable' ? 'Aktif' : 'Nonaktif',
                        statusColor: router.action == 'enable'
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      if (router.isolirProfile.isNotEmpty)
                        _buildDetailItem(
                          Icons.shield,
                          'Profil Isolir',
                          router.isolirProfile,
                        ),
                    ]),

                    const SizedBox(height: 24),

                    _buildDetailSection('Informasi Sistem', [
                      _buildDetailItem(
                        Icons.tag,
                        'Router ID',
                        router.id.toString(),
                      ),
                      _buildDetailItem(
                        Icons.calendar_today,
                        'Dibuat',
                        _formatDate(router.createdAt),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showPppoeData(router),
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Lihat Data PPPoE Terhubung'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Tutup'),
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
                              _showActionBottomSheet(
                                router,
                                context.read<RouterProvider>(),
                              );
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

                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPppoeData(RouterModel router) {
    final pppoeFuture = context.read<RouterProvider>().fetchRouterPppoes(
      router.id,
    );

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
          initialChildSize: 1,
          minChildSize: 0.5,
          maxChildSize: 1,
          expand: false,
          builder: (context, scrollController) {
            return DefaultTabController(
              length: 2,
              child: FutureBuilder<RouterPppoeSecrets>(
                future: pppoeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildPppoeError(
                      context,
                      scrollController,
                      snapshot.error.toString(),
                      router,
                    );
                  }

                  final data = snapshot.data;
                  if (data == null) {
                    return _buildPppoeError(
                      context,
                      scrollController,
                      'Data PPPoE tidak tersedia.',
                      router,
                    );
                  }

                  return _buildPppoeContent(
                    context,
                    scrollController,
                    router,
                    data,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPppoeContent(
    BuildContext sheetContext,
    ScrollController scrollController,
    RouterModel router,
    RouterPppoeSecrets data,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'PPPoe Terhubung',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                router.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              _buildPppoeSummary(data),
            ],
          ),
        ),

        TabBar(
          indicatorColor: AppColors.primary,
          dividerColor: Colors.grey.shade300,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Tidak Aktif'),
          ],
        ),

        const SizedBox(height: 12),

        Expanded(
          child: TabBarView(
            children: [
              _buildPppoeSection(
                title: 'PPPoe Aktif (${data.activeList.length})',
                secrets: data.activeList,
                isActive: true,
              ),
              _buildPppoeSection(
                title: 'PPPoe Tidak Aktif (${data.inactiveList.length})',
                secrets: data.inactiveList,
                isActive: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPppoeError(
    BuildContext sheetContext,
    ScrollController scrollController,
    String message,
    RouterModel router,
  ) {
    String titleContainer = 'Gagal Memuat Data PPPoE';
    String messageContainer = 'Gagal memuat data PPPoE';

    if (message.contains('No route to host')) {
      titleContainer = 'Gagal Memuat Data PPPoE';
      messageContainer =
          'Anda tidak terhubung ke internet. Pastikan koneksi internet Anda terhubung dengan benar.';
    } else if (message.contains('Connection refused') ||
        message.contains('Failed host lookup')) {
      titleContainer = 'Koneksi Ditolak';
      messageContainer =
          'Koneksi ke Mikrotik ditolak atau host tidak dapat ditemukan. Pastikan Mikrotik menyala dan dapat diakses.';
    } else if (message.contains('Timeout')) {
      titleContainer = 'Waktu Habis';
      messageContainer =
          'Permintaan ke Mikrotik melebihi batas waktu. Periksa koneksi jaringan Anda atau status Mikrotik.';
    } else if (message.contains('500')) {
      titleContainer = 'Internal Server Error';
      messageContainer =
          'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
    } else if (message.contains('404')) {
      titleContainer = 'Not Found';
      messageContainer = 'Data yang Anda cari tidak ditemukan.';
    } else if (message.contains('401')) {
      titleContainer = 'Unauthorized';
      messageContainer = 'Anda tidak memiliki izin untuk mengakses data ini.';
    } else if (message.contains('403')) {
      titleContainer = 'Forbidden';
      messageContainer = 'Anda tidak memiliki izin untuk mengakses data ini.';
    }

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 40,
          bottom: 24 + MediaQuery.of(sheetContext).padding.bottom,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              titleContainer,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              messageContainer,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showPppoeData(router);
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPppoeSummary(RouterPppoeSecrets data) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.link,
            color: Colors.green,
            title: 'Aktif',
            value: data.activeList.length.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.link_off,
            color: Colors.orange,
            title: 'Tidak Aktif',
            value: data.inactiveList.length.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        color: color.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPppoeSection({
    required String title,
    required List<RouterPppoeSecret> secrets,
    required bool isActive,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (secrets.isEmpty)
              _buildPppoeEmptyState(
                isActive
                    ? 'Tidak ada PPPoE aktif saat ini.'
                    : 'Tidak ada PPPoE nonaktif.',
              )
            else
              ...secrets.map(
                (secret) => _buildPppoeCard(secret, isActive: isActive),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPppoeEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildPppoeCard(RouterPppoeSecret secret, {required bool isActive}) {
    final statusColor = isActive ? Colors.green : Colors.orange;
    final pppoeDisconnectReasonMapping = {
      'hung-up': 'Terputus',
      'lost-carrier': 'Carrier Hilang',
      'loss-connection': 'Koneksi Hilang',
      'peer-hung-up': 'Peer Memutus Koneksi',
      'ppp-timeout': 'PPP Timeout',
      'authentication-failure': 'Gagal Autentikasi',
      'no-response': 'Tidak Ada Respons',
      'terminated': 'Dihentikan',
      'session-limit': 'Batas Sesi Tercapai',
      'service-unavailable': 'Layanan Tidak Tersedia',
      'peer-initiated': 'Diputus dari Client',
      'server-initiated': 'Diputus dari Server',
      'radius-timeout': 'RADIUS Timeout',
      'radius-reject': 'RADIUS Menolak Login',
      'disconnect-request': 'Diminta Disconnect',
      'profile-change': 'Profil Berubah',
      'idle-timeout': 'Idle Timeout',
      'connect-failed': 'Koneksi Gagal',
      'authentication-timeout': 'Timeout Autentikasi',
      'unknown': 'Tidak Dikenali',
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  secret.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPppoeInfoRow('Profil', secret.profile),
          _buildPppoeInfoRow('ID Pemanggil', secret.callerId),
          if (isActive)
            _buildPppoeInfoRow('Uptime', _formatUptime(secret.uptime))
          else
            _buildPppoeInfoRow('Terakhir Keluar', secret.lastLoggedOut),
          _buildPppoeInfoRow(
            'Alasan Terputus',
            pppoeDisconnectReasonMapping[secret.lastDisconnectReason] ??
                secret.lastDisconnectReason,
          ),
          _buildPppoeInfoRow('Alamat Mac Terakhir', secret.lastCallerId),
        ],
      ),
    );
  }

  String? _formatUptime(String? uptime) {
    if (uptime == null || uptime.isEmpty) return null;

    final regex = RegExp(r'(\d+)([wdhms])');
    final matches = regex.allMatches(uptime);

    if (matches.isEmpty) return uptime;

    final parts = <String>[];
    for (final match in matches) {
      final value = match.group(1)!;
      final unit = match.group(2)!;

      switch (unit) {
        case 'w':
          parts.add('$value minggu');
          break;
        case 'd':
          parts.add('$value hari');
          break;
        case 'h':
          parts.add('$value jam');
          break;
        case 'm':
          parts.add('$value menit');
          break;
        case 's':
          parts.add('$value detik');
          break;
      }
    }

    return parts.join(' ');
  }

  Widget _buildPppoeInfoRow(String label, String? value) {
    if (!_isValueAvailable(value)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value!, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  bool _isValueAvailable(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed == '0') return false;
    if (trimmed == '1970-01-01 00:00:00') return false;
    return true;
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
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    Color? statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: statusColor ?? Colors.grey[600]),
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
    showOptionModalBottomSheet(
      context: context,
      header: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getStatusColor(router.status),
            child: const Icon(Icons.router, color: Colors.white),
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
              ],
            ),
          ),
        ],
      ),
      items: [
        OptionMenuItem(
          icon: Icons.edit,
          title: 'Edit Router',
          subtitle: 'Ubah pengaturan router',
          onTap: () {
            Navigator.pop(context);
            _editRouter(router);
          },
        ),
        OptionMenuItem(
          icon: Icons.router,
          title: 'Koneksi PPPoE',
          subtitle: 'Lihat data PPPoE yang terhubung',
          onTap: () {
            Navigator.pop(context);
            _showPppoeData(router);
          },
        ),
        OptionMenuItem(
          icon: Icons.wifi,
          title: 'Monitor Jaringan',
          subtitle: 'Pantau jaringan router ini',
          onTap: () {
            Navigator.pop(context);
            _showLoginToMonitor(router);
          },
        ),
        OptionMenuItem(
          icon: Icons.delete,
          title: 'Hapus Router',
          subtitle: 'Hapus router dari daftar',
          isDestructive: true,
          onTap: () {
            Navigator.pop(context);
            _showDeleteConfirmation(router, provider);
          },
        ),
      ],
    );
  }

  Future<void> _showLoginToMonitor(RouterModel router) async {
    final result = await showModalBottomSheet<MonitorLoginResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MonitorLoginSheet(router: router),
    );

    if (!mounted || result == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MonitorMikrotikScreen(
          router: router,
          client: result.client,
          username: result.username,
          port: result.port,
          useSsl: result.useSsl,
        ),
      ),
    );
  }

  void _toggleAllAutoIsolate(bool enable) {
    final provider = context.read<RouterProvider>();
    final action = enable ? 'active' : 'inactive';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: enable ? Colors.green.shade50 : Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  enable ? Icons.wifi_protected_setup : Icons.wifi_off,
                  size: 32,
                  color: enable
                      ? Colors.green.shade600
                      : Colors.orange.shade600,
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  enable
                      ? 'Aktifkan Auto-Isolir untuk semua router?'
                      : 'Nonaktifkan Auto-Isolir untuk semua router?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  enable
                      ? 'Fitur ini akan mengaktifkan isolasi otomatis pada semua perangkat router yang terhubung'
                      : 'Fitur isolasi otomatis akan dinonaktifkan pada semua perangkat router',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: enable
                              ? Colors.green.shade600
                              : Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: enable
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                        ),
                        onPressed: () {
                          provider.toggleAllAutoIsolate(action);
                          provider.getAllRouters();
                          Navigator.pop(context);

                          if (enable) {
                            SnackBars.success(
                              context,
                              'Auto-Isolir berhasil diaktifkan untuk semua router',
                            );
                          } else {
                            SnackBars.success(
                              context,
                              'Auto-Isolir berhasil dinonaktifkan untuk semua router',
                            );
                          }
                        },
                        child: Text(
                          enable ? 'Ya, Aktifkan' : 'Ya, Nonaktifkan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openMikrotikForm({RouterModel? router}) async {
    final provider = context.read<RouterProvider>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MikrotikFormSheet(router: router),
    );

    if (result == true) {
      await provider.refresh();
    }
  }
}
