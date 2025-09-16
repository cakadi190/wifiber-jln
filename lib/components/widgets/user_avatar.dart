import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final String? initials;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final Map<String, String>? headers;
  final VoidCallback? onTap;
  final Border? border;
  final double scale;
  final int? cacheWidth;
  final int? cacheHeight;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.initials,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.headers,
    this.onTap,
    this.border,
    this.scale = 1.0,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundImage = _getBackgroundImage();

    Widget avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        backgroundImage: backgroundImage,

        onBackgroundImageError:
            backgroundImage != null ? (exception, stackTrace) {} : null,
        child: backgroundImage == null ? _buildInitialsWidget(context) : null,
      ),
    );

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  ImageProvider? _getBackgroundImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return null;
    }

    try {
      return ResizeImage(
        NetworkImage(imageUrl!, headers: headers, scale: scale),
        width: cacheWidth ?? (radius * 2 * 2).toInt(),
        height: cacheHeight ?? (radius * 2 * 2).toInt(),
        allowUpscaling: false,
      );
    } catch (_) {
      return null;
    }
  }

  Widget _buildInitialsWidget(BuildContext context) {
    return Text(
      _getInitials(),
      style: TextStyle(
        color: textColor ?? Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: _getFontSize(),
      ),
    );
  }

  String _getInitials() {
    if (initials != null && initials!.trim().isNotEmpty) {
      return initials!.trim().toUpperCase();
    }

    if (name != null && name!.trim().isNotEmpty) {
      return _generateInitialsFromName(name!.trim());
    }

    return 'U';
  }

  String _generateInitialsFromName(String fullName) {
    if (fullName.isEmpty) return 'U';

    List<String> nameParts = fullName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (nameParts.isEmpty) return 'U';

    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }

    String firstInitial = nameParts[0][0].toUpperCase();
    String lastInitial = nameParts[nameParts.length - 1][0].toUpperCase();

    return firstInitial + lastInitial;
  }

  double _getFontSize() {
    if (radius <= 16) return radius * 0.5;
    if (radius <= 24) return radius * 0.6;
    if (radius <= 32) return radius * 0.65;
    return radius * 0.7;
  }
}
