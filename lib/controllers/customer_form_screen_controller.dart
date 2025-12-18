import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/providers/customer_provider.dart';
import 'package:wifiber/services/customer_service.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/services/location_service.dart';
import 'package:wifiber/utils/file_picker_validator.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class CustomerFormController extends SafeChangeNotifier {
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
  CustomerStatus selectedStatus = CustomerStatus.customer;

  bool isLoading = false;
  bool isInitializing = false;

  XFile? ktpPhotoFile;
  XFile? locationPhotoFile;

  CustomerFormController() {
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

  void initializeWithCustomer(Customer? customer) {
    if (customer == null) return;

    nameController.text = customer.name;
    nicknameController.text = customer.nickname ?? '';
    phoneController.text = customer.phone;
    identityNumberController.text = customer.identityNumber;
    addressController.text = customer.address;
    packageIdController.text = customer.packageId;
    routerIdController.text = customer.routerId ?? '';
    pppoeSecretController.text = customer.pppoeSecret;
    dueDateController.text = customer.dueDate;
    odpIdController.text = customer.odpId ?? '';
    latitudeController.text = customer.latitude ?? '';
    longitudeController.text = customer.longitude ?? '';
    discountController.text = customer.discount;

    ktpPhotoUrl = customer.ktpPhoto?.isNotEmpty == true
        ? customer.ktpPhoto
        : null;
    locationPhotoUrl = customer.locationPhoto?.isNotEmpty == true
        ? customer.locationPhoto
        : null;

    selectedStatus = _getStatusFromString(customer.status);
    selectedPackageId = customer.packageId;
    selectedAreaId = customer.areaId;
    selectedRouterId = customer.routerId;
    selectedOdpId = customer.odpId;

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

  void onStatusChanged(CustomerStatus status) {
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
        SnackBars.error(
          context,
          'Izin kamera diperlukan untuk mengambil foto. '
          'Silakan aktifkan izin kamera di pengaturan.',
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

      if (image == null) {
        // User membatalkan pemilihan, tidak perlu tampilkan error
        return;
      }

      // Validasi file menggunakan FilePickerValidator
      final config = forKtp
          ? FilePickerConfig.ktpPhoto
          : FilePickerConfig.locationPhoto;

      final validationResult = await FilePickerValidator.validate(
        image,
        config,
      );

      if (!context.mounted) return;

      if (!validationResult.isValid) {
        // Tampilkan error dengan snackbar yang informatif
        validationResult.showErrorIfInvalid(context);
        Navigator.pop(context);
        return;
      }

      // Validasi berhasil, simpan file
      if (forKtp) {
        ktpPhotoFile = image;
      } else {
        locationPhotoFile = image;
      }

      notifyListeners();
      Navigator.pop(context);
    } on Exception catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);

      String errorMessage = 'Gagal mengambil foto';

      // Handle specific exceptions
      if (e.toString().contains('permission')) {
        errorMessage =
            'Izin akses galeri/kamera ditolak. '
            'Silakan berikan izin di pengaturan aplikasi.';
      } else if (e.toString().contains('storage')) {
        errorMessage =
            'Penyimpanan tidak mencukupi. '
            'Silakan kosongkan beberapa ruang penyimpanan.';
      } else {
        errorMessage =
            'Gagal mengambil foto: ${e.toString().replaceAll('Exception: ', '')}';
      }

      SnackBars.error(context, errorMessage);
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
          top: false,
          bottom: true,
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
    Customer? customer,
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

    final customerData = <String, dynamic>{
      'name': nameController.text.trim(),
      'nickname': nicknameController.text.trim(),
      'phone': phoneController.text.trim(),
      'ktp': identityNumberController.text.trim().isEmpty
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
    };

    if (latitudeController.text.trim().isNotEmpty &&
        longitudeController.text.trim().isNotEmpty) {
      customerData['coordinate'] =
          '${latitudeController.text.trim()},${longitudeController.text.trim()}';
    }

    if (ktpPhotoFile != null) {
      customerData['ktp-photo'] = ktpPhotoFile;
    }
    if (locationPhotoFile != null) {
      customerData['location-photo'] = locationPhotoFile;
    }

    if (!context.mounted) return false;

    final provider = Provider.of<CustomerProvider>(context, listen: false);
    bool success;

    try {
      if (isEdit && customer != null) {
        success = await provider.updateCustomer(customer.id, customerData);
      } else {
        success = await provider.createCustomer(customerData);
      }
    } on ValidationException catch (e) {
      isLoading = false;
      notifyListeners();

      // Filter out optional photo errors if photos were not selected
      final filteredErrors = _filterOptionalPhotoErrors(e.errors);

      if (filteredErrors.isEmpty) {
        // All errors were optional photo errors, treat as success or show generic message
        if (!context.mounted) return false;
        SnackBars.error(
          context,
          'Terjadi kesalahan validasi di sisi server',
        ).clearSnackBars();
        return false;
      }

      onValidationError?.call(filteredErrors);
      if (!context.mounted) return false;

      // Format error message to show specific validation errors
      final errorMessage = _formatValidationErrors(
        ValidationException(errors: filteredErrors, message: e.message),
      );
      SnackBars.error(context, errorMessage).clearSnackBars();
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

  /// Filter out photo-related errors if photos were not selected (since they're optional)
  Map<String, dynamic> _filterOptionalPhotoErrors(Map<String, dynamic> errors) {
    // List of optional photo field keys
    const optionalPhotoFields = [
      'ktp-photo',
      'ktp_photo',
      'ktpPhoto',
      'location-photo',
      'location_photo',
      'locationPhoto',
    ];

    // Only filter if photos were not selected
    final filteredErrors = Map<String, dynamic>.from(errors);

    for (final field in optionalPhotoFields) {
      // Remove photo errors only if the corresponding photo was not selected
      if (field.contains('ktp') && ktpPhotoFile == null) {
        filteredErrors.remove(field);
      } else if (field.contains('location') && locationPhotoFile == null) {
        filteredErrors.remove(field);
      }
    }

    return filteredErrors;
  }

  /// Format validation errors to be displayed in a user-friendly way
  String _formatValidationErrors(ValidationException e) {
    if (e.errors.isEmpty) {
      return e.message;
    }

    final List<String> errorMessages = [];

    // Map field names to Indonesian labels
    final fieldLabels = {
      'name': 'Nama',
      'nickname': 'Nama Panggilan',
      'phone': 'Nomor Telepon',
      'ktp': 'Nomor KTP',
      'identity-number': 'Nomor KTP',
      'identity_number': 'Nomor KTP',
      'address': 'Alamat',
      'status': 'Status',
      'package': 'Paket Internet',
      'area': 'Area',
      'router': 'Router',
      'pppoe_secret': 'PPPoE Secret',
      'due-date': 'Tanggal Jatuh Tempo',
      'due_date': 'Tanggal Jatuh Tempo',
      'odp': 'ODP',
      'discount': 'Diskon',
      'coordinate': 'Koordinat',
      'ktp-photo': 'Foto KTP',
      'ktp_photo': 'Foto KTP',
      'location-photo': 'Foto Lokasi',
      'location_photo': 'Foto Lokasi',
    };

    e.errors.forEach((field, messages) {
      final label = fieldLabels[field] ?? field;
      if (messages is List && messages.isNotEmpty) {
        for (final message in messages) {
          errorMessages.add('$label: $message');
        }
      } else if (messages is String) {
        errorMessages.add('$label: $messages');
      }
    });

    if (errorMessages.isEmpty) {
      return e.message;
    }

    // Return first error for snackbar, full list is shown in form fields
    return errorMessages.first;
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

  CustomerStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'customer':
        return CustomerStatus.customer;
      case 'inactive':
        return CustomerStatus.inactive;
      case 'free':
        return CustomerStatus.free;
      case 'isolir':
        return CustomerStatus.isolir;
      default:
        return CustomerStatus.customer;
    }
  }

  String _getStatusString(CustomerStatus status) {
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
