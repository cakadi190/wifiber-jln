import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/config/app_font.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/providers/bills_provider.dart';
import 'package:wifiber/providers/complaint_provider.dart';
import 'package:wifiber/providers/customer_provider.dart';
import 'package:wifiber/providers/registrant_provider.dart';
import 'package:wifiber/providers/router_provider.dart';
import 'package:wifiber/providers/transaction_provider.dart';
import 'package:wifiber/providers/infrastructure_provider.dart';
import 'package:wifiber/screens/splash_screen.dart';
import 'package:wifiber/services/bills_service.dart';
import 'package:wifiber/services/complaint_service.dart';
import 'package:wifiber/services/customer_service.dart';
import 'package:wifiber/services/registrant_service.dart';
import 'package:wifiber/services/router_service.dart';
import 'package:wifiber/services/transaction_service.dart';
import 'package:wifiber/services/navigation_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(TransactionService()),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistrantProvider(RegistrantService()),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(CustomerService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(ComplaintService()),
        ),
        ChangeNotifierProvider(create: (_) => BillsProvider(BillsService())),
        ChangeNotifierProvider(create: (_) => RouterProvider(RouterService())),
        ChangeNotifierProvider(create: (_) => InfrastructureProvider()),
      ],
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
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.colorScheme,
        textTheme: AppFont.textTheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          unselectedLabelStyle: AppFont.baseFont(12),
          selectedLabelStyle: AppFont.baseFont(12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFFE5E1EF), width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFFE5E1EF), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFFE5E1EF), width: 1.0),
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
