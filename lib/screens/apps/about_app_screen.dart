import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/app_info_helper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  String copyrightText() {
    return 'Hak Cipta © ${DateTime.now().year} Wifiber oleh PT Jawara Lintas Nusantara. Hak cipta dilindungi undang-undang.';
  }

  String buildWithLove() {
    return "Made with ❤️ & clean code in Indonesia by PT Kodingin Digital Nusantara.";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(title: const Text('Tentang Aplikasi')),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo-wifiber-png/logo-colorxxxhdpi.png',
                      width: 200,
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: AppInfo.getAppVersion(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            "Versi ${snapshot.data ?? 'Unknown'}",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      copyrightText(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Divider(color: Colors.grey[100]),
              const ListTile(
                leading: Icon(RemixIcons.map_pin_2_line),
                title: Text(
                  "Alamat",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Jalan Sahara Perum Kraksaan Land Nomor 49, Kebonagung, Kraksaan, Probolinggo, Jawa Timur",
                ),
              ),
              const ListTile(
                leading: Icon(RemixIcons.phone_line),
                title: Text(
                  "WhatsApp / Telepon",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("0853-3338-3432"),
              ),
              const ListTile(
                leading: Icon(RemixIcons.mail_line),
                title: Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("admin@jalidan.id"),
              ),

              ListTile(
                leading: Icon(RemixIcons.globe_line),
                title: Text(
                  "Website",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("https://jalidan.id"),
                onTap: () async {
                  final url = Uri.parse('https://jalidan.id');
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
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
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  buildWithLove(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
