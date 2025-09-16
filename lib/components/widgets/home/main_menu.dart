import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/role.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/dashboard/customers/customer_list_screen.dart';
import 'package:wifiber/screens/dashboard/registrants/registrant_list_screen.dart';
import 'package:wifiber/screens/dashboard/infrastructure/infrastructure_home.dart';
import 'package:wifiber/screens/dashboard/mikrotik/list_mikrotik_screen.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({
    super.key,
    this.onTicketMenuTapped,
    this.onTransactionMenuTapped,
    this.onBillMenuTapped,
  });

  final VoidCallback? onTicketMenuTapped;
  final VoidCallback? onTransactionMenuTapped;
  final VoidCallback? onBillMenuTapped;

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late List<MenuItem> _allMenuItems;
  List<MenuItem> _filteredMenuItems = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _initializeMenuItems();
    _filterMenuItemsByRole();
  }

  void _initializeMenuItems() {
    _allMenuItems = [
      MenuItem(
        icon: Icons.verified_user_sharp,
        title: 'Calon Pelanggan',
        permissions: 'registrant',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrantListScreen(),
            ),
          );
        },
      ),
      MenuItem(
        icon: Icons.person,
        title: 'Data Pelanggan',
        permissions: 'customer',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CustomerListScreen()),
          );
        },
      ),
      MenuItem(
        icon: Icons.warning,
        title: 'Keluhan',
        permissions: 'ticket',
        onTap: () {
          widget.onTicketMenuTapped?.call();
        },
      ),
      MenuItem(
        icon: Icons.bookmark,
        title: 'Pembukuan',
        permissions: 'finance',
        onTap: () {
          widget.onTransactionMenuTapped?.call();
        },
      ),
      MenuItem(
        icon: Icons.wallet,
        title: 'Tagihan dan Pembayaran',
        permissions: ['bill'],
        mode: PermissionMode.any,
        onTap: () {
          widget.onBillMenuTapped?.call();
        },
      ),
      MenuItem(
        icon: Icons.wifi,
        title: 'Router MikroTik',
        permissions: 'integration',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListMikrotikScreen()),
          );
        },
      ),
      MenuItem(
        icon: Icons.pin_drop,
        title: 'Peta Infrastruktur',
        permissions: null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InfrastructureHome()),
          );
        },
      ),
    ];
  }

  void _filterMenuItemsByRole() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userPermissions = authProvider.user?.permissions ?? [];

    List<MenuItem> filtered = [];

    for (MenuItem item in _allMenuItems) {
      if (item.permissions == null) {
        filtered.add(item);
        continue;
      }

      bool hasAccess = await RoleGuard.hasPermission(
        permissions: item.permissions!,
        mode: item.mode ?? PermissionMode.all,
        userPermissions: userPermissions,
      );

      if (hasAccess) {
        filtered.add(item);
      }
    }

    setState(() {
      _filteredMenuItems = filtered;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_filteredMenuItems.isEmpty && _allMenuItems.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildMenuGrid(),
      ),
    );
  }

  Widget _buildMenuGrid() {
    if (_filteredMenuItems.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada menu yang tersedia',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVisibleItems(),
        AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _slideAnimation.value,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, (1 - _slideAnimation.value) * -20),
                    child: _buildCollapsibleItems(),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVisibleItems() {
    final visibleItems = _filteredMenuItems.take(3).toList();
    final needsCollapseButton = _filteredMenuItems.length > 3;
    final totalItems = visibleItems.length + (needsCollapseButton ? 1 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (needsCollapseButton && index == visibleItems.length) {
          return _buildCollapseButton();
        }
        return _buildMenuItem(visibleItems[index]);
      },
    );
  }

  Widget _buildCollapsibleItems() {
    if (_filteredMenuItems.length <= 3) return const SizedBox.shrink();

    final collapsibleItems = _filteredMenuItems.skip(3).toList();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: collapsibleItems.length,
        itemBuilder: (context, index) {
          return _buildMenuItem(collapsibleItems[index]);
        },
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildIconContainer(Icon(item.icon, size: 24, color: Colors.white)),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(Icon icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: icon,
    );
  }

  Widget _buildCollapseButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
          if (isExpanded) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
      },
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isExpanded ? Icons.expand_less : Icons.apps,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isExpanded ? 'Tutup' : 'Lainnya',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final dynamic permissions;
  final PermissionMode? mode;
  final VoidCallback? onTap;

  MenuItem({
    required this.icon,
    required this.title,
    this.permissions,
    this.mode,
    this.onTap,
  });
}
