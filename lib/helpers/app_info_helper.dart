import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static Future<String> getAppName() async {
    final info = await PackageInfo.fromPlatform();
    return info.appName;
  }

  static Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }
}
