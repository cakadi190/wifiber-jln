import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wifiber/config/app_colors.dart';

class AppFont {
  static TextTheme get textTheme => TextTheme(
    displayLarge: baseFont(46),
    displayMedium: baseFont(37),
    displaySmall: baseFont(29),
    headlineMedium: baseFont(24),
    headlineSmall: baseFont(20),
    titleLarge: baseFont(18),
    titleMedium: baseFont(16),
    titleSmall: baseFont(14),
    bodyLarge: baseFont(16),
    bodyMedium: baseFont(14),
    bodySmall: baseFont(13),
    labelLarge: baseFont(14),
    labelMedium: baseFont(12),
    labelSmall: baseFont(12),
  );

  static TextStyle baseFont(double size) {
    return GoogleFonts.figtree(
      fontSize: size,
      fontWeight: FontWeight.normal,
      color: AppColors.onSurface,
    );
  }
}
