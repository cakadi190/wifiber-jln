import 'package:flutter/material.dart';

class HomeDashboardTabItem {
  final String key;
  final Widget widget;
  final BottomNavigationBarItem item;

  const HomeDashboardTabItem({
    required this.key,
    required this.widget,
    required this.item,
  });
}
