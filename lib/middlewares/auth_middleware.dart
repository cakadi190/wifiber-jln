import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final List<String>? requiredPermissions;
  final Widget? fallback;

  const AuthGuard({
    super.key,
    required this.child,
    this.requiredPermissions,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          if (!authProvider.isManualLogout) {
            SnackBars.info(
              context,
              "Silahkan login terlebih dahulu untuk melanjutkan.",
            ).clearSnackBars();
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });

      return const Scaffold(body: SizedBox());
    }

    if (requiredPermissions != null &&
        !authProvider.hasAllPermissions(requiredPermissions!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          SnackBars.error(context, "Anda tidak memiliki hak akses.");
          Navigator.of(context).maybePop();
        }
      });
      return fallback ?? const Scaffold(body: SizedBox());
    }

    return child;
  }
}

class PermissionWidget extends StatelessWidget {
  final List<String> permissions;
  final Widget child;
  final Widget? fallback;

  const PermissionWidget({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.hasAnyPermission(permissions)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
