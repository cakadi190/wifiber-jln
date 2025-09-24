import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class ImageHelper {
  static Future<Uint8List?> compressImage(
    File imageFile, {
    int quality = 85,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );

      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return null;

      final compressedBytes = byteData.buffer.asUint8List();

      if (compressedBytes.length > 500000) {
        final reductionFactor = (compressedBytes.length / 500000).ceil();
        final reducedBytes = <int>[];

        for (int i = 0; i < compressedBytes.length; i += reductionFactor) {
          reducedBytes.add(compressedBytes[i]);
        }

        return Uint8List.fromList(reducedBytes);
      }

      return compressedBytes;
    } catch (_) {
      try {
        final bytes = await imageFile.readAsBytes();

        if (bytes.length > 500000) {
          final reductionFactor = (bytes.length / 500000).ceil();
          final reducedBytes = <int>[];

          for (int i = 0; i < bytes.length; i += reductionFactor) {
            reducedBytes.add(bytes[i]);
          }

          return Uint8List.fromList(reducedBytes);
        }

        return bytes;
      } catch (_) {
        return null;
      }
    }
  }

  static Future<Size?> getImageSize(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (_) {
      return null;
    }
  }

  static Future<bool> needsCompression(
    File imageFile, {
    int maxSizeBytes = 500000,
  }) async {
    try {
      final length = await imageFile.length();
      return length > maxSizeBytes;
    } catch (_) {
      return false;
    }
  }

  static Future<Uint8List?> createThumbnail(
    File imageFile, {
    int thumbnailSize = 150,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: thumbnailSize,
        targetHeight: thumbnailSize,
      );

      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}
