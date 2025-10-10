import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({
    super.key,
    required this.ipAddress,
    required this.loading,
  });

  final String ipAddress;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: loading,
      child: Text('Diakses dari $ipAddress', textAlign: TextAlign.center),
    );
  }
}
