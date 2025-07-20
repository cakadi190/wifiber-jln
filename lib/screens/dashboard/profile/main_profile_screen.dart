import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/widgets/user_avatar.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/profile_controller.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/screens/dashboard/profile/edit_profile_screen.dart';

class MainProfileScreen extends StatefulWidget {
  const MainProfileScreen({super.key});

  @override
  State<MainProfileScreen> createState() => _MainProfileScreenState();
}

class _MainProfileScreenState extends State<MainProfileScreen> {
  late ProfileController _profileController;

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _profileController = ProfileController(authProvider: authProvider);
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

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
      Navigator.pop(context);
      await _profileController.pickImageFromGallery();
      await _showCropPreviewDialog();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      Navigator.pop(context);
      await _profileController.pickImageFromCamera();
      await _showCropPreviewDialog();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _showCropPreviewDialog() async {
    if (_profileController.selectedImage == null) return;

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
                  child: Image.file(
                    _profileController.selectedImage!,
                    fit: BoxFit.cover,
                  ),
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
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Gunakan'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        _profileController.clearSelectedImage();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _handleImageUpload();
    } else {
      _profileController.clearSelectedImage();
    }
  }

  Future<void> _handleImageUpload() async {
    try {
      await _profileController.uploadImage();
      _showSuccessSnackBar('Berhasil mengunggah gambar');
    } catch (e) {
      _showErrorSnackBar('Gagal mengunggah gambar: ${e.toString()}');
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
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: _profileController)],
      child: Consumer<ProfileController>(
        builder: (context, profileController, child) {
          return SystemUiWrapper(
            style: SystemUiHelper.duotone(
              statusBarColor: AppColors.primary,
              navigationBarColor: profileController.isUploading
                  ? AppColors.primary
                  : Colors.white,
            ),
            child: Scaffold(
              backgroundColor: AppColors.primary,
              appBar: AppBar(title: Text('Profil Saya')),
              body: Consumer2<AuthProvider, ProfileController>(
                builder: (context, authProvider, profileController, child) {
                  if (authProvider.isLoading || profileController.isUploading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          if (profileController.isUploading) ...[
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
                          // Profile Header
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
                                      profileController.selectedImage != null
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
                                            profileController
                                                .selectedImage!,
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
                                            ? {
                                          'Authorization':
                                          'Bearer $token',
                                        }
                                            : {},
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: profileController.isUploading
                                              ? null
                                              : _showImagePickerModal,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            padding: EdgeInsets.all(8),
                                            child: Icon(
                                              profileController.isUploading
                                                  ? Icons.hourglass_empty
                                                  : Icons.edit,
                                              size: 16,
                                              color:
                                              profileController.isUploading
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

                          SizedBox(height: 16),

                          // Profile Items - Fixed the ListView issue
                          Column(
                            children: [
                              _buildProfileItem(
                                ListTileItem(
                                  title: 'Nama',
                                  subtitle: user.name,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfileScreen(
                                              formLabel: 'Nama',
                                              formName: 'name',
                                              value: user.name,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              _buildProfileItem(
                                ListTileItem(
                                  title: 'Nama Pengguna',
                                  subtitle: user.username,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfileScreen(
                                              formLabel: 'Nama Pengguna',
                                              formName: 'username',
                                              value: user.username,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              _buildProfileItem(
                                ListTileItem(
                                  title: 'Surel',
                                  subtitle: user.email,
                                ),
                              ),
                              _buildProfileItem(
                                ListTileItem(
                                  title: 'Peran Anda',
                                  subtitle: user.groupName ?? 'Pengguna Biasa',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(ListTileItem item) {
    return ListTile(
      title: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(item.subtitle),
      trailing: item.onTap == null ? null : Icon(Icons.chevron_right),
      onTap: item.onTap,
    );
  }
}

class ListTileItem {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  ListTileItem({required this.title, required this.subtitle, this.onTap});
}