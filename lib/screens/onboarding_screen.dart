import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/helpers/network_helper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/screens/login_screen.dart';
import 'package:wifiber/services/first_launch_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _ipAddress;
  bool _loadingIpAddress = true;
  int _currentIndex = 0;

  final PageController _pageController = PageController();

  final List<String> _onboardingTitle = [
    "Wifiber Apps",
    "Kelola Billing & Penagihan",
    "Manajemen Data Pelanggan",
    "Monitoring & Troubleshooting",
    "Laporan & Analisis",
    "Kontrol Akses & Bandwidth",
    "Aplikasi Siap Digunakan",
  ];

  final List<String> _onboardingDescription = [
    "Dashboard admin untuk mengelola sistem billing WiFi. Khusus untuk admin dan teknisi jaringan.",
    "Kelola penagihan bulanan, atur paket internet, dan pantau status pembayaran pelanggan.",
    "Tambah, edit, dan hapus data pelanggan. Atur paket berlangganan dan status akun.",
    "Monitor jaringan secara real-time, diagnosa masalah koneksi, dan lakukan troubleshooting.",
    "Generate laporan keuangan, analisis performa jaringan, dan statistik pelanggan.",
    "Kontrol akses internet pelanggan, atur bandwidth, dan blokir/unblok koneksi sesuai status billing.",
    "Semua tools admin sudah siap! Mulai kelola sistem billing WiFi Anda sekarang.",
  ];

  final List<String> _onboardingImage = [
    "assets/logo/logo-color.png",
    "assets/onboardings/payment.png",
    "assets/onboardings/customer.png",
    "assets/onboardings/monitoring.png",
    "assets/onboardings/report.png",
    "assets/onboardings/limit.png",
    "assets/onboardings/complete.png",
  ];

  @override
  void initState() {
    super.initState();
    _getPublicIp();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _getPublicIp() async {
    final ip = await NetworkHelper.getPublicIp();
    setState(() {
      _ipAddress = ip ?? 'Unknown';
      _loadingIpAddress = false;
    });
  }

  void _nextPage() {
    if (_currentIndex < _onboardingTitle.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingTitle.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _currentIndex == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(int index) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                _onboardingImage[index],
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  _onboardingTitle[index],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _onboardingDescription[index],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Skeletonizer(
                  enabled: _loadingIpAddress,
                  child: Text(
                    "Diakses dari $_ipAddress",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.light(
        statusBarColor: Colors.transparent,
        navigationBarColor: Colors.grey.shade100,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 60),
                    Text(
                      "${_currentIndex + 1} dari ${_onboardingTitle.length}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: _onCompleteAction,
                      child: const Text("Lewati"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingTitle.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(index);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPageIndicator(),
                    Center(
                      child: Row(
                        children: [
                          _currentIndex > 0
                              ? IconButton(
                                  onPressed: _prevPage,
                                  icon: const Icon(Icons.arrow_back_ios),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.grey.shade200,
                                    foregroundColor: Colors.grey.shade600,
                                    padding: const EdgeInsets.all(12),
                                  ),
                                )
                              : const SizedBox(width: 48),
                          const SizedBox(width: 12),
                          _currentIndex < _onboardingTitle.length - 1
                              ? IconButton(
                                  onPressed: _nextPage,
                                  icon: const Icon(Icons.arrow_forward_ios),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(12),
                                  ),
                                )
                              : IconButton(
                                  onPressed: _onCompleteAction,
                                  icon: const Icon(Icons.check),
                                  style: IconButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCompleteAction() {
    FirstLaunchService.setFirstLaunchStatus(false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (_) => false,
    );
  }
}
