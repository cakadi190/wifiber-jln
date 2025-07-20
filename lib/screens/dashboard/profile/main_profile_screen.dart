import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/widgets/user_avatar.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/auth_user.dart';
import 'package:wifiber/providers/auth_provider.dart';

class MainProfileScreen extends StatefulWidget {
  const MainProfileScreen({super.key});

  @override
  State<MainProfileScreen> createState() => _MainProfileScreenState();
}

class _MainProfileScreenState extends State<MainProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _showImagePickerModal() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Pilih Gambar Profil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildImagePickerOption(
                            icon: Icons.photo_library,
                            label: 'Galeri',
                            onTap: () => _pickImageFromGallery(),
                          ),
                          _buildImagePickerOption(
                            icon: Icons.camera_alt,
                            label: 'Kamera',
                            onTap: () => _pickImageFromCamera(),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.primary),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
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
      _showErrorSnackBar('Gagal memilih gambar dari galeri: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _cropImage(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal mengambil foto dari kamera: ${e.toString()}');
    }
  }

  Future<void> _cropImage(String imagePath) async {
    try {
      if (!await File(imagePath).exists()) {
        _showErrorSnackBar('File gambar tidak ditemukan');
        return;
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
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 520, height: 520),
          ),
        ],
      );

      if (croppedFile != null) {
        final file = File(croppedFile.path);
        if (await file.exists()) {
          setState(() {
            _selectedImage = file;
          });

          await _showCropPreviewDialog();
        } else {
          _showErrorSnackBar('Gagal memproses gambar yang dipotong');
        }
      }
    } catch (e) {
      _showErrorSnackBar(
        'Gagal memotong gambar. Coba gunakan galeri atau ambil foto baru.',
      );
    }
  }

  Future<void> _showCropPreviewDialog() async {
    if (_selectedImage == null) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Gambar Profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Apakah Anda ingin menggunakan gambar ini sebagai foto profil?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                setState(() {
                  _selectedImage = null;
                });
              },
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Gunakan'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _handleImageUpload();
    } else {
      setState(() {
        _selectedImage = null;
      });
    }
  }

  Future<void> _handleImageUpload() async {
    if (_selectedImage == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final AuthUser user = auth.user!;
    final File? imagePath = _selectedImage;

    setState(() {
      _isUploading = true;
    });

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
        auth.reinitialize();

        _showSuccessSnackBar('Berhasil mengunggah gambar');
      } else if (response.statusCode == 422) {
        _showErrorSnackBar('Gagal mengunggah gambar');
        throw ValidationException(
          errors: jsonDecode(responseBody),
          message: 'Gagal mengunggah gambar',
        );
      } else {
        _showErrorSnackBar('Gagal mengunggah gambar');
        throw Exception('Gagal mengunggah gambar');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal mengunggah gambar: ${e.toString()}');
    } finally {
      setState(() {
        _selectedImage = null;
        _isUploading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(title: Text('Profil Saya')),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading || _isUploading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    if (_isUploading) ...[
                      SizedBox(height: 16),
                      Text(
                        'Mengupload gambar...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ],
                ),
              );
            }

            if (authProvider.user == null) {
              return Center(
                child: Text(
                  'Silakan login terlebih dahulu',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }

            final user = authProvider.user!;
            final token = authProvider.user!.accessToken;

            return SingleChildScrollView(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(512),
                          bottomRight: Radius.circular(512),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                _selectedImage != null
                                    ? Container(
                                        width: 96,
                                        height: 96,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : UserAvatar(
                                        imageUrl:
                                            user.picture ??
                                            'https://via.placeholder.com/150',
                                        name: user.name.isNotEmpty == true
                                            ? user.name
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                            : 'A',
                                        radius: 48,
                                        backgroundColor: Colors.black,
                                        headers: token.isNotEmpty
                                            ? {'Authorization': 'Bearer $token'}
                                            : {},
                                      ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: _isUploading
                                        ? null
                                        : _showImagePickerModal,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        _isUploading
                                            ? Icons.hourglass_empty
                                            : Icons.edit,
                                        size: 16,
                                        color: _isUploading
                                            ? Colors.grey[400]
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
