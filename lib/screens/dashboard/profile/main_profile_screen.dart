import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/widgets/user_avatar.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/providers/auth_provider.dart';

class MainProfileScreen extends StatefulWidget {
  const MainProfileScreen({super.key});

  @override
  State<MainProfileScreen> createState() => _MainProfileScreenState();
}

class _MainProfileScreenState extends State<MainProfileScreen> {
  final ImagePicker _picker = ImagePicker();

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
                // Handle bar
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.primary,
              ),
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
    Navigator.pop(context); // Close modal
    try {
      // Add delay to ensure modal is closed properly
      await Future.delayed(Duration(milliseconds: 300));

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Handle the selected image here
        // You can call your upload function or update the user avatar
        _handleImageSelected(image);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      _showErrorSnackBar('Gagal memilih gambar dari galeri: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromCamera() async {
    Navigator.pop(context); // Close modal
    try {
      // Add delay to ensure modal is closed properly
      await Future.delayed(Duration(milliseconds: 300));

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Handle the captured image here
        // You can call your upload function or update the user avatar
        _handleImageSelected(image);
      }
    } catch (e) {
      print('Error picking image from camera: $e');
      _showErrorSnackBar('Gagal mengambil foto dari kamera: ${e.toString()}');
    }
  }

  void _handleImageSelected(XFile image) {
    // TODO: Implement image upload logic here
    // Example:
    // 1. Show loading indicator
    // 2. Upload image to server
    // 3. Update user profile
    // 4. Refresh UI

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gambar dipilih: ${image.name}'),
        backgroundColor: Colors.green,
      ),
    );

    print('Image selected: ${image.path}');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
            if (authProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
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
                                UserAvatar(
                                  imageUrl:
                                  user.picture ??
                                      'https://via.placeholder.com/150',
                                  name: user.name.isNotEmpty == true
                                      ? user.name.substring(0, 1).toUpperCase()
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
                                    onTap: _showImagePickerModal,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha:0.1),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: AppColors.primary,
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