import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/complaint_tab_controller.dart';
import 'package:wifiber/controllers/tabs/transaction_tab.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/providers/transaction_provider.dart';
import 'package:wifiber/screens/dashboard/bills/bills_screen.dart';
import 'package:wifiber/screens/login_screen.dart';
import 'package:wifiber/tabs/home/account_center_screen.dart';
import 'package:wifiber/tabs/home/complaints_tab.dart';
import 'package:wifiber/tabs/home/home_tab.dart';
import 'package:wifiber/tabs/home/transaction_tab.dart';
import 'package:wifiber/helpers/role.dart';

class _TabItem {
  final String key;
  final Widget widget;
  final BottomNavigationBarItem item;

  const _TabItem({
    required this.key,
    required this.widget,
    required this.item,
  });
}

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String _selectedTab = 'home';
  late final TransactionTabController _transactionTabController;
  late final ComplaintTabController _complaintController;

  DateTime? _lastBackPressed;
  bool _showExitMessage = false;

  SystemUiOverlayStyle _internalStyle = SystemUiHelper.duotone(
    statusBarColor: Colors.transparent,
    navigationBarColor: AppColor.violet50,
  );

  @override
  void initState() {
    super.initState();

    final transactionProvider = context.read<TransactionProvider>();
    _transactionTabController = TransactionTabController(transactionProvider);
    _complaintController = ComplaintTabController(context);
  }

  List<_TabItem> _buildTabs(AuthProvider authProvider) {
    final tabs = <_TabItem>[];

    tabs.add(
      _TabItem(
        key: 'home',
        widget: HomeTab(
          onTransactionTap: () => _onTabSelected('finance'),
          onBookKeepingTap: () => _onTabSelected('bills'),
          onLogoutTap: _onLogoutRedirect,
          onTicketTap: () => _onTabSelected('ticket'),
        ),
        item: BottomNavigationBarItem(
          icon: PhosphorIcon(PhosphorIcons.house(PhosphorIconsStyle.duotone)),
          label: 'Beranda',
        ),
      ),
    );

    if (authProvider.user?.permissions.contains('finance') ?? false) {
      tabs.add(
        _TabItem(
          key: 'finance',
          widget: TransactionTab(controller: _transactionTabController),
          item: BottomNavigationBarItem(
            icon: PhosphorIcon(PhosphorIcons.wallet(PhosphorIconsStyle.duotone)),
            label: 'Keuangan',
          ),
        ),
      );

      if (authProvider.user?.permissions.contains('bill') ?? false) {
        tabs.add(
          _TabItem(
            key: 'bills',
            widget: Container(),
            item: BottomNavigationBarItem(
              icon: PhosphorIcon(
                PhosphorIcons.listChecks(PhosphorIconsStyle.duotone),
              ),
              label: 'Tagihan',
            ),
          ),
        );
      }
    }

    if (authProvider.user?.permissions.contains('ticket') ?? false) {
      tabs.add(
        _TabItem(
          key: 'ticket',
          widget: ComplaintsTab(controller: _complaintController),
          item: BottomNavigationBarItem(
            icon: PhosphorIcon(
              PhosphorIcons.chatCenteredDots(PhosphorIconsStyle.duotone),
            ),
            label: 'Pengaduan',
          ),
        ),
      );
    }

    tabs.add(
      _TabItem(
        key: 'account',
        widget: AccountCenterScreen(),
        item: BottomNavigationBarItem(
          icon: PhosphorIcon(PhosphorIcons.user(PhosphorIconsStyle.duotone)),
          label: 'Akun',
        ),
      ),
    );

    return tabs;
  }

  void _onLogoutRedirect() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: const RouteSettings(arguments: {'showLogoutMessage': true}),
      ),
      (route) => false,
    );
  }

  void _onTabSelected(String key) {
    switch (key) {
      case 'home':
        setState(() {
          _internalStyle = SystemUiHelper.light(
            statusBarColor: AppColors.background,
            navigationBarColor: AppColor.violet50,
          );
        });
        break;
      case 'finance':
        RoleGuard.check(
          context: context,
          permissions: 'finance',
          action: () => _transactionTabController.refreshTransactions(),
        );
        break;
      case 'bills':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const BillsScreen()));
        return;
      case 'ticket':
        RoleGuard.check(
          context: context,
          permissions: 'ticket',
          action: () => _complaintController.loadComplaints(),
        );
        break;
      case 'account':
        setState(() {
          _internalStyle = SystemUiHelper.duotone(
            statusBarColor: Colors.transparent,
            navigationBarColor: AppColor.violet50,
          );
        });
        break;
    }

    setState(() {
      _selectedTab = key == 'bills' ? _selectedTab : key;
      _showExitMessage = false;
    });
  }

  bool _handleBackNavigation() {
    final now = DateTime.now();

    if (_selectedTab != 'home') {
      _onTabSelected('home');
      return false;
    }

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;

      setState(() {
        _showExitMessage = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showExitMessage = false;
          });
        }
      });

      return false;
    }

    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: _internalStyle,
      child: AuthGuard(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) {
            if (!didPop) {
              _handleBackNavigation();
            }
          },
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final tabs = _buildTabs(authProvider);
              final currentIndex =
                  tabs.indexWhere((t) => t.key == _selectedTab);
              final safeIndex = currentIndex < 0 ? 0 : currentIndex;

              return Scaffold(
                body: Stack(
                  children: [
                    tabs[safeIndex].widget,

                    if (_showExitMessage)
                      Positioned(
                        bottom: 100,
                        left: 16,
                        right: 16,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Tekan tombol kembali sekali lagi untuk keluar dari aplikasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                bottomNavigationBar: Theme(
                  data: ThemeData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: AppColor.violet50,
                    currentIndex: safeIndex,
                    onTap: (index) => _onTabSelected(tabs[index].key),
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: Colors.grey,
                    showUnselectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                    items: tabs.map((t) => t.item).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
