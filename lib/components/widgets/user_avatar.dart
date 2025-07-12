import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wifiber/services/secure_storage_service.dart';

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

  /// Cache duration (default 7 hari)
  final Duration cacheDuration;

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
    this.cacheDuration = const Duration(days: 7),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primary,
        shape: BoxShape.circle,
        border: border,
      ),
      child: _buildAvatarContent(context),
    );

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  Widget _buildAvatarContent(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: _CachedNetworkImage(
          imageUrl: imageUrl!,
          width: radius * 2,
          height: radius * 2,
          headers: headers ?? {},
          cacheDuration: cacheDuration,
          placeholder: _buildLoadingWidget(),
          errorWidget: _buildInitialsWidget(context),
        ),
      );
    }

    return _buildInitialsWidget(context);
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: SizedBox(
        width: radius * 0.8,
        height: radius * 0.8,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor ?? Colors.white),
        ),
      ),
    );
  }

  Widget _buildInitialsWidget(BuildContext context) {
    return Center(
      child: Text(
        _getInitials(),
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: _getFontSize(),
        ),
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

class _CachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final Map<String, String> headers;
  final Duration cacheDuration;
  final Widget placeholder;
  final Widget errorWidget;

  const _CachedNetworkImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.headers,
    required this.cacheDuration,
    required this.placeholder,
    required this.errorWidget,
  });

  @override
  State<_CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<_CachedNetworkImage> {
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final cachedImage = await _getCachedImage(widget.imageUrl);
      if (cachedImage != null) {
        setState(() {
          _imageData = cachedImage;
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(widget.imageUrl),
        headers: widget.headers,
      );

      if (response.statusCode == 200) {
        final imageData = response.bodyBytes;

        await _cacheImage(widget.imageUrl, imageData);

        setState(() {
          _imageData = imageData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _cacheImage(String url, Uint8List imageData) async {
    try {
      await SecureStorageService.cacheAvatarByUrl(url, imageData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
    }
  }

  Future<Uint8List?> _getCachedImage(String url) async {
    try {
      return await SecureStorageService.getCachedAvatarByUrl(
        url,
        maxAge: widget.cacheDuration,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder;
    }

    if (_hasError || _imageData == null) {
      return widget.errorWidget;
    }

    return Image.memory(
      _imageData!,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
    );
  }
}

// Utility class untuk clear cache (deprecated - use SecureStorageService instead)
class AvatarCacheManager {
  /// Clear semua avatar cache
  static Future<void> clearCache() async {
    await SecureStorageService.clearAllAvatarCache();
  }

  /// Clear expired cache
  static Future<void> clearExpiredCache() async {
    await SecureStorageService.clearExpiredAvatarCache();
  }

  /// Get cache size in MB
  static Future<double> getCacheSize() async {
    return await SecureStorageService.getAvatarCacheSize();
  }

  /// Cache avatar untuk user tertentu
  static Future<void> cacheUserAvatar(
    String userId,
    Uint8List imageData,
  ) async {
    await SecureStorageService.cacheUserAvatar(userId, imageData);
  }

  /// Get cached avatar untuk user tertentu
  static Future<Uint8List?> getUserAvatar(
    String userId, {
    Duration? maxAge,
  }) async {
    return await SecureStorageService.getUserAvatar(userId, maxAge: maxAge);
  }

  /// Clear avatar untuk user tertentu
  static Future<void> clearUserAvatar(String userId) async {
    await SecureStorageService.clearUserAvatar(userId);
  }
}
