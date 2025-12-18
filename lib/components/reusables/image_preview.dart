import 'dart:io';

import 'package:flutter/material.dart';

void showImagePreview(
  BuildContext context, {
  String? imageUrl,
  File? imageFile,
  Map<String, String>? headers,
}) {
  if (imageUrl == null && imageFile == null) {
    return;
  }

  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (_) {
      Widget imageWidget;
      if (imageUrl != null) {
        imageWidget = Image.network(
          imageUrl,
          headers: headers,
          fit: BoxFit.contain,
        );
      } else {
        imageWidget = Image.file(imageFile!, fit: BoxFit.contain);
      }

      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: InteractiveViewer(child: imageWidget),
        ),
      );
    },
  );
}
