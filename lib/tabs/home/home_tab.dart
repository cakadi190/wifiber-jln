import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/widgets/home/customer_summary.dart';
import 'package:wifiber/components/widgets/home/dashboard_summary.dart';
import 'package:wifiber/components/widgets/home/main_menu.dart';
import 'package:wifiber/components/widgets/home/tickets_summary.dart';
import 'package:wifiber/components/widgets/home/finance_summary.dart';
import 'package:wifiber/components/widgets/user_avatar.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/dashboard_summary.dart';
import 'package:wifiber/controllers/tabs/home_tab.dart';
import 'package:wifiber/providers/auth_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    this.onTransactionTap,
    this.onLogoutTap,
    this.onTicketTap,
    this.onBookKeepingTap,
  });

  final VoidCallback? onTransactionTap;
  final VoidCallback? onBookKeepingTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onTicketTap;

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

        final hasFinancePermission =
            authProvider.user?.permissions.contains('finance') == true;
        final hasTicketPermission =
            authProvider.user?.permissions.contains('ticket') == true;

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
          body: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  if (hasFinancePermission)
                    ChangeNotifierProvider(
                      create: (_) =>
                          DashboardSummaryController()..loadDashboardData(),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: DashboardSummary(
                              onTransactionTap: widget.onTransactionTap,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: const CustomerSummary(),
                          ),
                        ],
                      ),
                    ),

                  if (!hasFinancePermission) const SizedBox(height: 24),

                  MainMenu(
                    onTicketMenuTapped: widget.onTicketTap,
                    onTransactionMenuTapped: widget.onTransactionTap,
                    onBillMenuTapped: widget.onBookKeepingTap,
                  ),

                  if (hasFinancePermission)
                    SizedBox(
                      width: double.infinity,
                      child: FinanceSummary(
                        onFinanceTap: widget.onTransactionTap,
                      ),
                    ),

                  if (hasTicketPermission)
                    SizedBox(
                      width: double.infinity,
                      child: TicketSummary(onTicketTap: widget.onTicketTap),
                    ),
                ],
              ),
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

    return InkWell(
      onTap: () => controller.navigateToProfile(),
      child: Row(
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
      ),
    );
  }
}
