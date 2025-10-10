import 'package:flutter/material.dart';

class AboutAppHeader extends StatelessWidget {
  const AboutAppHeader({
    super.key,
    required this.versionFuture,
    required this.copyrightText,
  });

  final Future<String> versionFuture;
  final String Function() copyrightText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Image.asset('assets/logo/logo-color.png', width: 200),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: versionFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  'Versi ${snapshot.data ?? 'Unknown'}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Text('Versi tidak tersedia');
              }

              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 16),
          Text(
            copyrightText(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
