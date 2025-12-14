import 'package:flutter/material.dart';
import 'package:wifiber/config/app_colors.dart';

class OptionMenuItem {
  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;
  final Widget? trailing;

  OptionMenuItem({
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    required this.onTap,
    this.trailing,
  }) : assert(
         icon != null || leading != null,
         'Either icon or leading must be provided',
       );
}

Future<T?> showOptionModalBottomSheet<T>({
  required BuildContext context,
  Widget? header,
  required List<OptionMenuItem> items,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => SafeArea(
      top: false,
      bottom: true,
      child: _OptionModalContent(header: header, items: items),
    ),
  );
}

class _OptionModalContent extends StatelessWidget {
  final Widget? header;
  final List<OptionMenuItem> items;

  const _OptionModalContent({this.header, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (header != null)
            Padding(padding: const EdgeInsets.all(20), child: header),
          ...items.map((item) => _OptionItem(item)),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final OptionMenuItem item;
  const _OptionItem(this.item);

  @override
  Widget build(BuildContext context) {
    final Widget leading =
        item.leading ??
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (item.isDestructive ? Colors.red : AppColors.primary)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            color: item.isDestructive ? Colors.red : AppColors.primary,
            size: 20,
          ),
        );

    final Widget trailing =
        item.trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]);

    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: item.isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
