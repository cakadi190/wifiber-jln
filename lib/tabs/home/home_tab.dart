import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/widgets/home/dashboard_summary.dart';
import 'package:wifiber/components/widgets/home/tickets_summary.dart';
import 'package:wifiber/components/widgets/user_avatar.dart';
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
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: TicketSummary(),
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
        UserAvatar(
          imageUrl: controller.isAuthenticated && controller.hasProfilePicture
              ? controller.userPictureUrl
              : null,
          name: controller.userDisplayName,
          radius: 24,
          backgroundColor: Colors.black,
          headers: controller.userAccessToken != null
              ? {'Authorization': 'Bearer ${controller.userAccessToken}'}
              : null,
        ),
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