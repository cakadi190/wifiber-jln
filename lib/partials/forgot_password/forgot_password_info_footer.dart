import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';

class ForgotPasswordInfoFooter extends StatelessWidget {
  const ForgotPasswordInfoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Butuh bantuan?'),
            TextSpan(
              text: ' Silahkan Hubungi Kami di WhatsApp.',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
