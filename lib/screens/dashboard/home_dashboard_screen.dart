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
  late final List<Widget> _widgetOptions;
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

    final provider = context.read<TransactionProvider>();
    _transactionTabController = TransactionTabController(provider);
    _complaintController = ComplaintTabController(context);

    _widgetOptions = [
      HomeTab(
        onTransactionTap: () => _onItemTapped(1),
        onBookKeepingTap: () => _onItemTapped(2),
        onLogoutTap: _onLogoutRedirect,
        onTicketTap: () => _onItemTapped(3),
      ),
      TransactionTab(controller: _transactionTabController),
      Container(),
      ComplaintsTab(controller: _complaintController),
      AccountCenterScreen(),
    ];
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
    if (index == 4) {
      setState(() {
        _internalStyle = SystemUiHelper.duotone(
          statusBarColor: Colors.transparent,
          navigationBarColor: AppColor.violet50,
        );
      });
    } else if (index == 1) {
      RoleGuard.check(
        context: context,
        permissions: 'finance',
        action: () => _transactionTabController.refreshTransactions(),
      );
    } else if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const BillsScreen()));
    } else if (index == 3) {
      RoleGuard.check(
        context: context,
        permissions: 'ticket',
        action: () => _complaintController.loadComplaints(),
      );
    } else {
      setState(() {
        _internalStyle = SystemUiHelper.light(
          statusBarColor: AppColors.background,
          navigationBarColor: AppColor.violet50,
        );
      });
    }

    setState(() {
      _selectedIndex = index == 2 ? _selectedIndex : index;

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
          child: Scaffold(
            body: Stack(
              children: [
                _widgetOptions.elementAt(_selectedIndex),

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
                          style: TextStyle(color: Colors.white, fontSize: 14),
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
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: PhosphorIcon(
                      PhosphorIcons.house(PhosphorIconsStyle.duotone),
                    ),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: PhosphorIcon(
                      PhosphorIcons.wallet(PhosphorIconsStyle.duotone),
                    ),
                    label: 'Keuangan',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.qrCode(PhosphorIconsStyle.duotone),
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Bayar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: PhosphorIcon(
                      PhosphorIcons.chatCenteredDots(
                        PhosphorIconsStyle.duotone,
                      ),
                    ),
                    label: 'Pengaduan',
                  ),
                  BottomNavigationBarItem(
                    icon: PhosphorIcon(
                      PhosphorIcons.user(PhosphorIconsStyle.duotone),
                    ),
                    label: 'Akun',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
