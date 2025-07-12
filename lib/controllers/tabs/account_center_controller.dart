import 'package:flutter/material.dart';

class AccountCenterController {
  void navigateToScreen({
    required Widget screen,
    required BuildContext context,
  }) {
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    }
  }
}
