import 'package:flutter/material.dart';
import 'package:wifiber/helpers/app_info_helper.dart';

enum LogoType { color, white, black }

class AppLogo extends StatefulWidget {
  const AppLogo({super.key, this.logoType, this.textColor});

  final LogoType? logoType;
  final Color? textColor;

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> {
  String _version = '1.0.0';
  late String _assetPath;
  late Color _textColor;

  @override
  void initState() {
    super.initState();
    AppInfo.getAppVersion().then((value) {
      setState(() {
        _version = value;
      });
    });

    if (widget.textColor != null) {
      _textColor = widget.textColor!;
    } else {
      switch (widget.logoType ?? LogoType.color) {
        case LogoType.color:
          _textColor = const Color(0xFF0F5D7F);
          break;
        case LogoType.white:
          _textColor = Colors.white;
          break;
        case LogoType.black:
          _textColor = Colors.black;
          break;
      }
    }

    switch (widget.logoType ?? LogoType.color) {
      case LogoType.color:
        _assetPath = 'assets/logo/logo-color.png';
        break;
      case LogoType.white:
        _assetPath = 'assets/logo/logo-white.png';
        break;
      case LogoType.black:
        _assetPath = 'assets/logo/logo-black.png';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset(_assetPath, width: 200),
        const SizedBox(height: 4),
        Text(
          "Versi $_version",
          style: appTheme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: _textColor,
          ),
        ),
      ],
    );
  }
}
