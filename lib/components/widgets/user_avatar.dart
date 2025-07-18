import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  /// URL gambar avatar
  final String? imageUrl;

  /// Nama untuk generate initials
  final String? name;

  /// Custom initials (override name)
  final String? initials;

  /// Ukuran radius avatar
  final double radius;

  /// Warna background
  final Color? backgroundColor;

  /// Warna text initials
  final Color? textColor;

  /// Headers untuk network request (misal: Authorization)
  final Map<String, String>? headers;

  /// Callback ketika avatar di-tap
  final VoidCallback? onTap;

  /// Border untuk avatar
  final Border? border;

  /// Scale untuk image (default 1.0)
  final double scale;

  /// Cache width untuk optimasi memory
  final int? cacheWidth;

  /// Cache height untuk optimasi memory
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

    Widget avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        backgroundImage: _getBackgroundImage(),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle error jika gambar gagal load
          debugPrint('Avatar image failed to load: $exception');
        },
        child: _getBackgroundImage() == null ? _buildInitialsWidget(context) : null,
      ),
    );

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  ImageProvider? _getBackgroundImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ResizeImage(
        NetworkImage(
          imageUrl!,
          headers: headers,
          scale: scale,
        ),
        width: cacheWidth ?? (radius * 2 * 2).toInt(), // 2x untuk density
        height: cacheHeight ?? (radius * 2 * 2).toInt(),
        allowUpscaling: false,
      );
    }
    return null;
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
    if (initials != null && initials!.isNotEmpty) {
      return initials!.toUpperCase();
    }

    if (name != null && name!.isNotEmpty) {
      return _generateInitialsFromName(name!);
    }

    return 'U';
  }

  String _generateInitialsFromName(String fullName) {
    List<String> nameParts = fullName.trim().split(' ');

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