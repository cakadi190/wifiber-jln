import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/widgets/home/dashboard_summary.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/home_tab.dart';
import 'package:wifiber/providers/auth_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, this.onTransactionTap, this.onLogoutTap});

  final VoidCallback? onTransactionTap;
  final VoidCallback? onLogoutTap;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late HomeController _controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        _controller = HomeController(
          context: context,
          authProvider: authProvider,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: _ProfileHeader(controller: _controller),
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.onSurface,
            actions: [
              IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.signOut(PhosphorIconsStyle.duotone),
                  color: AppColors.onSurface,
                ),
                onPressed: () => _controller.handleLogout(
                  onLogoutSuccess: widget.onLogoutTap,
                ),
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

class _ProfileHeader extends StatelessWidget {
  final HomeController controller;

  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);

    return Row(
      children: [
        _UserAvatar(controller: controller),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
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
                controller.userDisplayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: appTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Separate widget for user avatar
class _UserAvatar extends StatelessWidget {
  final HomeController controller;

  const _UserAvatar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.black,
      child: !controller.isAuthenticated
          ? const Text('U')
          : !controller.hasProfilePicture
          ? Text(controller.userInitials)
          : ClipOval(
        child: Image.network(
          controller.userPictureUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          headers: controller.userAccessToken != null
              ? {'Authorization': 'Bearer ${controller.userAccessToken}'}
              : {},
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _AvatarFallback(initials: controller.userInitials);
          },
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initials;

  const _AvatarFallback({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}