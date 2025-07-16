import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool isExpanded = false;

  final List<MenuItem> menuItems = [
    MenuItem(icon: Icons.verified_user_sharp, title: 'Calon Pelanggan'),
    MenuItem(icon: Icons.person, title: 'Data Pelanggan'),
    MenuItem(icon: Icons.warning, title: 'Keluhan'),
    MenuItem(icon: Icons.bookmark, title: 'Pembukuan'),
    MenuItem(icon: Icons.wifi, title: 'Mikrotik'),
    MenuItem(icon: Icons.pin_drop, title: 'Peta Infrastruktur'),
    MenuItem(icon: Icons.cell_tower, title: 'Infrastruktur'),
  ];

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _buildMenuGrid(),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final displayItems = isExpanded ? menuItems : menuItems.take(3).toList();
    final totalItems = displayItems.length + 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index == displayItems.length) {
          return _buildCollapseButton();
        }
        return _buildMenuItem(displayItems[index]);
      },
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return GestureDetector(
      onTap: () {
        print('Tapped: ${item.title}');
      },
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
        });
      },
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildIconContainer(Icon(
              isExpanded ? Icons.expand_less : Icons.apps,
              size: 24,
              color: Colors.white,
            )),
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
