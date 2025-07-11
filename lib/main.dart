import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/config/app_font.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const CoreApp(),
    ),
  );
}

class CoreApp extends StatelessWidget {
  const CoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wifiber',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.colorScheme,
        textTheme: AppFont.textTheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: Color(0xFFE5E1EF),
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: Color(0xFFE5E1EF),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.0,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: Color(0xFFE5E1EF),
              width: 1.0,
            ),
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
