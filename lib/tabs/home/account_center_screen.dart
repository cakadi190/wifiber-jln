import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/account_center_controller.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/dashboard/profile/main_profile_screen.dart';

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
            Container(
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
                      const CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(
                          'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                        ),
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
            ),

            const SizedBox(height: 8),

            _buildActionTileLists(context),
          ],
        ),
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
            // _accountCenterController.navigateToScreen(
            //   screen: const ChangePasswordScreen(),
            //   context: context,
            // );
          },
        ),
        ListTile(
          leading: PhosphorIcon(
            PhosphorIcons.info(PhosphorIconsStyle.duotone),
            color: AppColors.primary,
          ),
          title: const Text('Bantuan'),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
          onTap: () {
            // _accountCenterController.navigateToScreen(
            //   screen: const HelpScreen(),
            //   context: context,
            // );
          },
        ),
        ListTile(
          leading: PhosphorIcon(
            PhosphorIcons.shieldCheck(PhosphorIconsStyle.duotone),
            color: AppColors.primary,
          ),
          title: const Text('Kebijakan Privasi'),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
          onTap: () {
            // _accountCenterController.navigateToScreen(
            //   screen: const PrivacyPolicyScreen(),
            //   context: context,
            // );
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
            // _accountCenterController.navigateToScreen(
            //   screen: const PrivacyPolicyScreen(),
            //   context: context,
            // );
          },
        ),
        ListTile(
          leading: PhosphorIcon(
            PhosphorIcons.signOut(PhosphorIconsStyle.duotone),
            color: Colors.red,
          ),
          title: const Text('Keluar', style: TextStyle(color: Colors.red)),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.red,
          ),
          onTap: () => _logout(context, context.read<AuthProvider>()),
        ),
      ],
    );
  }

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
}
