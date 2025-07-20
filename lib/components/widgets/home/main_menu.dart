import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';
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
        curve: Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _menuItems = [
      MenuItem(icon: Icons.verified_user_sharp, title: 'Calon Pelanggan'),
      MenuItem(icon: Icons.person, title: 'Data Pelanggan'),
      MenuItem(
        icon: Icons.warning,
        title: 'Keluhan',
        onTap: widget.onTicketMenuTapped,
      ),
      MenuItem(
        icon: Icons.bookmark,
        title: 'Pembukuan',
        onTap: widget.onTransactionMenuTapped,
      ),
      MenuItem(
        icon: Icons.wallet,
        title: 'Tagihan dan Pembayaran',
        onTap: widget.onBillMenuTapped,
      ),
      MenuItem(
        icon: Icons.wifi,
        title: 'Router MikroTik',
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
        onTap: () {},
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  late List<MenuItem> _menuItems;

  @override
  Widget build(BuildContext context) {
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
    final visibleItems = _menuItems.take(3).toList();
    final totalItems = visibleItems.length + 1;

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
        if (index == visibleItems.length) {
          return _buildCollapseButton();
        }
        return _buildMenuItem(visibleItems[index]);
      },
    );
  }

  Widget _buildCollapsibleItems() {
    if (_menuItems.length <= 3) return const SizedBox.shrink();

    final collapsibleItems = _menuItems.skip(3).toList();

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
  final VoidCallback? onTap;

  MenuItem({required this.icon, required this.title, this.onTap});
}
