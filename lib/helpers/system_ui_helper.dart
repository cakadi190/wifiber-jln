import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUiHelper {
  static Brightness _brightness(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Brightness.dark : Brightness.light;
  }

  static SystemUiOverlayStyle light({
    Color statusBarColor = Colors.transparent,
    Color navigationBarColor = Colors.white,
  }) {
    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: navigationBarColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
  }

  static SystemUiOverlayStyle dark({
    Color statusBarColor = Colors.transparent,
    Color navigationBarColor = Colors.black,
  }) {
    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: navigationBarColor,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light,
    );
  }

  static SystemUiOverlayStyle duotone({
    Color statusBarColor = Colors.transparent,
    Color navigationBarColor = Colors.white,
  }) {
    final brightnessForStatusBar = _brightness(statusBarColor);
    final brightnessForNavBar = _brightness(navigationBarColor);

    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: brightnessForStatusBar,
      statusBarBrightness: brightnessForStatusBar,
      systemNavigationBarColor: navigationBarColor,
      systemNavigationBarIconBrightness: brightnessForNavBar,
    );
  }
}
