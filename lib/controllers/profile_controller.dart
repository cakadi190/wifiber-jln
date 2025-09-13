import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/exceptions/string_exceptions.dart';
import 'package:wifiber/models/auth_user.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class ProfileController extends SafeChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final HttpService _httpService = HttpService();
  final AuthProvider _authProvider;

  File? _selectedImage;
  bool _isUploading = false;
  bool _isPickingImage = false;
  String? _uploadError;

  ProfileController({required AuthProvider authProvider})
    : _authProvider = authProvider;

  File? get selectedImage => _selectedImage;
  bool get isUploading => _isUploading;
  bool get isPickingImage => _isPickingImage;
  String? get uploadError => _uploadError;
  AuthProvider get authProvider => _authProvider;

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      _isPickingImage = true;
      _uploadError = null;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 300));

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _cropImage(image.path);
      }
    } catch (e) {
      _uploadError = 'Gagal memilih gambar: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isPickingImage = false;
      notifyListeners();
    }
  }

  Future<void> pickImageFromCamera() async {
    await pickImage(source: ImageSource.camera);
  }

  Future<void> pickImageFromGallery() async {
    await pickImage(source: ImageSource.gallery);
  }

  Future<void> _cropImage(String imagePath) async {
    try {
      if (!await File(imagePath).exists()) {
        throw Exception('File gambar tidak ditemukan');
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Gambar Profil',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            statusBarColor: AppColors.primary,
            backgroundColor: Colors.white,
            activeControlsWidgetColor: AppColors.primary,
            dimmedLayerColor: Colors.black.withValues(alpha: 0.8),
            cropFrameColor: AppColors.primary,
            cropGridColor: AppColors.primary.withValues(alpha: 0.5),
            cropFrameStrokeWidth: 2,
            cropGridStrokeWidth: 1,
            showCropGrid: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Gambar Profil',
            doneButtonTitle: 'Selesai',
            cancelButtonTitle: 'Batal',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            rotateClockwiseButtonHidden: false,
            rotateButtonsHidden: false,
            resetButtonHidden: false,
            aspectRatioLockDimensionSwapEnabled: false,
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      if (croppedFile != null) {
        final file = File(croppedFile.path);
        if (await file.exists()) {
          _selectedImage = file;
          _uploadError = null;
          notifyListeners();
        } else {
          throw Exception('Gagal memproses gambar yang dipotong');
        }
      }
    } catch (e) {
      _uploadError = 'Gagal memotong gambar. Coba gunakan gambar lain.';
      notifyListeners();
      throw Exception('Gagal memotong gambar. Coba gunakan gambar lain.');
    }
  }

  Future<void> uploadImage() async {
    if (_selectedImage == null) {
      _uploadError = 'Tidak ada gambar yang dipilih';
      notifyListeners();
      return;
    }

    final AuthUser user = _authProvider.user!;

    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      final multipartFile = await _httpService.createMultipartFile(
        'picture',
        _selectedImage!,
        filename:
            'profile_${user.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: 'image/jpeg',
      );

      final streamedResponse = await _httpService.postUpload(
        '/profiles/${user.userId}',
        files: [multipartFile],
        requiresAuth: true,
      );

      await _httpService.streamedResponseToResponse(streamedResponse);

      await _authProvider.reinitialize(force: true);
      _selectedImage = null;
      _uploadError = null;
      notifyListeners();
    } on ValidationException catch (e) {
      _uploadError = _formatValidationErrors(e);
      notifyListeners();
      rethrow;
    } on StringException catch (e) {
      _uploadError = e.message;
      notifyListeners();
      rethrow;
    } catch (e) {
      _uploadError = 'Gagal mengunggah gambar: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  String _formatValidationErrors(ValidationException exception) {
    final buffer = StringBuffer();
    buffer.writeln(exception.message);

    if (exception.errors.isNotEmpty) {
      buffer.writeln('\nDetail error:');
      exception.errors.forEach((field, messages) {
        if (messages is List) {
          for (final message in messages) {
            buffer.writeln('• $message');
          }
        } else if (messages is String) {
          buffer.writeln('• $messages');
        }
      });
    }

    return buffer.toString().trim();
  }

  Future<void> uploadImageWithProgress({
    Function(double progress)? onProgress,
  }) async {
    if (_selectedImage == null) {
      _uploadError = 'Tidak ada gambar yang dipilih';
      notifyListeners();
      return;
    }

    final AuthUser user = _authProvider.user!;

    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      final fileSize = await _selectedImage!.length();

      final multipartFile = await _httpService.createMultipartFile(
        'picture',
        _selectedImage!,
        filename:
            'profile_${user.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: 'image/jpeg',
      );

      final streamedResponse = await _httpService.postUpload(
        '/profiles/${user.userId}',
        files: [multipartFile],
        requiresAuth: true,
      );

      if (onProgress != null) {
        var uploaded = 0;
        streamedResponse.stream.listen((chunk) {
          uploaded += chunk.length;
          final progress = uploaded / fileSize;
          onProgress(progress.clamp(0.0, 1.0));
        });
      }

      await _httpService.streamedResponseToResponse(streamedResponse);

      await _authProvider.reinitialize(force: true);
      _selectedImage = null;
      _uploadError = null;

      if (onProgress != null) {
        onProgress(1.0);
      }

      notifyListeners();
    } on ValidationException catch (e) {
      _uploadError = _formatValidationErrors(e);
      notifyListeners();
      rethrow;
    } on StringException catch (e) {
      _uploadError = e.message;
      notifyListeners();
      rethrow;
    } catch (e) {
      _uploadError = 'Gagal mengunggah gambar: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void clearSelectedImage() {
    _selectedImage = null;
    _uploadError = null;
    notifyListeners();
  }

  void clearError() {
    _uploadError = null;
    notifyListeners();
  }

  Future<bool> isValidImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) return false;

      final fileSize = await imageFile.length();
      const maxSize = 5 * 1024 * 1024;

      if (fileSize > maxSize) {
        _uploadError = 'Ukuran file terlalu besar. Maksimal 5MB';
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      _uploadError = 'Gagal memvalidasi gambar: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> retryUpload() async {
    if (_selectedImage != null && !_isUploading) {
      await uploadImage();
    }
  }
}
