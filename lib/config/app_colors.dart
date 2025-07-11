import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3E4095);
  static const Color primaryContainer = Color(0xFFA6A7CE);
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFF6566AA);
  static const Color onSecondary = Colors.white;

  static const Color background = Color(0xFFF0F0F0);
  static const Color onBackground = Color(0xFF2D2D2D);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF2D2D2D);
  static const Color surfaceVariant = Color(0xFFD1D1D1);

  static const Color error = Color(0xFFB00020);
  static const Color onError = Colors.white;

  static ColorScheme get colorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimary,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: Color(0xFF7E7FB8),
    onSecondaryContainer: onPrimary,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurface,
    error: error,
    onError: onError,
    outline: Color(0xFF9C9C9C),
  );
}

class AppColor {
  static const Color violet50 = Color(0xFFECECF4);
  static const Color violet100 = Color(0xFFC3C4DE);
  static const Color violet200 = Color(0xFFA6A7CE);
  static const Color violet300 = Color(0xFF7E7FB8);
  static const Color violet400 = Color(0xFF6566AA);
  static const Color violet500 = Color(0xFF3E4095);
  static const Color violet600 = Color(0xFF383A88);
  static const Color violet700 = Color(0xFF2C2D6A);
  static const Color violet800 = Color(0xFF222352);
  static const Color violet900 = Color(0xFF1A1B3F);

  static const Color grey50 = Color(0xFFF0F0F0);
  static const Color grey100 = Color(0xFFD1D1D1);
  static const Color grey200 = Color(0xFFBBBBBB);
  static const Color grey300 = Color(0xFF9C9C9C);
  static const Color grey400 = Color(0xFF898989);
  static const Color grey500 = Color(0xFF6B6B6B);
  static const Color grey600 = Color(0xFF616161);
  static const Color grey700 = Color(0xFF4C4C4C);
  static const Color grey800 = Color(0xFF3B3B3B);
  static const Color grey900 = Color(0xFF2D2D2D);
}