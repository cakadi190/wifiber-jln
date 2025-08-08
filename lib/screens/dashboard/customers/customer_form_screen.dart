import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/providers/customer_provider.dart';
import 'package:wifiber/services/customer_service.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/components/reusables/package_modal_action.dart';
import 'package:wifiber/components/reusables/router_modal_selector.dart';
import 'package:wifiber/components/reusables/odp_modal_selector.dart';
import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;
  final bool isEdit;

  const CustomerFormScreen({super.key, this.customer, this.isEdit = false});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final HttpService _http = HttpService();

  String? _selectedPackageId;
  String? _selectedPackageName;
  String? _selectedRouterId;
  String? _selectedRouterName;
  String? _selectedOdpId;
  String? _selectedOdpName;

  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _phoneController;
  late TextEditingController _identityNumberController;
  late TextEditingController _addressController;
  late TextEditingController _packageIdController;
  late TextEditingController _areaIdController;
  late TextEditingController _routerIdController;
  late TextEditingController _pppoeSecretController;
  late TextEditingController _dueDateController;
  late TextEditingController _odpIdController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _discountController;

  CustomerStatus _selectedStatus = CustomerStatus.customer;
  bool _isLoading = false;
  bool _isInitializing = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _ktpPhotoFile;
  XFile? _locationPhotoFile;

  @override
  void initState() {
    super.initState();
    _initControllers();
    if (widget.isEdit && widget.customer != null) {
      _initializeEditData();
    }
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _nicknameController = TextEditingController(
      text: widget.customer?.nickname ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.customer?.phone ?? '',
    );
    _identityNumberController = TextEditingController(
      text: widget.customer?.identityNumber ?? '',
    );
    _addressController = TextEditingController(
      text: widget.customer?.address ?? '',
    );
    _packageIdController = TextEditingController(
      text: widget.customer?.packageId ?? '',
    );
    _areaIdController = TextEditingController(
      text: widget.customer?.areaId ?? '',
    );
    _routerIdController = TextEditingController(
      text: widget.customer?.routerId ?? '',
    );
    _pppoeSecretController = TextEditingController(
      text: widget.customer?.pppoeSecret ?? '',
    );
    _dueDateController = TextEditingController(
      text: widget.customer?.dueDate ?? '',
    );
    _odpIdController = TextEditingController(
      text: widget.customer?.odpId ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.customer?.latitude ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.customer?.longitude ?? '',
    );
    _discountController = TextEditingController(
      text: widget.customer?.discount ?? '0',
    );

    if (widget.customer != null) {
      _selectedStatus = _getStatusFromString(widget.customer!.status);
      _selectedPackageId = widget.customer?.packageId;
      _selectedRouterId = widget.customer?.routerId;
      _selectedOdpId = widget.customer?.odpId;
    }
  }

  Future<void> _initializeEditData() async {
    if (widget.customer == null) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      if (_selectedPackageId != null && _selectedPackageId!.isNotEmpty) {
        await _fetchPackageName(_selectedPackageId!);
      }

      if (_selectedRouterId != null && _selectedRouterId!.isNotEmpty) {
        await _fetchRouterName(_selectedRouterId!);
      }

      if (_selectedOdpId != null && _selectedOdpId!.isNotEmpty) {
        await _fetchOdpName(_selectedOdpId!);
      }
    } catch (e) {
      print('Error initializing edit data: $e');
    }

    setState(() {
      _isInitializing = false;
    });
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
          setState(() {
            _selectedPackageName = package['name'];
          });
        }
      }
    } catch (e) {
      print('Error fetching package name: $e');
    }
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
          setState(() {
            _selectedRouterName = router['name'];
          });
        }
      }
    } catch (e) {
      print('Error fetching router name: $e');
    }
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
          setState(() {
            _selectedOdpName = odp['name'];
          });
        }
      }
    } catch (e) {
      print('Error fetching ODP name: $e');
    }
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
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _identityNumberController.dispose();
    _addressController.dispose();
    _packageIdController.dispose();
    _areaIdController.dispose();
    _routerIdController.dispose();
    _pppoeSecretController.dispose();
    _dueDateController.dispose();
    _odpIdController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm([BuildContext? context]) async {
    final ctx = context ?? this.context;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final customerData = <String, dynamic>{
      'name': _nameController.text.trim(),
      'nickname': _nicknameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'ktp': _identityNumberController.text.trim().isEmpty
          ? '-'
          : _identityNumberController.text.trim(),
      'address': _addressController.text.trim(),
      'status': _getStatusString(_selectedStatus),

      'package': (_selectedPackageId?.isEmpty ?? true)
          ? null
          : _selectedPackageId,
      'area': _areaIdController.text.trim().isEmpty
          ? null
          : _areaIdController.text.trim(),
      'router': (_selectedRouterId?.isEmpty ?? true) ? null : _selectedRouterId,
      'pppoe_secret': _pppoeSecretController.text.trim(),
      'due-date': _dueDateController.text.trim(),
      'odp': (_selectedOdpId?.isEmpty ?? true) ? null : _selectedOdpId,

      if (_latitudeController.text.trim().isNotEmpty &&
          _longitudeController.text.trim().isNotEmpty)
        'coordinate':
            '${_latitudeController.text.trim()},${_longitudeController.text.trim()}',

      'discount': _discountController.text.trim().isEmpty
          ? '0'
          : _discountController.text.trim(),
    };

    // Jika ada foto KTP dan foto lokasi yang sudah dipilih, sertakan di sini
    if (_ktpPhotoFile != null) {
      customerData['ktp-photo'] = _ktpPhotoFile;
    }
    if (_locationPhotoFile != null) {
      customerData['location-photo'] = _locationPhotoFile;
    }

    final provider = Provider.of<CustomerProvider>(ctx, listen: false);
    bool success;

    if (widget.isEdit && widget.customer != null) {
      success = await provider.updateCustomer(
        widget.customer!.id,
        customerData,
      );
    } else {
      success = await provider.createCustomer(customerData);
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(ctx).pop(true);
      SnackBars.success(
        ctx,
        widget.isEdit
            ? 'Data pelanggan berhasil diperbarui'
            : 'Data pelanggan berhasil ditambahkan',
      ).clearSnackBars();
    } else {
      print(provider.error);
      SnackBars.error(
        ctx,
        provider.error ??
            (widget.isEdit
                ? 'Gagal memperbarui data pelanggan'
                : 'Gagal menambah data pelanggan'),
      ).clearSnackBars();
    }
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  Future<void> _pickImage(
    ImageSource source,
    BuildContext context, {
    required bool forKtp,
  }) async {
    // Kalau sumbernya kamera, pastikan izin kamera sudah ada
    if (source == ImageSource.camera) {
      bool granted = await _requestCameraPermission();
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin kamera diperlukan untuk mengambil foto'),
            backgroundColor: Colors.red,
          ),
        );
        return; // jangan lanjut jika izin tidak ada
      }
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image != null) {
        setState(() {
          if (forKtp) {
            _ktpPhotoFile = image;
          } else {
            _locationPhotoFile = image;
          }
        });
        Navigator.pop(context);
      }
    } catch (e) {
      print("Failed to pick image: $e");
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPickerModal(BuildContext context, {required bool forKtp}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                      _pickImage(ImageSource.gallery, context, forKtp: forKtp),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('Ambil dengan Kamera'),
                  onTap: () =>
                      _pickImage(ImageSource.camera, context, forKtp: forKtp),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoSelector({
    required String title,
    required String subtitle,
    required XFile? selectedFile,
    required bool forKtp,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    forKtp ? Icons.credit_card : Icons.location_on,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedFile != null)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    const Icon(Icons.add_a_photo, color: Colors.grey),
                ],
              ),
              if (selectedFile != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(selectedFile.path),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Foto terpilih: ${basename(selectedFile.path)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 32,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk untuk menambah foto',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    if (!_isInitializing) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () => _submitForm(context),
              icon: const Icon(Icons.save),
              tooltip: 'Simpan',
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                      side: BorderSide.none,
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Umum',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama lengkap wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nicknameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Panggilan',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Nomor Telepon',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor telepon wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Awali dengan 62 bukan 0!",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _identityNumberController,
                            decoration: const InputDecoration(
                              labelText:
                                  'Nomor KTP (atau isi dengan "-" jika belum ada)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor KTP wajib diisi (atau isi dengan "-")';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Alamat',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<CustomerStatus>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.info),
                            ),
                            items: CustomerStatus.values.map((status) {
                              String displayName;
                              switch (status) {
                                case CustomerStatus.customer:
                                  displayName = 'Pelanggan';
                                  break;
                                case CustomerStatus.inactive:
                                  displayName = 'Tidak Aktif';
                                  break;
                                case CustomerStatus.free:
                                  displayName = 'Gratis';
                                  break;
                                case CustomerStatus.isolir:
                                  displayName = 'Isolir';
                                  break;
                              }
                              return DropdownMenuItem(
                                value: status,
                                child: Text(displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                      side: BorderSide.none,
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Teknis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          PackageButtonSelector(
                            selectedPackageId: _selectedPackageId,
                            selectedPackageName: _selectedPackageName,
                            onPackageSelected: (package) {
                              setState(() {
                                _selectedPackageId = package.id;
                                _selectedPackageName = package.name;
                                _packageIdController.text = package.id;
                              });
                            },
                          ),
                          if (_selectedPackageId == null ||
                              _selectedPackageId!.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Paket internet wajib dipilih',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _areaIdController,
                            decoration: const InputDecoration(
                              labelText: 'ID Area',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.map),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ID Area wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          RouterButtonSelector(
                            selectedRouterId: _selectedRouterId,
                            selectedRouterName: _selectedRouterName,
                            onRouterSelected: (router) {
                              setState(() {
                                _selectedRouterId = router.id;
                                _selectedRouterName = router.name;
                                _routerIdController.text = router.id;
                              });
                            },
                          ),
                          if (_selectedRouterId == null ||
                              _selectedRouterId!.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Router wajib dipilih',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _pppoeSecretController,
                            decoration: const InputDecoration(
                              labelText: 'PPPoE Secret',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.vpn_key),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'PPPoE Secret wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _dueDateController,
                            decoration: InputDecoration(
                              labelText: 'Tanggal Jatuh Tempo',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.calendar_today),
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (selectedDate != null) {
                                    setState(() {
                                      _dueDateController.text =
                                          DateHelper.format(selectedDate);
                                    });
                                  }
                                },
                                icon: const Icon(Icons.date_range),
                              ),
                            ),
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tanggal jatuh tempo wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          OdpButtonSelector(
                            selectedOdpId: _selectedOdpId,
                            selectedOdpName: _selectedOdpName,
                            onOdpSelected: (odp) {
                              setState(() {
                                _selectedOdpId = odp.id;
                                _selectedOdpName = odp.name;
                                _odpIdController.text = odp.id;
                              });
                            },
                          ),
                          if (_selectedOdpId == null || _selectedOdpId!.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'ODP wajib dipilih',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _discountController,
                            decoration: const InputDecoration(
                              labelText: 'Diskon',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.discount),
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Diskon wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                      side: BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Koordinat Lokasi (Wajib Diisi)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kedua koordinat harus diisi atau biarkan keduanya kosong',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _latitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.my_location),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              final lat = value?.trim() ?? '';
                              final lng = _longitudeController.text.trim();

                              // Both must be filled or both must be empty
                              if ((lat.isEmpty && lng.isNotEmpty) ||
                                  (lat.isNotEmpty && lng.isEmpty)) {
                                return 'Kedua koordinat harus diisi atau biarkan keduanya kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _longitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.my_location),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              final lng = value?.trim() ?? '';
                              final lat = _latitudeController.text.trim();

                              // Both must be filled or both must be empty
                              if ((lng.isEmpty && lat.isNotEmpty) ||
                                  (lng.isNotEmpty && lat.isEmpty)) {
                                return 'Kedua koordinat harus diisi atau biarkan keduanya kosong';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Photo Upload Section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                      side: BorderSide.none,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Foto Dokumen dan Lokasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Silakan tambahkan foto KTP dan foto lokasi pemasangan',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // KTP Photo Selector
                        _buildPhotoSelector(
                          title: 'Foto KTP',
                          subtitle: 'Upload foto KTP pelanggan (opsional)',
                          selectedFile: _ktpPhotoFile,
                          forKtp: true,
                          onTap: () => _showPickerModal(context, forKtp: true),
                        ),
                        const SizedBox(height: 16),

                        // Location Photo Selector
                        _buildPhotoSelector(
                          title: 'Foto Lokasi',
                          subtitle: 'Upload foto lokasi pemasangan (opsional)',
                          selectedFile: _locationPhotoFile,
                          forKtp: false,
                          onTap: () => _showPickerModal(context, forKtp: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _submitForm(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(widget.isEdit ? 'Perbarui' : 'Simpan'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}
