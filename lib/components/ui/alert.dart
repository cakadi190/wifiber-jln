import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';

/// Enum untuk tipe alert yang menentukan warna dan styling
enum AlertType {
  primary,
  secondary,
  danger,
  info,
  success,
}

/// Widget Alert yang dapat dikustomisasi dengan berbagai style dan properti
///
/// Alert adalah komponen UI yang digunakan untuk menampilkan informasi penting
/// kepada pengguna dengan berbagai variasi style seperti solid, outlined,
/// opaque, dan plain.
///
/// Fitur:
/// - Empat variant style (solid, outlined, opaque, plain)
/// - Lima tipe warna (primary, secondary, danger, info, success)
/// - Support untuk disabled state
/// - Opsi full width
/// - Callback onClick yang dapat dikustomisasi
/// - Child widget yang fleksibel
class Alert extends StatelessWidget {
  /// Widget child yang akan ditampilkan di dalam alert
  final Widget child;

  /// Callback function yang dipanggil ketika alert diklik
  final VoidCallback? onClick;

  /// Status disabled untuk alert, jika true maka alert tidak dapat diklik
  final bool disabled;

  /// Menentukan apakah alert menggunakan full width dari parent
  final bool fullWidth;

  /// Tipe alert yang menentukan warna yang digunakan
  final AlertType type;

  /// Constructor untuk Alert dengan style solid (default)
  ///
  /// [child] Widget yang akan ditampilkan di dalam alert
  /// [onClick] Callback yang dipanggil saat alert diklik
  /// [disabled] Status disabled, default false
  /// [fullWidth] Apakah menggunakan full width, default false
  /// [type] Tipe alert, default AlertType.primary
  const Alert({
    super.key,
    required this.child,
    this.onClick,
    this.disabled = false,
    this.fullWidth = false,
    this.type = AlertType.primary,
  });

  /// Factory constructor untuk Alert dengan style solid
  ///
  /// [child] Widget yang akan ditampilkan di dalam alert
  /// [onClick] Callback yang dipanggil saat alert diklik
  /// [disabled] Status disabled, default false
  /// [fullWidth] Apakah menggunakan full width, default false
  /// [type] Tipe alert, default AlertType.primary
  factory Alert.solid({
    Key? key,
    required Widget child,
    VoidCallback? onClick,
    bool disabled = false,
    bool fullWidth = false,
    AlertType type = AlertType.primary,
  }) {
    return _AlertSolid(
      key: key,
      onClick: onClick,
      disabled: disabled,
      fullWidth: fullWidth,
      type: type,
      child: child,
    );
  }

  /// Factory constructor untuk Alert dengan style outlined
  ///
  /// [child] Widget yang akan ditampilkan di dalam alert
  /// [onClick] Callback yang dipanggil saat alert diklik
  /// [disabled] Status disabled, default false
  /// [fullWidth] Apakah menggunakan full width, default false
  /// [type] Tipe alert, default AlertType.primary
  factory Alert.outlined({
    Key? key,
    required Widget child,
    VoidCallback? onClick,
    bool disabled = false,
    bool fullWidth = false,
    AlertType type = AlertType.primary,
  }) {
    return _AlertOutlined(
      key: key,
      onClick: onClick,
      disabled: disabled,
      fullWidth: fullWidth,
      type: type,
      child: child,
    );
  }

  /// Factory constructor untuk Alert dengan style opaque
  ///
  /// [child] Widget yang akan ditampilkan di dalam alert
  /// [onClick] Callback yang dipanggil saat alert diklik
  /// [disabled] Status disabled, default false
  /// [fullWidth] Apakah menggunakan full width, default false
  /// [type] Tipe alert, default AlertType.primary
  factory Alert.opaque({
    Key? key,
    required Widget child,
    VoidCallback? onClick,
    bool disabled = false,
    bool fullWidth = false,
    AlertType type = AlertType.primary,
  }) {
    return _AlertOpaque(
      key: key,
      onClick: onClick,
      disabled: disabled,
      fullWidth: fullWidth,
      type: type,
      child: child,
    );
  }

  /// Factory constructor untuk Alert dengan style plain
  ///
  /// [child] Widget yang akan ditampilkan di dalam alert
  /// [onClick] Callback yang dipanggil saat alert diklik
  /// [disabled] Status disabled, default false
  /// [fullWidth] Apakah menggunakan full width, default false
  /// [type] Tipe alert, default AlertType.primary
  factory Alert.plain({
    Key? key,
    required Widget child,
    VoidCallback? onClick,
    bool disabled = false,
    bool fullWidth = false,
    AlertType type = AlertType.primary,
  }) {
    return _AlertPlain(
      key: key,
      onClick: onClick,
      disabled: disabled,
      fullWidth: fullWidth,
      type: type,
      child: child,
    );
  }

  /// Mendapatkan warna utama berdasarkan tipe alert
  ///
  /// Returns:
  /// - Colors.orange untuk AlertType.primary
  /// - Colors.grey untuk AlertType.secondary
  /// - Colors.red untuk AlertType.danger
  /// - Colors.blue untuk AlertType.info
  /// - Colors.green untuk AlertType.success
  Color _getColor() {
    switch (type) {
      case AlertType.primary:
        return AppColors.primary;
      case AlertType.secondary:
        return Colors.grey;
      case AlertType.danger:
        return Colors.red;
      case AlertType.info:
        return Colors.blue;
      case AlertType.success:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AlertSolid(
      onClick: onClick,
      disabled: disabled,
      fullWidth: fullWidth,
      type: type,
      child: child,
    );
  }
}

/// Implementation untuk Alert dengan style solid
/// Background penuh dengan warna sesuai tipe, text berwarna putih
class _AlertSolid extends Alert {
  const _AlertSolid({
    super.key,
    required super.child,
    super.onClick,
    super.disabled,
    super.fullWidth,
    super.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: disabled ? color.withAlpha(30) : color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : onClick,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: DefaultTextStyle(
              style: TextStyle(
                color: disabled ? Colors.white.withAlpha(70) : Colors.white,
                fontWeight: FontWeight.w500,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Implementation untuk Alert dengan style outlined
/// Border dengan warna sesuai tipe, background transparan, text dengan warna sesuai tipe
class _AlertOutlined extends Alert {
  const _AlertOutlined({
    super.key,
    required super.child,
    super.onClick,
    super.disabled,
    super.fullWidth,
    super.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : onClick,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: disabled ? color.withAlpha(30) : color,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: disabled ? color.withAlpha(30) : color,
                fontWeight: FontWeight.w500,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Implementation untuk Alert dengan style opaque
/// Background semi-transparan dengan warna sesuai tipe, text dengan warna sesuai tipe
class _AlertOpaque extends Alert {
  const _AlertOpaque({
    super.key,
    required super.child,
    super.onClick,
    super.disabled,
    super.fullWidth,
    super.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: disabled
            ? color.withValues(alpha: 0.5)
            : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : onClick,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: DefaultTextStyle(
              style: TextStyle(
                color: disabled ? color.withAlpha(30) : color,
                fontWeight: FontWeight.w500,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Implementation untuk Alert dengan style plain
/// Background transparan, text dengan warna sesuai tipe, tanpa border
class _AlertPlain extends Alert {
  const _AlertPlain({
    super.key,
    required super.child,
    super.onClick,
    super.disabled,
    super.fullWidth,
    super.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : onClick,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: DefaultTextStyle(
              style: TextStyle(
                color: disabled ? color.withAlpha(30) : color,
                fontWeight: FontWeight.w500,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}