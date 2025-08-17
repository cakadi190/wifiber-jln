import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/providers/customer_provider.dart';
import 'package:wifiber/screens/dashboard/customers/customer_delete_modal.dart';
import 'package:wifiber/screens/dashboard/customers/customer_detail_modal.dart';
import 'package:wifiber/screens/dashboard/customers/customer_form_screen.dart';
import 'package:wifiber/services/customer_service.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  CustomerStatus? _selectedStatus;

  CustomerProvider? _customerProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
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
    showDialog(
      context: context,
      builder: (context) {
        CustomerStatus? tempSelectedStatus = _selectedStatus;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Pelanggan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<CustomerStatus?>(
                    value: tempSelectedStatus,
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
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tempSelectedStatus = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = tempSelectedStatus;
                    });
                    Navigator.of(context).pop();
                    _applyFilter();
                  },
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyFilter() {
    if (_customerProvider != null) {
      _customerProvider!.loadCustomers(status: _selectedStatus);
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedStatus = null;
      _searchController.clear();
    });
    if (_customerProvider != null) {
      _customerProvider!.loadCustomers();
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
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getStatusColor(customer.status),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(customer.phone),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToForm(customer: customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                // Use the new delete modal instead of the old dialog
                CustomerDeleteModal.show(context, customer);
              },
            ),
          ],
        ),
      ),
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

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickFile() async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['xls', 'xlsx'],
                  allowMultiple: false,
                );

                if (result != null) {
                  setState(() {
                    selectedFile = File(result.files.single.path!);
                    fileName = result.files.single.name;
                  });
                }
              } catch (e) {
                SnackBars.error(
                  context,
                  'Gagal memilih berkas: ${e.toString()}',
                ).clearSnackBars();
              }
            }

            Future<void> upload() async {
              if (selectedFile == null) return;
              setState(() {
                isLoading = true;
              });

              final provider = _customerProvider;
              try {
                final message = await provider?.importCustomers(selectedFile!);
                if (!mounted) return;
                Navigator.of(context).pop();
                if (message != null) {
                  SnackBars.success(context, message).clearSnackBars();
                  provider?.refresh();
                } else if (provider?.error != null) {
                  SnackBars.error(context, provider!.error!).clearSnackBars();
                }
              } catch (e) {
                if (mounted) {
                  SnackBars.error(context, e.toString()).clearSnackBars();
                }
              } finally {
                if (mounted) {
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
                    onPressed: selectedFile != null && !isLoading ? upload : null,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Data Pelanggan'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _showFilterDialog,
                child: Row(
                  children: const [
                    Icon(Icons.filter_list, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Filter'),
                  ],
                ),
              ),
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
      body: Container(
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
            if (_selectedStatus != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: Colors.blue.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filter: ${_getStatusDisplayName(_selectedStatus.toString().split('.').last)}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi Kesalahan',
                            style: Theme.of(context).textTheme.headlineSmall,
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
                            style: Theme.of(context).textTheme.headlineSmall,
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
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(customer.status),
                              child: Text(
                                customer.name.isNotEmpty
                                    ? customer.name[0].toUpperCase()
                                    : 'N',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              customer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(customer.phone),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Tambah Pelanggan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
