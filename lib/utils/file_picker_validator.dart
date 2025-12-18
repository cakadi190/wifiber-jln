import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wifiber/components/ui/snackbars.dart';

class FilePickerConfig {
  final List<String> allowedExtensions;

  final int maxFileSizeBytes;

  final String fileTypeLabel;

  final bool isRequired;

  const FilePickerConfig({
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    this.maxFileSizeBytes = 5 * 1024 * 1024, // Default 5MB
    this.fileTypeLabel = 'Gambar',
    this.isRequired = false,
  });

  static const FilePickerConfig imageDefault = FilePickerConfig(
    allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
    fileTypeLabel: 'Gambar',
  );

  static const FilePickerConfig documentDefault = FilePickerConfig(
    allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    maxFileSizeBytes: 10 * 1024 * 1024, // 10MB
    fileTypeLabel: 'Dokumen',
  );

  static const FilePickerConfig ktpPhoto = FilePickerConfig(
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
    fileTypeLabel: 'Foto KTP',
    isRequired: false,
  );

  static const FilePickerConfig locationPhoto = FilePickerConfig(
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
    fileTypeLabel: 'Foto Lokasi',
    isRequired: false,
  );

  static const FilePickerConfig paymentProof = FilePickerConfig(
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
    fileTypeLabel: 'Bukti Pembayaran',
    isRequired: false,
  );

  String get maxFileSizeFormatted {
    if (maxFileSizeBytes >= 1024 * 1024) {
      return '${(maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0)}MB';
    } else if (maxFileSizeBytes >= 1024) {
      return '${(maxFileSizeBytes / 1024).toStringAsFixed(0)}KB';
    }
    return '$maxFileSizeBytes bytes';
  }

  String get allowedExtensionsFormatted {
    return allowedExtensions.map((e) => e.toUpperCase()).join(', ');
  }
}

enum FilePickerErrorType {
  noFileSelected,

  invalidFormat,

  fileTooLarge,

  fileNotAccessible,

  permissionDenied,

  unknown,
}

class FilePickerValidationResult {
  final bool isValid;

  final FilePickerErrorType? errorType;

  final String? errorMessage;

  final XFile? file;

  const FilePickerValidationResult._({
    required this.isValid,
    this.errorType,
    this.errorMessage,
    this.file,
  });

  factory FilePickerValidationResult.success(XFile file) {
    return FilePickerValidationResult._(isValid: true, file: file);
  }

  factory FilePickerValidationResult.failure({
    required FilePickerErrorType errorType,
    required String errorMessage,
  }) {
    return FilePickerValidationResult._(
      isValid: false,
      errorType: errorType,
      errorMessage: errorMessage,
    );
  }
}

class FilePickerValidator {
  FilePickerValidator._();

  ///

  ///

  static Future<FilePickerValidationResult> validate(
    XFile? file,
    FilePickerConfig config,
  ) async {
    // Validasi file tidak null
    if (file == null) {
      if (config.isRequired) {
        return FilePickerValidationResult.failure(
          errorType: FilePickerErrorType.noFileSelected,
          errorMessage:
              '${config.fileTypeLabel} wajib dipilih. '
              'Silakan pilih file terlebih dahulu.',
        );
      }
      // Jika tidak required, return null file tanpa error
      return const FilePickerValidationResult._(isValid: true);
    }

    // Validasi ekstensi file
    final extension = _getFileExtension(file.path);
    if (!config.allowedExtensions.contains(extension.toLowerCase())) {
      return FilePickerValidationResult.failure(
        errorType: FilePickerErrorType.invalidFormat,
        errorMessage:
            'Format file "${extension.toUpperCase()}" tidak didukung. '
            'Format yang diizinkan: ${config.allowedExtensionsFormatted}.',
      );
    }

    // Validasi ukuran file
    try {
      final fileSize = await file.length();
      if (fileSize > config.maxFileSizeBytes) {
        final actualSize = _formatFileSize(fileSize);
        return FilePickerValidationResult.failure(
          errorType: FilePickerErrorType.fileTooLarge,
          errorMessage:
              'Ukuran file ($actualSize) melebihi batas maksimum '
              '${config.maxFileSizeFormatted}. '
              'Silakan pilih file yang lebih kecil atau kompres file terlebih dahulu.',
        );
      }
    } catch (e) {
      return FilePickerValidationResult.failure(
        errorType: FilePickerErrorType.fileNotAccessible,
        errorMessage:
            'File tidak dapat diakses. '
            'Pastikan file masih ada dan tidak sedang digunakan oleh aplikasi lain.',
      );
    }

    // Validasi file bisa dibaca
    try {
      final exists = await File(file.path).exists();
      if (!exists) {
        return FilePickerValidationResult.failure(
          errorType: FilePickerErrorType.fileNotAccessible,
          errorMessage:
              'File tidak ditemukan. '
              'Silakan pilih file lain.',
        );
      }
    } catch (e) {
      return FilePickerValidationResult.failure(
        errorType: FilePickerErrorType.fileNotAccessible,
        errorMessage:
            'Tidak dapat mengakses file. '
            'Silakan coba pilih file lain.',
      );
    }

    return FilePickerValidationResult.success(file);
  }

  static Future<FilePickerValidationResult> validateFile(
    File? file,
    FilePickerConfig config,
  ) async {
    if (file == null) {
      if (config.isRequired) {
        return FilePickerValidationResult.failure(
          errorType: FilePickerErrorType.noFileSelected,
          errorMessage:
              '${config.fileTypeLabel} wajib dipilih. '
              'Silakan pilih file terlebih dahulu.',
        );
      }
      return const FilePickerValidationResult._(isValid: true);
    }

    // Konversi File ke XFile untuk konsistensi
    final xFile = XFile(file.path);
    return validate(xFile, config);
  }

  static String _getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1 || lastDot == path.length - 1) {
      return '';
    }
    return path.substring(lastDot + 1);
  }

  static String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)}KB';
    }
    return '$bytes bytes';
  }

  static String getErrorMessage(
    FilePickerErrorType errorType, {
    String? customFileTypeLabel,
    FilePickerConfig? config,
  }) {
    final fileLabel = customFileTypeLabel ?? config?.fileTypeLabel ?? 'File';

    switch (errorType) {
      case FilePickerErrorType.noFileSelected:
        return '$fileLabel wajib dipilih. Silakan pilih file terlebih dahulu.';
      case FilePickerErrorType.invalidFormat:
        final formats = config?.allowedExtensionsFormatted ?? 'yang didukung';
        return 'Format file tidak didukung. Format yang diizinkan: $formats.';
      case FilePickerErrorType.fileTooLarge:
        final maxSize = config?.maxFileSizeFormatted ?? '5MB';
        return 'Ukuran file melebihi batas maksimum $maxSize. '
            'Silakan pilih file yang lebih kecil.';
      case FilePickerErrorType.fileNotAccessible:
        return 'File tidak dapat diakses. Silakan pilih file lain.';
      case FilePickerErrorType.permissionDenied:
        return 'Izin akses ditolak. Silakan berikan izin di pengaturan aplikasi.';
      case FilePickerErrorType.unknown:
        return 'Terjadi kesalahan yang tidak diketahui saat memilih file.';
    }
  }
}

extension FilePickerValidationResultExtension on FilePickerValidationResult {
  void showErrorIfInvalid(BuildContext context) {
    if (!isValid && errorMessage != null) {
      SnackBars.error(context, errorMessage!);
    }
  }
}

mixin FilePickerErrorMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String?> _fileValidationErrors = {};

  String? getFileError(String fieldName) => _fileValidationErrors[fieldName];

  void setFileError(String fieldName, String? error) {
    setState(() {
      if (error == null) {
        _fileValidationErrors.remove(fieldName);
      } else {
        _fileValidationErrors[fieldName] = error;
      }
    });
  }

  void clearFileError(String fieldName) {
    setState(() {
      _fileValidationErrors.remove(fieldName);
    });
  }

  void clearAllFileErrors() {
    setState(() {
      _fileValidationErrors.clear();
    });
  }

  bool hasFileError(String fieldName) =>
      _fileValidationErrors.containsKey(fieldName) &&
      _fileValidationErrors[fieldName] != null;

  Future<bool> validateAndSetFileError(
    String fieldName,
    XFile? file,
    FilePickerConfig config, {
    bool showSnackbar = true,
  }) async {
    final result = await FilePickerValidator.validate(file, config);

    if (!result.isValid) {
      setFileError(fieldName, result.errorMessage);
      if (showSnackbar && mounted) {
        result.showErrorIfInvalid(context);
      }
      return false;
    }

    clearFileError(fieldName);
    return true;
  }
}
