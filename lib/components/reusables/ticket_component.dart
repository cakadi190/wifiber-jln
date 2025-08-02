import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final DecorationImage? backgroundImage;

  const SummaryCard({
    super.key,
    required this.title,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        image: backgroundImage,
      ),
      child: Column(
        children: [
          if (title.isNotEmpty) _buildHeader(context),
          Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 0, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (onTap != null)
            IconButton(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
        ],
      ),
    );
  }
}

class StateBuilder<T> extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final T? data;
  final Widget Function() loadingBuilder;
  final Widget Function(String error) errorBuilder;
  final Widget Function() emptyBuilder;
  final Widget Function(T data) dataBuilder;
  final bool Function(T? data)? isEmpty;

  const StateBuilder({
    super.key,
    required this.isLoading,
    this.error,
    this.data,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.emptyBuilder,
    required this.dataBuilder,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingBuilder();
    }

    if (error != null) {
      return errorBuilder(error!);
    }

    final isDataEmpty = isEmpty?.call(data ?? (T as dynamic)) ?? (data == null);
    if (isDataEmpty) {
      return emptyBuilder();
    }

    return dataBuilder(data ?? (T as dynamic));
  }
}

class DefaultStates {
  static Widget loading({Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
        ),
      ),
    );
  }

  static Widget error({
    required String message,
    VoidCallback? onRetry,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: textColor ?? Colors.red.shade700,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Error: $message',
            style: TextStyle(
              color: textColor ?? Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: textColor ?? Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  static Widget empty({
    required String message,
    IconData? icon,
    Color? iconColor,
    Color? textColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Icons.info, color: iconColor ?? Colors.grey, size: 48),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: textColor ?? Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
