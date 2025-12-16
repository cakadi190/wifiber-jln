import 'package:flutter/material.dart';

class HideableFabWrapper extends StatelessWidget {
  final bool visible;
  final Widget child;

  const HideableFabWrapper({
    super.key,
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: child,
    );
  }
}
