import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                            SizedBox(height: 16),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Ubah Gambar', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
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
