import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/models/package.dart';
import 'package:wifiber/providers/package_provider.dart';
import 'package:wifiber/screens/dashboard/packages/package_form_screen.dart';
import 'package:wifiber/components/reusables/options_bottom_sheet.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PackageProvider>().loadPackages();
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
        requiredPermissions: const ['package'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(title: const Text('Paket')),
          floatingActionButton: PermissionWidget(
            permissions: const ['package'],
            child: FloatingActionButton(
              onPressed: () => _openForm(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              tooltip: 'Tambah Paket',
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
                  child: Consumer<PackageProvider>(
                    builder: (context, provider, child) {
                      if (provider.state == PackageState.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.state == PackageState.error) {
                        return Center(child: Text(provider.error ?? 'Error'));
                      }
                      final packages = provider.packages;
                      if (packages.isEmpty) {
                        return const Center(child: Text('Tidak ada data'));
                      }
                      return RefreshIndicator(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListView.builder(
                            itemCount: packages.length,
                            itemBuilder: (context, index) {
                              final PackageModel pkg = packages[index];

                              return InkWell(
                                onLongPress: () => _showActionBottomSheet(pkg),
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
                                              pkg.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Rp ${_formatPrice(pkg.price)}',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (pkg.description != null &&
                                                pkg
                                                    .description!
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                pkg.description!,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            _showActionBottomSheet(pkg),
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
                        onRefresh: () => provider.loadPackages(),
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

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    // Format angka dengan pemisah ribuan
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showActionBottomSheet(PackageModel pkg) {
    showOptionModalBottomSheet(
      context: context,
      header: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.inventory_2, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rp ${_formatPrice(pkg.price)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
      items: [
        OptionMenuItem(
          icon: Icons.edit,
          title: 'Edit Paket',
          subtitle: 'Ubah detail paket',
          onTap: () {
            Navigator.pop(context);
            _openForm(context, package: pkg);
          },
        ),
        OptionMenuItem(
          icon: Icons.delete,
          title: 'Hapus Paket',
          subtitle: 'Hapus paket dari daftar',
          isDestructive: true,
          onTap: () {
            _delete(context, pkg.id);
          },
        ),
      ],
    );
  }

  void _openForm(BuildContext context, {PackageModel? package}) {
    final mainContext = this.context;

    Future.delayed(Duration.zero, () {
      Navigator.of(mainContext)
          .push(
            MaterialPageRoute(
              builder: (_) => PackageFormScreen(package: package),
            ),
          )
          .then((_) => mainContext.read<PackageProvider>().loadPackages());
    });
  }

  Future<void> _delete(BuildContext context, String id) async {
    final mainContext = this.context;

    Navigator.pop(context);

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
                    'Hapus Paket',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apakah Anda yakin ingin menghapus paket ini?',
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
                        mainContext.read<PackageProvider>().deletePackage(id);
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
                        'Ya, Hapus Paket',
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
}
