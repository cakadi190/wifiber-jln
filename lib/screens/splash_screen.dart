import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/controllers/splash_screen_controller.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/partials/splash/splash_screen_body.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashScreenController _controller;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _controller = SplashScreenController(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.initializeApp();
      });
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SplashScreenController>.value(
      value: _controller,
      child: SystemUiWrapper(
        style: SystemUiHelper.light(
          statusBarColor: Colors.transparent,
          navigationBarColor: Colors.grey.shade300,
        ),
        child: Scaffold(
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: const SplashScreenBody(),
            ),
          ),
        ),
      ),
    );
  }
}
