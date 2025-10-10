import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifiber/components/ui/snackbars.dart';

class AboutAppWebsiteTile extends StatelessWidget {
  const AboutAppWebsiteTile({super.key, required this.url});

  final Uri url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(RemixIcons.globe_line),
      title: const Text(
        'Website',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(url.toString()),
      onTap: () async {
        try {
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $url';
          }
        } catch (e) {
          if (context.mounted) {
            SnackBars.error(
              context,
              'Tidak dapat membuka website: $e',
            ).clearSnackBars();
          }
        }
      },
    );
  }
}
