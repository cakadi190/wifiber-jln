import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/reusables/area_modal_selector.dart';
import 'package:wifiber/components/reusables/options_bottom_sheet.dart';
import 'package:wifiber/components/reusables/router_modal_selector.dart'
    as router_selector;
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/providers/customer_provider.dart';
import 'package:wifiber/screens/dashboard/customers/customer_delete_modal.dart';
import 'package:wifiber/screens/dashboard/customers/customer_detail_modal.dart';
import 'package:wifiber/screens/dashboard/customers/customer_form_screen.dart';
import 'package:wifiber/services/customer_service.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/mixins/scroll_to_hide_fab_mixin.dart';
import 'package:wifiber/components/reusables/hideable_fab_wrapper.dart';
import 'package:wifiber/utils/file_picker_validator.dart';

class CustomerListScreen extends StatefulWidget {
  final CustomerStatus? initialStatus;

  const CustomerListScreen({super.key, this.initialStatus});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen>
    with ScrollToHideFabMixin {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedAreaId;
  String? _selectedAreaName;

  String? _selectedRouterId;
  String? _selectedRouterName;

  CustomerStatus? _selectedStatus;
  CustomerProvider? _customerProvider;

  @override
  void initState() {
    super.initState();

    _selectedStatus = widget.initialStatus;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CustomerProvider>(
          context,
          listen: false,
        ).loadCustomers(status: _selectedStatus);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _customerProvider = Provider.of<CustomerProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerProvider = null;
    super.dispose();
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'customer':
        return 'Pelanggan';
      case 'inactive':
        return 'Tidak Aktif';
      case 'free':
        return 'Gratis';
      case 'isolir':
        return 'Isolir';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'customer':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'free':
        return Colors.blue;
      case 'isolir':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        CustomerStatus? tempSelectedStatus = _selectedStatus;
        String? tempSelectedAreaId = _selectedAreaId;
        String? tempSelectedAreaName = _selectedAreaName;
        String? tempSelectedRouterId = _selectedRouterId;
        String? tempSelectedRouterName = _selectedRouterName;

        return SafeArea(
          top: false,
          bottom: true,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Filter Pelanggan',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<CustomerStatus?>(
                      initialValue: tempSelectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Semua Status'),
                        ),
                        ...CustomerStatus.values.map((status) {
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
                        }),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempSelectedStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    AreaButtonSelector(
                      selectedAreaId: tempSelectedAreaId,
                      selectedAreaName: tempSelectedAreaName,
                      onAreaSelected: (Area area) {
                        setModalState(() {
                          tempSelectedAreaId = area.id;
                          tempSelectedAreaName = area.name;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    router_selector.RouterButtonSelector(
                      selectedRouterId: tempSelectedRouterId,
                      selectedRouterName: tempSelectedRouterName,
                      onRouterSelected: (router_selector.Router router) {
                        setModalState(() {
                          tempSelectedRouterId = router.id;
                          tempSelectedRouterName = router.name;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                AppColors.primary,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _selectedStatus = tempSelectedStatus;
                                _selectedAreaId = tempSelectedAreaId;
                                _selectedAreaName = tempSelectedAreaName;
                                _selectedRouterId = tempSelectedRouterId;
                                _selectedRouterName = tempSelectedRouterName;
                              });
                              _applyFilter();
                            },
                            child: const Text(
                              'Terapkan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _applyFilter() {
    if (_customerProvider != null) {
      _customerProvider!.loadCustomers(
        status: _selectedStatus,
        areaId: _selectedAreaId != null ? int.tryParse(_selectedAreaId!) : null,
        routerId: _selectedRouterId != null
            ? int.tryParse(_selectedRouterId!)
            : null,
      );
    }
  }

  void _onSearchChanged(String query) {
    if (_customerProvider != null) {
      if (query.isEmpty) {
        _customerProvider!.loadCustomers(status: _selectedStatus);
      } else {
        _customerProvider!.searchCustomers(query);
      }
    }
  }

  void _navigateToForm({Customer? customer}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CustomerFormScreen(customer: customer, isEdit: customer != null),
      ),
    );

    if (mounted && _customerProvider != null) {
      _customerProvider!.refresh();
    }
  }

  void _showOptionsMenu(Customer customer) {
    showOptionModalBottomSheet<void>(
      context: context,
      header: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getStatusColor(customer.status),
            child: const Icon(Icons.verified_user, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  customer.phone,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      items: [
        OptionMenuItem(
          icon: Icons.visibility,
          title: 'Lihat Data',
          subtitle: 'Lihat data pelanggan',
          onTap: () {
            Navigator.pop(context);
            _showCustomerDetail(customer);
          },
        ),
        OptionMenuItem(
          icon: Icons.edit,
          title: 'Ubah Data',
          subtitle: 'Ubah data pelanggan',
          onTap: () {
            Navigator.pop(context);
            _navigateToForm(customer: customer);
          },
        ),
        OptionMenuItem(
          icon: Icons.delete,
          title: 'Hapus Data',
          subtitle: 'Hapus data dari daftar',
          isDestructive: true,
          onTap: () {
            Navigator.pop(context);
            CustomerDeleteModal.show(context, customer);
          },
        ),
      ],
    );
  }

  void _showCustomerDetail(Customer customer) {
    CustomerDetailModal.show(context, customer);
  }

  void _showImportModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        File? selectedFile;
        String? fileName;
        bool isLoading = false;

        return SafeArea(
          top: false,
          bottom: true,
          child: StatefulBuilder(
            builder: (context, setState) {
              Future<void> pickFile() async {
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xls', 'xlsx'],
                    allowMultiple: false,
                  );

                  if (!context.mounted) return;

                  if (result == null || result.files.isEmpty) {
                    // User membatalkan pemilihan
                    return;
                  }

                  final file = File(result.files.single.path!);

                  // Validasi ukuran file (maks 10MB untuk Excel)
                  const excelConfig = FilePickerConfig(
                    allowedExtensions: ['xls', 'xlsx'],
                    maxFileSizeBytes: 10 * 1024 * 1024, // 10MB
                    fileTypeLabel: 'File Excel',
                  );

                  final validationResult =
                      await FilePickerValidator.validateFile(file, excelConfig);

                  if (!context.mounted) return;

                  if (!validationResult.isValid) {
                    validationResult.showErrorIfInvalid(context);
                    return;
                  }

                  setState(() {
                    selectedFile = file;
                    fileName = result.files.single.name;
                  });
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Gagal memilih berkas: ${e.toString().replaceAll('Exception: ', '')}',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red.shade600,
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                }
              }

              Future<void> upload() async {
                if (selectedFile == null) return;
                setState(() {
                  isLoading = true;
                });

                final provider = _customerProvider;
                try {
                  final message = await provider?.importCustomers(
                    selectedFile!,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  if (message != null) {
                    SnackBars.success(context, message).clearSnackBars();
                    provider?.refresh();
                  } else if (provider?.error != null) {
                    SnackBars.error(context, provider!.error!).clearSnackBars();
                  }
                } catch (e) {
                  if (context.mounted) {
                    SnackBars.error(context, e.toString()).clearSnackBars();
                  }
                } finally {
                  if (context.mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              }

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Impor Data Pelanggan',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: pickFile,
                      icon: const Icon(Icons.insert_drive_file),
                      label: Text(fileName ?? 'Pilih File Excel'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: selectedFile != null && !isLoading
                          ? upload
                          : null,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Unggah'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      requiredPermissions: const ['customer'],
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: const Text('Data Pelanggan'),
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: _showImportModal,
                  child: Row(
                    children: const [
                      Icon(Icons.file_upload, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Impor Data Excel'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    if (_customerProvider != null) {
                      _customerProvider!.refresh();
                    }
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.refresh, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Refresh'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari pelanggan...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                    icon: const Icon(Icons.clear),
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          _showFilterDialog();
                        },
                        icon: const Icon(Icons.filter_list),
                        tooltip: 'Filter',
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.grey.shade200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedStatus != null ||
                    _selectedAreaName != null ||
                    _selectedRouterName != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedStatus != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                label: Text(
                                  _getStatusDisplayName(
                                    _selectedStatus.toString().split('.').last,
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onDeleted: () {
                                  setState(() => _selectedStatus = null);
                                  _applyFilter();
                                },
                              ),
                            ),
                          if (_selectedAreaName != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                label: Text(
                                  _selectedAreaName!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onDeleted: () {
                                  setState(() {
                                    _selectedAreaId = null;
                                    _selectedAreaName = null;
                                  });
                                  _applyFilter();
                                },
                              ),
                            ),
                          if (_selectedRouterName != null)
                            Chip(
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              label: Text(
                                _selectedRouterName!,
                                style: const TextStyle(fontSize: 12),
                              ),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onDeleted: () {
                                setState(() {
                                  _selectedRouterId = null;
                                  _selectedRouterName = null;
                                });
                                _applyFilter();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: Consumer<CustomerProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Terjadi Kesalahan',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: provider.refresh,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (provider.customers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak Ada Data Pelanggan',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Belum ada data pelanggan yang tersedia',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: provider.refresh,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: provider.customers.length,
                          itemBuilder: (context, index) {
                            final customer = provider.customers[index];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.all(0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        customer.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(customer.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusDisplayName(customer.status),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  "${customer.phone} - ${customer.areaName}",
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () => _showOptionsMenu(customer),
                                ),
                                onLongPress: () => _showOptionsMenu(customer),
                                onTap: () => _showCustomerDetail(customer),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: HideableFabWrapper(
          visible: isFabVisible,
          child: PermissionWidget(
            permissions: const ['customer'],
            child: FloatingActionButton(
              onPressed: () => _navigateToForm(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              tooltip: 'Tambah Pelanggan',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
