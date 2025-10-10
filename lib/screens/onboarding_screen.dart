import 'package:flutter/material.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/helpers/network_helper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/screens/login_screen.dart';
import 'package:wifiber/services/first_launch_service.dart';
import 'package:wifiber/partials/onboarding/onboarding_page_content.dart';
import 'package:wifiber/partials/onboarding/onboarding_page_indicator.dart';

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
                    return OnboardingPageContent(
                      title: _onboardingTitle[index],
                      description: _onboardingDescription[index],
                      imagePath: _onboardingImage[index],
                      ipAddress: _ipAddress,
                      loadingIpAddress: _loadingIpAddress,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OnboardingPageIndicator(
                      length: _onboardingTitle.length,
                      currentIndex: _currentIndex,
                    ),
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
