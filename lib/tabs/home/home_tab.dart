import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/components/widgets/home/dashboard_summary.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/providers/auth_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, this.onTransactionTap, this.onLogoutTap});

  final VoidCallback? onTransactionTap;
  final VoidCallback? onLogoutTap;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  void _logout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                PhosphorIcons.warning(PhosphorIconsStyle.duotone),
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                "Keluar Sekarang?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Apakah anda yakin ingin keluar dari sesi ini? Harap simpan data sebelum keluar ya.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    try {
                      await authProvider.logout();
                      if (!mounted) return;

                      SnackBars.success(
                        scaffoldMessenger.context,
                        "Berhasil mengeluarkan anda dari sesi saat ini. Sampai jumpa di lain waktu!",
                      ).clearSnackBars();

                      navigator.pop();
                      widget.onLogoutTap?.call();
                    } catch (e) {
                      if (!mounted) return;

                      navigator.pop();
                      SnackBars.error(
                        scaffoldMessenger.context,
                        "Ada kesalahan saat mengeluarkan sesi. Buka ulang aplikasi atau coba keluar sekali lagi.",
                      ).clearSnackBars();
                    }
                  },
                  child: const Text("Keluar Sekarang"),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Batal"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider) {
    final authUser = authProvider.user;
    final appTheme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.black,
          child: Text(authUser?.nameInitials ?? "U"),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Selamat Datang",
              style: appTheme.textTheme.bodySmall?.copyWith(
                color: Colors.black,
              ),
            ),
            Text(
              authUser?.name ?? 'User',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: _buildProfileHeader(context, authProvider),
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.onSurface,
            actions: [
              IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.signOut(PhosphorIconsStyle.duotone),
                  color: AppColors.onSurface,
                ),
                onPressed: () => _logout(context, authProvider),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DashboardSummary(
                    onTransactionTap: widget.onTransactionTap,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}