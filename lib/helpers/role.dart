import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';

enum PermissionMode { any, all }

class RoleGuard {
  static void check({
    required BuildContext context,
    required dynamic permissions,
    required VoidCallback action,
    String? errorMessage,
    PermissionMode mode = PermissionMode.any,
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userPermissions = authProvider.user?.permissions ?? [];

    final allowed = _hasPermission(userPermissions, permissions, mode);

    print(allowed);

    if (!allowed) {
      SnackBars.error(
        context,
        errorMessage ??
            "Mohon maaf, anda tidak memiliki akses untuk mengakses fitur ini",
      );
      return;
    }

    action.call();
  }

  static bool _hasPermission(
    List<String> userPermissions,
    dynamic permissions,
    PermissionMode mode,
  ) {
    if (permissions is String) {
      return userPermissions.contains(permissions);
    } else if (permissions is List<String>) {
      if (mode == PermissionMode.any) {
        return permissions.any(userPermissions.contains);
      } else {
        return permissions.every(userPermissions.contains);
      }
    }
    return false;
  }
}

class RoleGuardWidget extends StatelessWidget {
  final dynamic permissions;
  final Widget child;
  final Widget? fallback;
  final PermissionMode mode;

  const RoleGuardWidget({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
    this.mode = PermissionMode.any,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userPermissions = authProvider.user?.permissions ?? [];

    final allowed = RoleGuard._hasPermission(
      userPermissions,
      permissions,
      mode,
    );

    if (!allowed) {
      return fallback ?? const SizedBox.shrink();
    }

    return child;
  }
}
