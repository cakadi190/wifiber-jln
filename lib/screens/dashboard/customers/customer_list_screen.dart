import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/providers/customer_provider.dart';
import 'package:wifiber/models/customer.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    final provider = Provider.of<CustomerProvider>(context, listen: false);
    provider.loadCustomers(status: _selectedStatus);
  }

  void _clearFilter() {
    setState(() {
      _selectedStatus = null;
      _searchController.clear();
    });
    final provider = Provider.of<CustomerProvider>(context, listen: false);
    provider.loadCustomers();
  }

  void _onSearchChanged(String query) {
    final provider = Provider.of<CustomerProvider>(context, listen: false);
    if (query.isEmpty) {
      provider.loadCustomers(status: _selectedStatus);
    } else {
      provider.searchCustomers(query);
    }
  }

  void _showDeleteConfirmation(Customer customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Pelanggan'),
          content: Text(
            'Apakah Anda yakin ingin menghapus pelanggan "${customer.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final provider = Provider.of<CustomerProvider>(
                  context,
                  listen: false,
                );
                final success = await provider.deleteCustomer(customer.id);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pelanggan berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.error ?? 'Gagal menghapus pelanggan',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToForm({Customer? customer}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CustomerFormScreen(customer: customer, isEdit: customer != null),
      ),
    );

    if (result == true) {
      final provider = Provider.of<CustomerProvider>(context, listen: false);
      provider.refresh();
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
                _showDeleteConfirmation(customer);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color ?? Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(String label, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.broken_image, size: 40)),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 150,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _customerDataModal(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Pelanggan',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow(
                            context,
                            'Nama',
                            customer.name,
                            Icons.person,
                          ),
                          if (customer.nickname != null &&
                              customer.nickname!.isNotEmpty)
                            _buildDetailRow(
                              context,
                              'Nama Panggilan',
                              customer.nickname!,
                              Icons.person_outline,
                            ),
                          _buildDetailRow(
                            context,
                            'Telepon',
                            customer.phone,
                            Icons.phone,
                          ),
                          _buildDetailRow(
                            context,
                            'No. Identitas',
                            customer.identityNumber,
                            Icons.badge,
                          ),
                          _buildDetailRow(
                            context,
                            'Alamat',
                            customer.address,
                            Icons.location_on,
                          ),
                          _buildDetailRow(
                            context,
                            'Status',
                            _getStatusDisplayName(customer.status),
                            Icons.info,
                            color: _getStatusColor(customer.status),
                          ),
                          const SizedBox(height: 8),

                          if (customer.ktpPhoto != null)
                            _buildPhotoSection('Foto KTP', customer.ktpPhoto!),
                          if (customer.locationPhoto != null)
                            _buildPhotoSection(
                              'Foto Lokasi',
                              customer.locationPhoto!,
                            ),

                          _buildDetailRow(
                            context,
                            'Paket',
                            customer.packageName,
                            Icons.wifi,
                            color: AppColors.primary,
                          ),
                          _buildDetailRow(
                            context,
                            'Harga Paket',
                            CurrencyHelper.formatCurrency(
                              int.parse(customer.packagePrice),
                            ),
                            Icons.monetization_on,
                            color: AppColors.primary,
                          ),
                          _buildDetailRow(
                            context,
                            'PPN Paket',
                            '${customer.packagePpn}%',
                            Icons.percent,
                            color: AppColors.primary,
                          ),
                          _buildDetailRow(
                            context,
                            'Diskon',
                            '${customer.discount}%',
                            Icons.local_offer,
                          ),
                          _buildDetailRow(
                            context,
                            'Jatuh Tempo',
                            customer.dueDate,
                            Icons.calendar_month,
                          ),
                          _buildDetailRow(
                            context,
                            'Created At',
                            customer.createdAt,
                            Icons.schedule,
                          ),

                          if (customer.routerName != null)
                            _buildDetailRow(
                              context,
                              'Router',
                              customer.routerName!,
                              Icons.router,
                            ),
                          if (customer.routerHost != null)
                            _buildDetailRow(
                              context,
                              'Router Host',
                              customer.routerHost!,
                              Icons.dns,
                            ),

                          // if (customer.latitude != null &&
                          //     customer.longitude != null)
                          //   _buildDetailRow(
                          //     context,
                          //     'Lokasi (Lat, Long)',
                          //     '${customer.latitude}, ${customer.longitude}',
                          //     Icons.my_location,
                          //   ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Tombol Buka Map
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (customer.latitude != null &&
                            customer.longitude != null) {
                          final lat = double.parse(customer.latitude!);
                          final lng = double.parse(customer.longitude!);
                          if (lat != 0 && lng != 0) {
                            MapsLauncher.launchCoordinates(lat, lng);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Buka Di Maps',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  // Tombol Tutup Besar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
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
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
          if (_selectedStatus != null || _searchController.text.isNotEmpty)
            IconButton(
              onPressed: _clearFilter,
              icon: const Icon(Icons.clear),
              tooltip: 'Bersihkan Filter',
            ),
          IconButton(
            onPressed: () {
              final provider = Provider.of<CustomerProvider>(
                context,
                listen: false,
              );
              provider.refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
                            onTap: () => _customerDataModal(customer),
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
