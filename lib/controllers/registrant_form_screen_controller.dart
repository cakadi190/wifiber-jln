import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/registrant.dart';
import 'package:wifiber/providers/registrant_provider.dart';
import 'package:wifiber/services/registrant_service.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/services/location_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class RegistrantFormController extends SafeChangeNotifier {
  final HttpService _http = HttpService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController nicknameController;
  late TextEditingController phoneController;
  late TextEditingController identityNumberController;
  late TextEditingController addressController;
  late TextEditingController packageIdController;
  late TextEditingController routerIdController;
  late TextEditingController pppoeSecretController;
  late TextEditingController dueDateController;
  late TextEditingController odpIdController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  late TextEditingController discountController;

  String? ktpPhotoUrl;
  String? locationPhotoUrl;

  String? selectedPackageId;
  String? selectedPackageName;
  String? selectedAreaId;
  String? selectedAreaName;
  String? selectedRouterId;
  String? selectedRouterName;
  String? selectedOdpId;
  String? selectedOdpName;
  RegistrantStatus selectedStatus = RegistrantStatus.registrant;

  bool isLoading = false;
  bool isInitializing = false;
  bool isProrate = false;

  XFile? ktpPhotoFile;
  XFile? locationPhotoFile;

  RegistrantFormController() {
    _initControllers();
  }

  void _initControllers() {
    nameController = TextEditingController();
    nicknameController = TextEditingController();
    phoneController = TextEditingController();
    identityNumberController = TextEditingController();
    addressController = TextEditingController();
    packageIdController = TextEditingController();
    routerIdController = TextEditingController();
    pppoeSecretController = TextEditingController();
    dueDateController = TextEditingController();
    odpIdController = TextEditingController();
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();
    discountController = TextEditingController(text: '0');
  }

  void initializeWithRegistrant(Registrant? registrant) {
    if (registrant == null) return;

    nameController.text = registrant.name;
    nicknameController.text = registrant.nickname ?? '';
    phoneController.text = registrant.phone;
    identityNumberController.text = registrant.identityNumber;
    addressController.text = registrant.address;
    packageIdController.text = registrant.packageId;
    routerIdController.text = registrant.routerId ?? '';
    pppoeSecretController.text = registrant.pppoeSecret;
    dueDateController.text = registrant.dueDate;
    odpIdController.text = registrant.odpId ?? '';
    latitudeController.text = registrant.latitude ?? '';
    longitudeController.text = registrant.longitude ?? '';
    discountController.text = registrant.discount;
    isProrate = registrant.isProrate;

    ktpPhotoUrl = registrant.ktpPhoto?.isNotEmpty == true
        ? registrant.ktpPhoto
        : null;
    locationPhotoUrl = registrant.locationPhoto?.isNotEmpty == true
        ? registrant.locationPhoto
        : null;

    selectedStatus = _getStatusFromString(registrant.status);
    selectedPackageId = registrant.packageId;
    selectedAreaId = registrant.areaId;
    selectedRouterId = registrant.routerId;
    selectedOdpId = registrant.odpId;

    notifyListeners();
  }

  void setProrate(bool value) {
    isProrate = value;
    notifyListeners();
  }

  Future<void> initializeEditData() async {
    if (selectedPackageId == null &&
        selectedAreaId == null &&
        selectedRouterId == null &&
        selectedOdpId == null) {
      return;
    }

    isInitializing = true;
    notifyListeners();

    try {
      await Future.wait([
        if (selectedPackageId != null && selectedPackageId!.isNotEmpty)
          _fetchPackageName(selectedPackageId!),
        if (selectedAreaId != null && selectedAreaId!.isNotEmpty)
          _fetchAreaName(selectedAreaId!),
        if (selectedRouterId != null && selectedRouterId!.isNotEmpty)
          _fetchRouterName(selectedRouterId!),
        if (selectedOdpId != null && selectedOdpId!.isNotEmpty)
          _fetchOdpName(selectedOdpId!),
      ]);
    } catch (_) {
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPackageName(String packageId) async {
    try {
      final response = await _http.get('/packages', requiresAuth: true);
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        final List packages = jsonResponse['data'];
        final package = packages.firstWhere(
          (p) => p['id'] == packageId,
          orElse: () => null,
        );

        if (package != null) {
          selectedPackageName = package['name'];
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchAreaName(String areaId) async {
    try {
      final response = await _http.get('/areas', requiresAuth: true);
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        final List areas = jsonResponse['data'];
        final area = areas.firstWhere(
          (a) => a['id'] == areaId,
          orElse: () => null,
        );

        if (area != null) {
          selectedAreaName = area['name'];
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchRouterName(String routerId) async {
    try {
      final response = await _http.get('/routers', requiresAuth: true);
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        final List routers = jsonResponse['data'];
        final router = routers.firstWhere(
          (r) => r['id'] == routerId,
          orElse: () => null,
        );

        if (router != null) {
          selectedRouterName = router['name'];
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchOdpName(String odpId) async {
    try {
      final response = await _http.get('/odps', requiresAuth: true);
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        final List odps = jsonResponse['data'];
        final odp = odps.firstWhere(
          (o) => o['id'] == odpId,
          orElse: () => null,
        );

        if (odp != null) {
          selectedOdpName = odp['name'];
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  void onPackageSelected(dynamic package) {
    selectedPackageId = package.id;
    selectedPackageName = package.name;
    packageIdController.text = package.id;
    notifyListeners();
  }

  void onAreaSelected(dynamic area) {
    selectedAreaId = area.id;
    selectedAreaName = area.name;
    notifyListeners();
  }

  void onRouterSelected(dynamic router) {
    selectedRouterId = router.id;
    selectedRouterName = router.name;
    routerIdController.text = router.id;
    notifyListeners();
  }

  void onOdpSelected(dynamic odp) {
    selectedOdpId = odp.id;
    selectedOdpName = odp.name;
    odpIdController.text = odp.id;
    notifyListeners();
  }

  void onStatusChanged(RegistrantStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      dueDateController.text = DateHelper.format(selectedDate);
      notifyListeners();
    }
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  Future<void> pickImage(
    ImageSource source,
    BuildContext context, {
    required bool forKtp,
  }) async {
    if (source == ImageSource.camera) {
      bool granted = await _requestCameraPermission();
      if (!granted) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin kamera diperlukan untuk mengambil foto'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (!context.mounted) return;

      if (image != null) {
        if (forKtp) {
          ktpPhotoFile = image;
        } else {
          locationPhotoFile = image;
        }

        notifyListeners();
        Navigator.pop(context);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showImagePickerModal(BuildContext context, {required bool forKtp}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  forKtp ? 'Pilih Foto KTP' : 'Pilih Foto Lokasi',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () =>
                      pickImage(ImageSource.gallery, context, forKtp: forKtp),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('Ambil dengan Kamera'),
                  onTap: () =>
                      pickImage(ImageSource.camera, context, forKtp: forKtp),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> submitForm(
    BuildContext context, {
    required bool isEdit,
    Registrant? registrant,
    void Function(Map<String, dynamic> errors)? onValidationError,
  }) async {
    isLoading = true;
    notifyListeners();

    if (latitudeController.text.trim().isEmpty ||
        longitudeController.text.trim().isEmpty) {
      try {
        final current = await LocationService.getCurrentPosition();
        if (current != null) {
          latitudeController.text = current.latitude.toString();
          longitudeController.text = current.longitude.toString();
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        if (!context.mounted) return false;
        SnackBars.error(
          context,
          'Izin lokasi diperlukan untuk menambahkan data',
        ).clearSnackBars();
        return false;
      }
    }

    final registrantData = <String, dynamic>{
      'name': nameController.text.trim(),
      'nickname': nicknameController.text.trim(),
      'phone': phoneController.text.trim(),
      'identity-number': identityNumberController.text.trim().isEmpty
          ? '-'
          : identityNumberController.text.trim(),
      'address': addressController.text.trim(),
      'status': _getStatusString(selectedStatus),
      'package': (selectedPackageId?.isEmpty ?? true)
          ? null
          : selectedPackageId,
      'area': (selectedAreaId?.isEmpty ?? true) ? null : selectedAreaId,
      'router': (selectedRouterId?.isEmpty ?? true) ? null : selectedRouterId,
      'pppoe_secret': pppoeSecretController.text.trim(),
      'due-date': dueDateController.text.trim(),
      'odp': (selectedOdpId?.isEmpty ?? true) ? null : selectedOdpId,
      'discount': discountController.text.trim().isEmpty
          ? '0'
          : discountController.text.trim(),
      'is-prorate': isProrate.toString(),
    };

    if (latitudeController.text.trim().isNotEmpty &&
        longitudeController.text.trim().isNotEmpty) {
      registrantData['coordinate'] =
          '${latitudeController.text.trim()},${longitudeController.text.trim()}';
    }

    if (ktpPhotoFile != null) {
      registrantData['ktp-photo'] = ktpPhotoFile;
    }
    if (locationPhotoFile != null) {
      registrantData['location-photo'] = locationPhotoFile;
    }

    final provider = Provider.of<RegistrantProvider>(context, listen: false);
    bool success;

    try {
      if (isEdit && registrant != null) {
        success = await provider.updateRegistrant(registrant.id, registrantData);
      } else {
        success = await provider.createRegistrant(registrantData);
      }
    } on ValidationException catch (e) {
      isLoading = false;
      notifyListeners();
      onValidationError?.call(e.errors);
      if (!context.mounted) return false;
      SnackBars.error(context, e.message).clearSnackBars();
      return false;
    }

    isLoading = false;
    notifyListeners();

    if (!context.mounted) return false;

    if (success) {
      Navigator.of(context).pop(true);
      SnackBars.success(
        context,
        isEdit
            ? 'Data pelanggan berhasil diperbarui'
            : 'Data pelanggan berhasil ditambahkan',
      ).clearSnackBars();
      return true;
    } else {
      SnackBars.error(
        context,
        provider.error ??
            (isEdit
                ? 'Gagal memperbarui data pelanggan'
                : 'Gagal menambah data pelanggan'),
      ).clearSnackBars();
      return false;
    }
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  String? validateCoordinates(String? value, bool isLatitude) {
    final current = value?.trim() ?? '';
    final other = isLatitude
        ? longitudeController.text.trim()
        : latitudeController.text.trim();

    if ((current.isEmpty && other.isNotEmpty) ||
        (current.isNotEmpty && other.isEmpty)) {
      return 'Kedua koordinat harus diisi atau biarkan keduanya kosong';
    }
    return null;
  }

  String? validatePackageSelection() {
    if (selectedPackageId == null || selectedPackageId!.isEmpty) {
      return 'Paket internet wajib dipilih';
    }
    return null;
  }

  String? validateAreaSelection() {
    if (selectedAreaId == null || selectedAreaId!.isEmpty) {
      return 'Area wajib dipilih';
    }
    return null;
  }

  String? validateRouterSelection() {
    if (selectedRouterId == null || selectedRouterId!.isEmpty) {
      return 'Router wajib dipilih';
    }
    return null;
  }

  String? validateOdpSelection() {
    if (selectedOdpId == null || selectedOdpId!.isEmpty) {
      return 'ODP wajib dipilih';
    }
    return null;
  }

  RegistrantStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'registrant':
        return RegistrantStatus.registrant;
      case 'inactive':
        return RegistrantStatus.inactive;
      case 'free':
        return RegistrantStatus.free;
      case 'isolir':
        return RegistrantStatus.isolir;
      default:
        return RegistrantStatus.registrant;
    }
  }

  String _getStatusString(RegistrantStatus status) {
    return status.toString().split('.').last;
  }

  @override
  void dispose() {
    nameController.dispose();
    nicknameController.dispose();
    phoneController.dispose();
    identityNumberController.dispose();
    addressController.dispose();
    packageIdController.dispose();
    routerIdController.dispose();
    pppoeSecretController.dispose();
    dueDateController.dispose();
    odpIdController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    discountController.dispose();
    super.dispose();
  }
}
