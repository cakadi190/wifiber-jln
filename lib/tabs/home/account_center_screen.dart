import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/components/widgets/user_avatar.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/account_center_controller.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/apps/about_app_screen.dart';
import 'package:wifiber/screens/dashboard/profile/main_profile_screen.dart';
import 'package:wifiber/screens/profile/change_password_screen.dart';
import 'package:wifiber/screens/dashboard/areas/area_list_screen.dart';
import 'package:wifiber/screens/dashboard/packages/package_list_screen.dart';

class AccountCenterScreen extends StatefulWidget {
  const AccountCenterScreen({super.key, this.onLogoutTap});

  final VoidCallback? onLogoutTap;

  @override
  State<AccountCenterScreen> createState() => _AccountCenterScreenState();
}

class _AccountCenterScreenState extends State<AccountCenterScreen> {
  final AccountCenterController _accountCenterController =
      AccountCenterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun Saya')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildActionTileLists(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(560),
          bottomRight: Radius.circular(560),
        ),
      ),
      height: 250,
      width: double.infinity,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final authUser = authProvider.user;

          return Column(
            children: [
              UserAvatar(
                imageUrl:
                    authUser?.picture != null && authUser!.picture!.isNotEmpty
                    ? authUser.picture
                    : null,
                name: authUser?.nameInitials ?? 'U',
                radius: 48,
                backgroundColor: Colors.black,
                headers: authUser?.accessToken != null
                    ? {'Authorization': 'Bearer ${authUser?.accessToken}'}
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                authUser?.name ?? 'User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                authUser?.email ?? 'mail@wifiber.id',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  _accountCenterController.navigateToScreen(
                    screen: const MainProfileScreen(),
                    context: context,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ubah Profil',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionTileLists(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: PhosphorIcon(
            PhosphorIcons.lock(PhosphorIconsStyle.duotone),
            color: AppColors.primary,
          ),
          title: const Text('Ubah Kata Sandi'),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
          onTap: () {
            _accountCenterController.navigateToScreen(
              screen: ChangePasswordScreen(),
              context: context,
            );
          },
        ),
        ListTile(
          leading: PhosphorIcon(
            PhosphorIcons.mapTrifold(PhosphorIconsStyle.duotone),
            color: AppColors.primary,
          ),
          title: const Text('Area'),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
          onTap: () {
            _accountCenterController.navigateToScreen(
              screen: const AreaListScreen(),
              context: context,
            );
          },
        ),
        ListTile(
          leading: PhosphorIcon(
            PhosphorIcons.package(PhosphorIconsStyle.duotone),
            color: AppColors.primary,
          ),
          title: const Text('Paket'),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
          onTap: () {
            _accountCenterController.navigateToScreen(
              screen: const PackageListScreen(),
              context: context,
            );
          },
        ),
        ListTile(
          leading: PhosphorIcon(
            PhosphorIcons.info(PhosphorIconsStyle.duotone),
            color: AppColors.primary,
          ),
          title: const Text('Tentang Aplikasi'),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
          onTap: () {
            _accountCenterController.navigateToScreen(
              screen: const AboutAppScreen(),
              context: context,
            );
          },
        ),
        ListTile(
          leading: PhosphorIcon(
            PhosphorIcons.signOut(PhosphorIconsStyle.duotone),
            color: Colors.red,
          ),
          title: const Text('Keluar', style: TextStyle(color: Colors.red)),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.red),
          onTap: () => _logout(context, context.read<AuthProvider>()),
        ),
      ],
    );
  }

  void _logout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
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
                style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Apakah anda yakin ingin keluar dari sesi ini? Harap simpan data sebelum keluar ya.",
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodyMedium,
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
                    final navigator = Navigator.of(dialogContext);
                    final mainContext = context;

                    try {
                      await authProvider.logout();

                      if (dialogContext.mounted) {
                        navigator.pop();
                      }

                      if (mounted) {
                        SnackBars.success(
                          mainContext,
                          "Berhasil mengeluarkan anda dari sesi saat ini. Sampai jumpa di lain waktu!",
                        ).clearSnackBars();
                      }

                      widget.onLogoutTap?.call();
                    } catch (e) {
                      if (dialogContext.mounted) {
                        navigator.pop();
                      }

                      if (mounted) {
                        SnackBars.error(
                          mainContext,
                          "Gagal mengeluarkan anda dari sesi saat ini. Silahkan coba lagi.",
                        ).clearSnackBars();
                      }
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
                    Navigator.of(dialogContext).pop();
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
}
