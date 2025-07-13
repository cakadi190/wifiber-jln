import 'package:flutter/material.dart';
import 'package:wifiber/controllers/change_password_controller.dart';

class PasswordMeterWidget extends StatelessWidget {
  final PasswordMeter? passwordMeter;
  final String password;

  const PasswordMeterWidget({
    super.key,
    required this.passwordMeter,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (passwordMeter == null || password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: passwordMeter!.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: passwordMeter!.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              passwordMeter!.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: passwordMeter!.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        _buildRequirements(theme),
      ],
    );
  }

  Widget _buildRequirements(ThemeData theme) {
    final requirements = [
      {'text': 'Minimal 8 karakter', 'isValid': password.length >= 8},
      {
        'text': 'Mengandung huruf kecil',
        'isValid': RegExp(r'[a-z]').hasMatch(password),
      },
      {
        'text': 'Mengandung huruf besar',
        'isValid': RegExp(r'[A-Z]').hasMatch(password),
      },
      {
        'text': 'Mengandung angka',
        'isValid': RegExp(r'[0-9]').hasMatch(password),
      },
      {
        'text': 'Mengandung simbol',
        'isValid': RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requirements.map((req) {
        final isValid = req['isValid'] as bool;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: isValid ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                req['text'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isValid ? Colors.green : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
