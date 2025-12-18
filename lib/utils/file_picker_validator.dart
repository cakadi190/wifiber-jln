import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Konfigurasi validasi untuk file/gambar picker
class FilePickerConfig {
  /// Ekstensi file yang diizinkan (tanpa titik, misal: 'jpg', 'png')
  final List<String> allowedExtensions;

  /// Ukuran file maksimum dalam bytes
  final int maxFileSizeBytes;

  /// Label untuk tipe file (untuk pesan error)
  final String fileTypeLabel;

  /// Apakah file wajib dipilih
  final bool isRequired;

  const FilePickerConfig({
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    this.maxFileSizeBytes = 5 * 1024 * 1024, // Default 5MB
    this.fileTypeLabel = 'Gambar',
    this.isRequired = false,
  });

  /// Konfigurasi default untuk gambar
  static const FilePickerConfig imageDefault = FilePickerConfig(
    allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
    fileTypeLabel: 'Gambar',
  );

  /// Konfigurasi untuk dokumen (Excel, PDF, dll)
  static const FilePickerConfig documentDefault = FilePickerConfig(
    allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    maxFileSizeBytes: 10 * 1024 * 1024, // 10MB
    fileTypeLabel: 'Dokumen',
  );

  /// Konfigurasi untuk foto KTP
  static const FilePickerConfig ktpPhoto = FilePickerConfig(
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
    fileTypeLabel: 'Foto KTP',
    isRequired: false,
  );

  /// Konfigurasi untuk foto lokasi
  static const FilePickerConfig locationPhoto = FilePickerConfig(
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
    fileTypeLabel: 'Foto Lokasi',
    isRequired: false,
  );

  /// Konfigurasi untuk bukti pembayaran
  static const FilePickerConfig paymentProof = FilePickerConfig(
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
    fileTypeLabel: 'Bukti Pembayaran',
    isRequired: false,
  );

  /// Format ukuran file maksimum menjadi string yang mudah dibaca
  String get maxFileSizeFormatted {
    if (maxFileSizeBytes >= 1024 * 1024) {
      return '${(maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0)}MB';
    } else if (maxFileSizeBytes >= 1024) {
      return '${(maxFileSizeBytes / 1024).toStringAsFixed(0)}KB';
    }
    return '$maxFileSizeBytes bytes';
  }

  /// Daftar ekstensi yang diformat untuk ditampilkan
  String get allowedExtensionsFormatted {
    return allowedExtensions.map((e) => e.toUpperCase()).join(', ');
  }
}

/// Tipe-tipe error yang bisa terjadi saat memilih file
enum FilePickerErrorType {
  /// File tidak dipilih
  noFileSelected,

  /// Format file tidak didukung
  invalidFormat,

  /// Ukuran file melebihi batas
  fileTooLarge,

  /// File tidak ditemukan atau tidak dapat diakses
  fileNotAccessible,

  /// Izin akses ditolak (kamera/galeri)
  permissionDenied,

  /// Error tidak diketahui
  unknown,
}

/// Hasil validasi file picker
class FilePickerValidationResult {
  /// Apakah validasi berhasil
  final bool isValid;

  /// Tipe error (null jika valid)
  final FilePickerErrorType? errorType;

  /// Pesan error yang informatif untuk pengguna
  final String? errorMessage;

  /// File yang divalidasi (null jika tidak valid)
  final XFile? file;

  const FilePickerValidationResult._({
    required this.isValid,
    this.errorType,
    this.errorMessage,
    this.file,
  });

  /// Membuat hasil validasi sukses
  factory FilePickerValidationResult.success(XFile file) {
    return FilePickerValidationResult._(isValid: true, file: file);
  }

  /// Membuat hasil validasi gagal
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

/// Utility class untuk validasi file/gambar picker
class FilePickerValidator {
  FilePickerValidator._();

  /// Memvalidasi file yang dipilih
  ///
  /// [file] - File yang akan divalidasi (XFile dari image_picker)
  /// [config] - Konfigurasi validasi
  ///
  /// Returns [FilePickerValidationResult] yang berisi status validasi
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

  /// Validasi untuk File (dari dart:io)
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

  /// Mendapatkan ekstensi file dari path
  static String _getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1 || lastDot == path.length - 1) {
      return '';
    }
    return path.substring(lastDot + 1);
  }

  /// Format ukuran file menjadi string yang mudah dibaca
  static String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)}KB';
    }
    return '$bytes bytes';
  }

  /// Pesan error berdasarkan tipe error
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

/// Extension untuk menampilkan error dengan mudah
extension FilePickerValidationResultExtension on FilePickerValidationResult {
  /// Menampilkan snackbar error jika validasi gagal
  void showErrorIfInvalid(
    BuildContext context, {
    Color? backgroundColor,
    Duration? duration,
  }) {
    if (!isValid && errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                _getErrorIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: backgroundColor ?? Colors.red.shade600,
            duration: duration ?? const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
    }
  }

  /// Mendapatkan icon berdasarkan tipe error
  Icon _getErrorIcon() {
    switch (errorType) {
      case FilePickerErrorType.noFileSelected:
        return const Icon(Icons.add_photo_alternate, color: Colors.white);
      case FilePickerErrorType.invalidFormat:
        return const Icon(Icons.file_present, color: Colors.white);
      case FilePickerErrorType.fileTooLarge:
        return const Icon(Icons.storage, color: Colors.white);
      case FilePickerErrorType.fileNotAccessible:
        return const Icon(Icons.folder_off, color: Colors.white);
      case FilePickerErrorType.permissionDenied:
        return const Icon(Icons.lock, color: Colors.white);
      case FilePickerErrorType.unknown:
      case null:
        return const Icon(Icons.error_outline, color: Colors.white);
    }
  }
}

/// Mixin untuk form yang memiliki file/image picker dengan error handling
mixin FilePickerErrorMixin<T extends StatefulWidget> on State<T> {
  /// Map untuk menyimpan error validasi file per field
  final Map<String, String?> _fileValidationErrors = {};

  /// Mendapatkan error untuk field tertentu
  String? getFileError(String fieldName) => _fileValidationErrors[fieldName];

  /// Mengatur error untuk field tertentu
  void setFileError(String fieldName, String? error) {
    setState(() {
      if (error == null) {
        _fileValidationErrors.remove(fieldName);
      } else {
        _fileValidationErrors[fieldName] = error;
      }
    });
  }

  /// Membersihkan error untuk field tertentu
  void clearFileError(String fieldName) {
    setState(() {
      _fileValidationErrors.remove(fieldName);
    });
  }

  /// Membersihkan semua error file
  void clearAllFileErrors() {
    setState(() {
      _fileValidationErrors.clear();
    });
  }

  /// Apakah ada error pada field tertentu
  bool hasFileError(String fieldName) =>
      _fileValidationErrors.containsKey(fieldName) &&
      _fileValidationErrors[fieldName] != null;

  /// Memvalidasi dan mengatur error jika diperlukan
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
