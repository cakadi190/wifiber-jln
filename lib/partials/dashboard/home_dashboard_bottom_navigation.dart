import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/partials/dashboard/home_dashboard_tab_item.dart';

class HomeDashboardBottomNavigation extends StatelessWidget {
  const HomeDashboardBottomNavigation({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<HomeDashboardTabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColor.violet50,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: tabs.map((t) => t.item).toList(),
      ),
    );
  }
}
