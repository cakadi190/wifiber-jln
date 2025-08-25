import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/models/auth_user.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class ProfileController extends SafeChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final AuthProvider _authProvider;

  File? _selectedImage;
  bool _isUploading = false;

  ProfileController({required AuthProvider authProvider})
    : _authProvider = authProvider;

  File? get selectedImage => _selectedImage;

  bool get isUploading => _isUploading;

  AuthProvider get authProvider => _authProvider;

  Future<void> pickImage() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _cropImage(image.path);
      }
    } catch (e) {
      throw Exception('Gagal memilih gambar: ${e.toString()}');
    }
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
          notifyListeners();
        } else {
          throw Exception('Gagal memproses gambar yang dipotong');
        }
      }
    } catch (e) {
      throw Exception('Gagal memotong gambar. Coba gunakan gambar lain.');
    }
  }

  Future<void> uploadImage() async {
    if (_selectedImage == null) return;

    final AuthUser user = _authProvider.user!;
    final File? imagePath = _selectedImage;

    _isUploading = true;
    notifyListeners();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://wifiber.web.id/api/v1/profiles/${user.userId}'),
      );
      request.headers['Authorization'] = 'Bearer ${user.accessToken}';
      request.files.add(
        await http.MultipartFile.fromPath('picture', imagePath!.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        await _authProvider.reinitialize(force: true);
        _selectedImage = null;
        notifyListeners();
      } else if (response.statusCode == 422) {
        throw ValidationException(
          errors: jsonDecode(responseBody),
          message: 'Gagal mengunggah gambar',
        );
      } else {
        throw Exception('Gagal mengunggah gambar');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }
}
