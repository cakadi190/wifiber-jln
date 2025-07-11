import 'package:flutter/material.dart';

/// **SnackBars**
///
/// A comprehensive and reusable SnackBar component that provides consistent
/// styling and behavior across your Flutter application. This utility class
/// offers predefined styles for different message types with custom color schemes
/// that are independent of the Material Theme and features solid backgrounds.
///
/// ## Features
/// - **Six predefined types**: success, error, warning, info, dark, primary
/// - **Custom color schemes**: Fixed colors independent of Material Theme
/// - **Solid backgrounds**: Opaque backgrounds for maximum visibility
/// - **Flexible content**: Supports String text or custom Widget content
/// - **Responsive design**: Automatically handles text overflow and wrapping
/// - **Chain methods**: Optional method chaining for clearing existing SnackBars
/// - **Consistent behavior**: Floating behavior with proper positioning
/// - **Dark/Light compatibility**: Colors optimized for both theme modes
/// - **High contrast**: Solid colors for better readability
///
/// ## Usage Examples
///
/// ### Basic Usage
/// ```dart
/// SnackBars.success(context, "Operation completed successfully!");
///
/// SnackBars.error(context, Row(
///   children: [
///     Icon(Icons.warning),
///     SizedBox(width: 8),
///     Text("Custom error message"),
///   ],
/// ));
/// ```
///
/// ### Method Chaining
/// ```dart
/// SnackBars.warning(context, "This is a warning")
///   .clearSnackBars();
///
/// SnackBars.info(context, "Information message");
/// ```
///
/// ### All Available Types
/// ```dart
/// SnackBars.success(context, "Success message");
/// SnackBars.error(context, "Error message");
/// SnackBars.warning(context, "Warning message");
/// SnackBars.info(context, "Info message");
/// SnackBars.dark(context, "Dark themed message");
/// SnackBars.primary(context, "Primary themed message");
/// ```
///
/// ## Color Schemes
/// - **Success**: Green theme (#4CAF50) with solid background
/// - **Error**: Red theme (#F44336) with solid background
/// - **Warning**: Orange theme (#FF9800) with solid background
/// - **Info**: Blue theme (#2196F3) with solid background
/// - **Dark**: Dark theme (#424242) with solid background
/// - **Primary**: Purple theme (#9C27B0) with solid background
///
/// ## Design Considerations
/// - Uses floating behavior with solid backgrounds for maximum visibility
/// - Custom color palette with full opacity for high contrast
/// - Automatically handles text overflow with proper wrapping
/// - Icons are contextually chosen based on message type
/// - Duration is set to 4 seconds for better readability
/// - High contrast colors for accessibility compliance
/// - Modern solid design aesthetic
class SnackBars {
  SnackBars._();

  static BuildContext? _context;

  static SnackBars success(BuildContext context, dynamic content) {
    _context = context;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final snackBar = _createSnackBar(
      context: context,
      content: content,
      backgroundColor: isDark ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50),
      borderColor: isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32),
      icon: Icons.check_circle,
      iconColor: Colors.white,
      textColor: Colors.white,
    );

    _pendingSnackBar = snackBar;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    return SnackBars._();
  }

  static SnackBars error(BuildContext context, dynamic content) {
    _context = context;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final snackBar = _createSnackBar(
      context: context,
      content: content,
      backgroundColor: isDark ? const Color(0xFFD32F2F) : const Color(0xFFF44336),
      borderColor: isDark ? const Color(0xFFF44336) : const Color(0xFFD32F2F),
      icon: Icons.error,
      iconColor: Colors.white,
      textColor: Colors.white,
    );

    _pendingSnackBar = snackBar;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    return SnackBars._();
  }

  static SnackBars warning(BuildContext context, dynamic content) {
    _context = context;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final snackBar = _createSnackBar(
      context: context,
      content: content,
      backgroundColor: isDark ? const Color(0xFFF57C00) : const Color(0xFFFF9800),
      borderColor: isDark ? const Color(0xFFFF9800) : const Color(0xFFF57C00),
      icon: Icons.warning,
      iconColor: Colors.white,
      textColor: Colors.white,
    );

    _pendingSnackBar = snackBar;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    return SnackBars._();
  }

  static SnackBars info(BuildContext context, dynamic content) {
    _context = context;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final snackBar = _createSnackBar(
      context: context,
      content: content,
      backgroundColor: isDark ? const Color(0xFF1976D2) : const Color(0xFF2196F3),
      borderColor: isDark ? const Color(0xFF2196F3) : const Color(0xFF1976D2),
      icon: Icons.info,
      iconColor: Colors.white,
      textColor: Colors.white,
    );

    _pendingSnackBar = snackBar;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    return SnackBars._();
  }

  static SnackBars dark(BuildContext context, dynamic content) {
    _context = context;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final snackBar = _createSnackBar(
      context: context,
      content: content,
      backgroundColor: isDark ? const Color(0xFF616161) : const Color(0xFF424242),
      borderColor: isDark ? const Color(0xFF424242) : const Color(0xFF212121),
      icon: Icons.circle_notifications,
      iconColor: Colors.white,
      textColor: Colors.white,
    );

    _pendingSnackBar = snackBar;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    return SnackBars._();
  }

  static SnackBars primary(BuildContext context, dynamic content) {
    _context = context;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final snackBar = _createSnackBar(
      context: context,
      content: content,
      backgroundColor: isDark ? const Color(0xFF7B1FA2) : const Color(0xFF9C27B0),
      borderColor: isDark ? const Color(0xFF9C27B0) : const Color(0xFF7B1FA2),
      icon: Icons.star,
      iconColor: Colors.white,
      textColor: Colors.white,
    );

    _pendingSnackBar = snackBar;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    return SnackBars._();
  }

  void clearSnackBars() {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).removeCurrentSnackBar();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_pendingSnackBar != null && _context != null) {
          ScaffoldMessenger.of(_context!).showSnackBar(_pendingSnackBar!);
          _pendingSnackBar = null;
        }
      });
    }
  }

  static SnackBar? _pendingSnackBar;

  static SnackBar _createSnackBar({
    required BuildContext context,
    required dynamic content,
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
  }) {
    Widget contentWidget;

    if (content is String) {
      contentWidget = Text(
        content,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      );
    } else if (content is Widget) {
      contentWidget = content;
    } else {
      contentWidget = Text(
        content.toString(),
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      );
    }

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 4),
      content: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: contentWidget,
            ),
          ],
        ),
      ),
    );
  }
}