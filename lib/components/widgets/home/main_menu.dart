import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool isExpanded = false;

  final List<MenuItem> menuItems = [
    MenuItem(icon: Icons.home, title: 'Home'),
    MenuItem(icon: Icons.search, title: 'Search'),
    MenuItem(icon: Icons.favorite, title: 'Favorite'),
    MenuItem(icon: Icons.person, title: 'Profile'),
    MenuItem(icon: Icons.settings, title: 'Settings'),
    MenuItem(icon: Icons.notifications, title: 'Notifications'),
    MenuItem(icon: Icons.help, title: 'Help'),
    MenuItem(icon: Icons.info, title: 'About'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Main Menu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,

              child: _buildMenuGrid(),
            ),
          ],
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

      return Row(
        children: [
          ...displayItems.asMap().entries.map((entry) {
            int index = entry.key;
            MenuItem item = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < displayItems.length - 1 ? 12 : 0,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildMenuItem(item),
                ),
              ),
            );
          }),

          const SizedBox(width: 12),

          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _buildCollapseButton(),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMenuItem(MenuItem item) {
    return GestureDetector(
      onTap: () {
        print('Tapped: ${item.title}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 24, color: Colors.blue.shade600),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.apps,
              size: 24,
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              isExpanded ? 'Tutup' : 'Lainnya',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade600,
              ),
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