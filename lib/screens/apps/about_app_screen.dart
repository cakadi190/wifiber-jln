import 'package:flutter/material.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/app_info_helper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/partials/apps/about_app_contact_list.dart';
import 'package:wifiber/partials/apps/about_app_header.dart';
import 'package:wifiber/partials/apps/about_app_website_tile.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  String copyrightText() {
    return 'Hak Cipta © ${DateTime.now().year} Wifiber oleh PT Jawara Lintas Nusantara. Hak cipta dilindungi undang-undang.';
  }

  String buildWithLove() {
    return "Made with ❤️ in Indonesia by PT Kodingin Digital Nusantara.";
  }

  @override
  Widget build(BuildContext context) {
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
              AboutAppHeader(
                versionFuture: AppInfo.getAppVersion(),
                copyrightText: copyrightText,
              ),
              Divider(color: Colors.grey[100]),
              const AboutAppContactList(),
              const SizedBox(height: 16),
              AboutAppWebsiteTile(url: Uri.parse('https://wifiber.web.id')),
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
