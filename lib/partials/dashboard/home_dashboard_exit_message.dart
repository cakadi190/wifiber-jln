import 'package:flutter/material.dart';
import 'package:wifiber/components/ui/snackbars.dart';

class HomeDashboardExitMessage extends StatelessWidget {
  const HomeDashboardExitMessage({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SnackBars.dark(
        context,
        'Tekan tombol kembali sekali lagi untuk keluar dari aplikasi.',
      );
    });

    return const SizedBox.shrink();
  }
}
