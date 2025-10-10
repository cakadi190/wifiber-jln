import 'package:flutter/material.dart';
import 'package:wifiber/components/ui/alert.dart';

class ChangePasswordInfo extends StatelessWidget {
  const ChangePasswordInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Alert.opaque(
      fullWidth: true,
      type: AlertType.info,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: Colors.blue, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubah Kata Sandi',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kata sandi minimal 8 karakter, termasuk huruf besar, huruf kecil, angka, dan simbol. Dan pastikan kata sandi yang anda buat dapat anda dapat diingat dengan baik.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blue.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
