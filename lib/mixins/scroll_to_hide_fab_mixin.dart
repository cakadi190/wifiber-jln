import 'package:flutter/material.dart';

mixin ScrollToHideFabMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  bool isFabVisible = true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    super.dispose();
  }

  double _lastScrollPosition = 0;
  final double _scrollThreshold = 20.0;

  void _handleScroll() {
    if (!scrollController.hasClients) return;

    final currentScroll = scrollController.position.pixels;

    if (currentScroll < 0 ||
        currentScroll > scrollController.position.maxScrollExtent) {
      return;
    }

    if (currentScroll > _lastScrollPosition + _scrollThreshold) {
      if (isFabVisible) {
        setState(() {
          isFabVisible = false;
        });
      }
      _lastScrollPosition = currentScroll;
    } else if (currentScroll < _lastScrollPosition - _scrollThreshold) {
      if (!isFabVisible) {
        setState(() {
          isFabVisible = true;
        });
      }
      _lastScrollPosition = currentScroll;
    }
  }

  void showFab() {
    if (!isFabVisible) {
      setState(() {
        isFabVisible = true;
      });
    }
  }
}
