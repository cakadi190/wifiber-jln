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
    if (isExpanded) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: menuItems.length + 1,
        itemBuilder: (context, index) {
          if (index == menuItems.length) {
            return _buildCollapseButton();
          }
          return _buildMenuItem(menuItems[index]);
        },
      );
    } else {
      final displayItems = menuItems.take(3).toList();

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...displayItems.map(
              (item) => Expanded(child: _buildMenuItem(item)),
            ),
            Expanded(child: _buildCollapseButton()),
          ],
        ),
      );
    }
  }

  Widget _buildMenuItem(MenuItem item) {
    return GestureDetector(
      onTap: () {
        print('Tapped: ${item.title}');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 24, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapseButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isExpanded ? Icons.expand_less : Icons.apps,
            size: 24,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            isExpanded ? 'Tutup' : 'Lainnya',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
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
