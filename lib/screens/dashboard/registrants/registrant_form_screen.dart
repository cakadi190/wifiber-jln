import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/forms/backend_validation_mixin.dart';
import 'package:wifiber/components/reusables/area_modal_selector.dart';
import 'package:wifiber/components/reusables/image_preview.dart';
import 'package:wifiber/components/reusables/location_picker_widget.dart';
import 'package:wifiber/components/reusables/odp_modal_selector.dart';
import 'package:wifiber/components/reusables/package_modal_action.dart';
import 'package:wifiber/components/reusables/router_modal_selector.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/registrant_form_screen_controller.dart';
import 'package:wifiber/models/registrant.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/services/registrant_service.dart';

class RegistrantFormScreen extends StatefulWidget {
  final Registrant? registrant;
  final bool isEdit;

  const RegistrantFormScreen({super.key, this.registrant, this.isEdit = false});

  @override
  State<RegistrantFormScreen> createState() => _RegistrantFormScreenState();
}

class _RegistrantFormScreenState extends State<RegistrantFormScreen>
    with BackendValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late RegistrantFormController _controller;
  LatLng? _selectedLocation;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _controller = RegistrantFormController();
    _controller.initializeWithRegistrant(widget.registrant);
    if (widget.registrant?.latitude != null &&
        widget.registrant?.longitude != null) {
      _selectedLocation = LatLng(
        double.parse(widget.registrant!.latitude!),
        double.parse(widget.registrant!.longitude!),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.initializeEditData();
    });
  }

  @override
  GlobalKey<FormState> get formKey => _formKey;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPhotoSelector({
    required String title,
    required String subtitle,
    required XFile? selectedFile,
    required VoidCallback onTap,
    required BuildContext context,
    String? urlPreview = '',
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final hasUrlPreview = urlPreview != null && urlPreview.isNotEmpty;
    final hasSelectedFile = selectedFile != null;
    final hasAnyImage = hasUrlPreview || hasSelectedFile;

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
                    title.contains('KTP')
                        ? Icons.credit_card
                        : Icons.location_on,
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
                  if (hasAnyImage)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    const Icon(Icons.add_a_photo, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),

              if (hasAnyImage) ...[
                GestureDetector(
                  onTap: () {
                    if (hasUrlPreview) {
                      showImagePreview(
                        context,
                        imageUrl: urlPreview,
                        headers: {
                          'Authorization':
                              'Bearer ${authProvider.user?.accessToken}',
                        },
                      );
                    } else {
                      showImagePreview(
                        context,
                        imageFile: File(selectedFile!.path),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: hasUrlPreview
                        ? Image.network(
                            urlPreview,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            headers: {
                              'Authorization':
                                  'Bearer ${authProvider.user?.accessToken}',
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading image: $error');
                              return Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade400,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gagal memuat gambar',
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Image.file(
                            File(selectedFile!.path),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade400,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'File tidak ditemukan',
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hasUrlPreview
                            ? basename(urlPreview)
                            : basename(selectedFile!.path),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
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
    return Consumer<RegistrantFormController>(
      builder: (context, controller, child) {
        if (!controller.isInitializing) return const SizedBox.shrink();

        return Container(
          color: Colors.black.withValues(alpha: 0.3),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<RegistrantFormController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            appBar: AppBar(
              title: Text(
                widget.isEdit
                    ? 'Edit Calon Pelanggan'
                    : 'Tambah Calon Pelanggan',
              ),
              actions: [
                if (controller.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        clearBackendErrors();
                        await controller.submitForm(
                          context,
                          isEdit: widget.isEdit,
                          registrant: widget.registrant,
                          onValidationError: setBackendErrors,
                        );
                      }
                    },
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
                                  controller: controller.nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Lengkap',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: validator(
                                    'name',
                                    (value) => controller.validateRequired(
                                      value,
                                      'Nama lengkap',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: controller.nicknameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Panggilan',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: controller.phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nomor Telepon',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.phone),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: validator(
                                    'phone',
                                    (value) => controller.validateRequired(
                                      value,
                                      'Nomor telepon',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Awali nomor telpon dengan 62 (contoh: 628123456789)",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller:
                                      controller.identityNumberController,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Nomor KTP (atau isi dengan "-" jika belum ada)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.credit_card),
                                  ),
                                  validator: validator(
                                    'identity-number',
                                    (value) => controller.validateRequired(
                                      value,
                                      'Nomor KTP (atau isi dengan "-")',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: controller.addressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Alamat',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.location_on),
                                  ),
                                  maxLines: 3,
                                  validator: validator(
                                    'address',
                                    (value) => controller.validateRequired(
                                      value,
                                      'Alamat',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<RegistrantStatus>(
                                  value: controller.selectedStatus,
                                  decoration: const InputDecoration(
                                    labelText: 'Status',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.info),
                                  ),
                                  items: RegistrantStatus.values.map((status) {
                                    String displayName;
                                    switch (status) {
                                      case RegistrantStatus.registrant:
                                        displayName = 'Calon Pelanggan';
                                        break;
                                      case RegistrantStatus.inactive:
                                        displayName = 'Tidak Aktif';
                                        break;
                                      case RegistrantStatus.free:
                                        displayName = 'Gratis';
                                        break;
                                      case RegistrantStatus.isolir:
                                        displayName = 'Isolir';
                                        break;
                                    }
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(displayName),
                                    );
                                  }).toList(),
                                  onChanged: (value) =>
                                      controller.onStatusChanged(value!),
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
                                  selectedPackageId:
                                      controller.selectedPackageId,
                                  selectedPackageName:
                                      controller.selectedPackageName,
                                  onPackageSelected:
                                      controller.onPackageSelected,
                                ),
                                if (controller.validatePackageSelection() !=
                                    null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      controller.validatePackageSelection()!,
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                AreaButtonSelector(
                                  selectedAreaId: controller.selectedAreaId,
                                  selectedAreaName: controller.selectedAreaName,
                                  onAreaSelected: controller.onAreaSelected,
                                ),
                                if (controller.validateAreaSelection() != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      controller.validateAreaSelection()!,
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                RouterButtonSelector(
                                  selectedRouterId: controller.selectedRouterId,
                                  selectedRouterName:
                                      controller.selectedRouterName,
                                  onRouterSelected: controller.onRouterSelected,
                                ),
                                if (controller.validateRouterSelection() !=
                                    null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      controller.validateRouterSelection()!,
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: controller.pppoeSecretController,
                                  decoration: const InputDecoration(
                                    labelText: 'PPPoE Secret',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.vpn_key),
                                  ),
                                  validator: validator(
                                    'pppoe_secret',
                                    (value) => controller.validateRequired(
                                      value,
                                      'PPPoE Secret',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: controller.dueDateController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Tanggal Jatuh Tempo',
                                    prefixIcon: Icon(Icons.calendar_month),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: validator(
                                    'due-date',
                                    (value) => controller.validateRequired(
                                      value,
                                      'Tanggal jatuh tempo',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Masukkan tanggal jatuh tempo dalam angka antara 1-28 saja.',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 20),
                                OdpButtonSelector(
                                  selectedOdpId: controller.selectedOdpId,
                                  selectedOdpName: controller.selectedOdpName,
                                  onOdpSelected: controller.onOdpSelected,
                                ),
                                if (controller.validateOdpSelection() != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      controller.validateOdpSelection()!,
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: controller.discountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Diskon',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.discount),
                                    suffixText: '%',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: validator(
                                    'discount',
                                    (value) => controller.validateRequired(
                                      value,
                                      'Diskon',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Buat Prorata?'),
                                  value: controller.isProrate,
                                  onChanged: (value) =>
                                      controller.setProrate(value ?? false),
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
                                  'Lokasi (Wajib Diisi)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LocationPickerWidget(
                                  initialLocation: _selectedLocation,
                                  label: 'Lokasi',
                                  helperText:
                                      'Pilih lokasi pemasangan pada peta atau gunakan lokasi saat ini',
                                  isRequired: true,
                                  onLocationChanged: (location) {
                                    setState(() {
                                      _selectedLocation = location;
                                      if (location != null) {
                                        _controller.latitudeController.text =
                                            location.latitude.toString();
                                        _controller.longitudeController.text =
                                            location.longitude.toString();
                                        _locationError = null;
                                      }
                                    });
                                  },
                                  validator: (location) {
                                    if (location == null) {
                                      return 'Lokasi wajib dipilih';
                                    }
                                    return null;
                                  },
                                ),
                                if (_locationError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _locationError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
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

                              _buildPhotoSelector(
                                context: context,
                                title: 'Foto KTP',
                                subtitle:
                                    'Upload foto KTP pelanggan (opsional)',
                                selectedFile: controller.ktpPhotoFile,
                                urlPreview: controller.ktpPhotoUrl,
                                onTap: () => controller.showImagePickerModal(
                                  context,
                                  forKtp: true,
                                ),
                              ),
                              const SizedBox(height: 16),

                              _buildPhotoSelector(
                                context: context,
                                title: 'Foto Lokasi',
                                urlPreview: controller.locationPhotoUrl,
                                subtitle:
                                    'Upload foto lokasi pemasangan (opsional)',
                                selectedFile: controller.locationPhotoFile,
                                onTap: () => controller.showImagePickerModal(
                                  context,
                                  forKtp: false,
                                ),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          clearBackendErrors();
                                          await controller.submitForm(
                                            context,
                                            isEdit: widget.isEdit,
                                            registrant: widget.registrant,
                                            onValidationError: setBackendErrors,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: controller.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        widget.isEdit ? 'Perbarui' : 'Simpan',
                                      ),
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
        },
      ),
    );
  }
}
