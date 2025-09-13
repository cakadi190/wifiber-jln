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

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;
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

  List<Widget> _buildWidgetOptions(AuthProvider authProvider) {
    List<Widget> widgets = [];

    widgets.add(
      HomeTab(
        onTransactionTap: () => _onItemTapped(1),
        onBookKeepingTap: () => _onItemTapped(2),
        onLogoutTap: _onLogoutRedirect,
        onTicketTap: () => _onItemTapped(
          (authProvider.user?.permissions.contains('finance') ?? false) ? 3 : 1,
        ),
      ),
    );

    if (authProvider.user?.permissions.contains('finance') ?? false) {
      widgets.add(TransactionTab(controller: _transactionTabController));
      widgets.add(Container());
    }

    if (authProvider.user?.permissions.contains('ticket') ?? false) {
      widgets.add(ComplaintsTab(controller: _complaintController));
    }

    widgets.add(AccountCenterScreen());

    return widgets;
  }

  List<BottomNavigationBarItem> _buildBottomNavItems(
    AuthProvider authProvider,
  ) {
    List<BottomNavigationBarItem> items = [];

    items.add(
      BottomNavigationBarItem(
        icon: PhosphorIcon(PhosphorIcons.house(PhosphorIconsStyle.duotone)),
        label: 'Beranda',
      ),
    );

    if (authProvider.user?.permissions.contains('finance') ?? false) {
      items.add(
        BottomNavigationBarItem(
          icon: PhosphorIcon(PhosphorIcons.wallet(PhosphorIconsStyle.duotone)),
          label: 'Keuangan',
        ),
      );
    }

    if (authProvider.user?.permissions.contains('bill') ?? false) {
      items.add(
        BottomNavigationBarItem(
          icon: PhosphorIcon(
            PhosphorIcons.listChecks(PhosphorIconsStyle.duotone),
          ),
          label: 'Tagihan',
        ),
      );
    }

    if (authProvider.user?.permissions.contains('ticket') ?? false) {
      items.add(
        BottomNavigationBarItem(
          icon: PhosphorIcon(
            PhosphorIcons.chatCenteredDots(PhosphorIconsStyle.duotone),
          ),
          label: 'Pengaduan',
        ),
      );
    }

    items.add(
      BottomNavigationBarItem(
        icon: PhosphorIcon(PhosphorIcons.user(PhosphorIconsStyle.duotone)),
        label: 'Akun',
      ),
    );

    return items;
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

  void _onItemTapped(int index) {
    final authProvider = context.read<AuthProvider>();
    bool hasFinance =
        authProvider.user?.permissions.contains('finance') ?? false;
    bool hasTicket = authProvider.user?.permissions.contains('ticket') ?? false;

    List<String> availableTabs = ['home'];
    if (hasFinance) availableTabs.addAll(['finance', 'bills']);
    if (hasTicket) availableTabs.add('ticket');
    availableTabs.add('account');

    if (index >= availableTabs.length) return;

    String selectedTab = availableTabs[index];

    switch (selectedTab) {
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
      _selectedIndex = selectedTab == 'bills' ? _selectedIndex : index;
      _showExitMessage = false;
    });
  }

  bool _handleBackNavigation() {
    final now = DateTime.now();

    if (_selectedIndex != 0) {
      _onItemTapped(0);
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
              final widgetOptions = _buildWidgetOptions(authProvider);
              final bottomNavItems = _buildBottomNavItems(authProvider);

              final safeSelectedIndex = _selectedIndex >= widgetOptions.length
                  ? 0
                  : _selectedIndex;

              return Scaffold(
                body: Stack(
                  children: [
                    widgetOptions.elementAt(safeSelectedIndex),

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
                    currentIndex: safeSelectedIndex,
                    onTap: _onItemTapped,
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: Colors.grey,
                    showUnselectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                    items: bottomNavItems,
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
