import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/providers/auth_provider.dart';

class HomeController {
  final BuildContext context;
  final AuthProvider authProvider;

  HomeController({
    required this.context,
    required this.authProvider,
  });

  /// Handle logout confirmation dialog and logout process
  Future<void> handleLogout({VoidCallback? onLogoutSuccess}) async {
    final shouldLogout = await _showLogoutConfirmationDialog();
    if (shouldLogout == true) {
      await _performLogout(onLogoutSuccess);
    }
  }

  /// Show logout confirmation dialog
  Future<bool?> _showLogoutConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => _LogoutConfirmationDialog(
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// Perform the actual logout process
  Future<void> _performLogout(VoidCallback? onLogoutSuccess) async {
    try {
      await authProvider.logout();
      if (!context.mounted) return;

      _showLogoutSuccessMessage();
      onLogoutSuccess?.call();
    } catch (e) {
      if (!context.mounted) return;
      _showLogoutErrorMessage();
    }
  }

  /// Show success message after logout
  void _showLogoutSuccessMessage() {
    SnackBars.success(
      context,
      "Berhasil mengeluarkan anda dari sesi saat ini. Sampai jumpa di lain waktu!",
    ).clearSnackBars();
  }

  /// Show error message if logout fails
  void _showLogoutErrorMessage() {
    SnackBars.error(
      context,
      "Ada kesalahan saat mengeluarkan sesi. Buka ulang aplikasi atau coba keluar sekali lagi.",
    ).clearSnackBars();
  }

  /// Get user display name
  String get userDisplayName => authProvider.user?.name ?? 'User';

  /// Get user initials for avatar
  String get userInitials => authProvider.user?.nameInitials ?? 'U';

  /// Get user profile picture URL
  String? get userPictureUrl => authProvider.user?.picture;

  /// Get user access token for image headers
  String? get userAccessToken => authProvider.user?.accessToken;

  /// Check if user has profile picture
  bool get hasProfilePicture => authProvider.user?.picture != null;

  /// Check if user is authenticated
  bool get isAuthenticated => authProvider.user != null;
}

/// Separate widget for logout confirmation dialog
class _LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _LogoutConfirmationDialog({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: onConfirm,
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
              onPressed: onCancel,
              child: const Text("Batal"),
            ),
          ],
        ),
      ],
    );
  }
}