import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUiWrapper extends StatelessWidget {
  final Widget child;
  final SystemUiOverlayStyle style;

  const SystemUiWrapper({
    super.key,
    required this.child,
    this.style = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: child,
    );
  }
}
