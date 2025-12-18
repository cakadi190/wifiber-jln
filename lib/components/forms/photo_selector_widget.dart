import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:wifiber/components/reusables/image_preview.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/utils/file_picker_validator.dart';

enum PhotoType { ktp, location, paymentProof, profile, general }

class PhotoSelectorWidget extends StatefulWidget {
  final String title;

  final String subtitle;

  final PhotoType photoType;

  final XFile? selectedFile;

  final String? urlPreview;

  final ValueChanged<XFile?> onPhotoSelected;

  final ValueChanged<String>? onError;

  final FilePickerConfig? customConfig;

  final bool isRequired;

  final String? errorMessage;

  final bool isLoading;

  const PhotoSelectorWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.photoType,
    required this.onPhotoSelected,
    this.selectedFile,
    this.urlPreview,
    this.onError,
    this.customConfig,
    this.isRequired = false,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  State<PhotoSelectorWidget> createState() => _PhotoSelectorWidgetState();
}

class _PhotoSelectorWidgetState extends State<PhotoSelectorWidget> {
  final ImagePicker _picker = ImagePicker();
  String? _internalError;
  bool _isProcessing = false;

  FilePickerConfig get _config {
    if (widget.customConfig != null) return widget.customConfig!;

    switch (widget.photoType) {
      case PhotoType.ktp:
        return FilePickerConfig.ktpPhoto;
      case PhotoType.location:
        return FilePickerConfig.locationPhoto;
      case PhotoType.paymentProof:
        return FilePickerConfig.paymentProof;
      case PhotoType.profile:
        return const FilePickerConfig(
          allowedExtensions: ['jpg', 'jpeg', 'png'],
          maxFileSizeBytes: 2 * 1024 * 1024, // 2MB for profile
          fileTypeLabel: 'Foto Profil',
        );
      case PhotoType.general:
        return FilePickerConfig.imageDefault;
    }
  }

  IconData get _icon {
    switch (widget.photoType) {
      case PhotoType.ktp:
        return Icons.credit_card;
      case PhotoType.location:
        return Icons.location_on;
      case PhotoType.paymentProof:
        return Icons.receipt_long;
      case PhotoType.profile:
        return Icons.person;
      case PhotoType.general:
        return Icons.image;
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Format: ${_config.allowedExtensionsFormatted} (Maks. ${_config.maxFileSizeFormatted})',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('Ambil dengan Kamera'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_hasImage) ...[
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red.shade600),
                    title: const Text('Hapus Foto'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _removePhoto();
                    },
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _internalError = null;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (!mounted) return;

      if (image == null) {
        // User membatalkan pemilihan
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Validasi file
      final validationResult = await FilePickerValidator.validate(
        image,
        _config,
      );

      if (!mounted) return;

      if (!validationResult.isValid) {
        setState(() {
          _internalError = validationResult.errorMessage;
          _isProcessing = false;
        });
        validationResult.showErrorIfInvalid(context);
        widget.onError?.call(
          validationResult.errorMessage ?? 'Terjadi kesalahan',
        );
        return;
      }

      // Validasi berhasil
      setState(() {
        _internalError = null;
        _isProcessing = false;
      });
      widget.onPhotoSelected(image);
    } on Exception catch (e) {
      if (!mounted) return;

      String errorMessage = 'Gagal mengambil foto';

      if (e.toString().contains('permission')) {
        errorMessage =
            'Izin akses galeri/kamera ditolak. '
            'Silakan berikan izin di pengaturan aplikasi.';
      } else if (e.toString().contains('storage')) {
        errorMessage = 'Penyimpanan tidak mencukupi.';
      } else {
        errorMessage =
            'Gagal mengambil foto: ${e.toString().replaceAll('Exception: ', '')}';
      }

      setState(() {
        _internalError = errorMessage;
        _isProcessing = false;
      });

      widget.onError?.call(errorMessage);

      SnackBars.error(context, errorMessage);
    }
  }

  void _removePhoto() {
    setState(() {
      _internalError = null;
    });
    widget.onPhotoSelected(null);
  }

  bool get _hasImage {
    return widget.selectedFile != null ||
        (widget.urlPreview != null && widget.urlPreview!.isNotEmpty);
  }

  String? get _displayError {
    return widget.errorMessage ?? _internalError;
  }

  bool get _isLoading => widget.isLoading || _isProcessing;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final hasUrlPreview =
        widget.urlPreview != null && widget.urlPreview!.isNotEmpty;
    final hasSelectedFile = widget.selectedFile != null;
    final hasAnyImage = hasUrlPreview || hasSelectedFile;
    final hasError = _displayError != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: hasError ? Colors.red.shade400 : Colors.grey.shade300,
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: _isLoading ? null : _showImagePickerModal,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    _icon,
                    color: hasError ? Colors.red.shade600 : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: hasError ? Colors.red.shade700 : null,
                                ),
                              ),
                            ),
                            if (widget.isRequired)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Wajib',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (hasAnyImage)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    Icon(
                      Icons.add_a_photo,
                      color: hasError ? Colors.red.shade400 : Colors.grey,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Image Preview atau Placeholder
              if (hasAnyImage) ...[
                GestureDetector(
                  onTap: () {
                    if (hasUrlPreview) {
                      showImagePreview(
                        context,
                        imageUrl: widget.urlPreview,
                        headers: {
                          'Authorization':
                              'Bearer ${authProvider.user?.accessToken}',
                        },
                      );
                    } else if (hasSelectedFile) {
                      showImagePreview(
                        context,
                        imageFile: File(widget.selectedFile!.path),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: hasUrlPreview
                        ? Image.network(
                            widget.urlPreview!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            headers: {
                              'Authorization':
                                  'Bearer ${authProvider.user?.accessToken}',
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildErrorPlaceholder(
                                'Gagal memuat gambar',
                              );
                            },
                          )
                        : Image.file(
                            File(widget.selectedFile!.path),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildErrorPlaceholder(
                                'File tidak ditemukan',
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hasUrlPreview
                            ? path.basename(widget.urlPreview!)
                            : path.basename(widget.selectedFile!.path),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: hasError ? Colors.red.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasError
                          ? Colors.red.shade300
                          : Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 32,
                        color: hasError
                            ? Colors.red.shade400
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk untuk menambah foto',
                        style: TextStyle(
                          color: hasError
                              ? Colors.red.shade500
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Maks. ${_config.maxFileSizeFormatted}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Error Message
              if (hasError) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _displayError!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(String message) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.red.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
