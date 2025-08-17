import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/providers/registrant_provider.dart';
import 'package:wifiber/models/registrant.dart';
import 'package:wifiber/screens/dashboard/registrants/registrant_form_screen.dart';
import 'package:wifiber/screens/dashboard/registrants/registrant_detail_modal.dart';
import 'package:wifiber/screens/dashboard/registrants/registrant_delete_modal.dart'; // Add this import
import 'package:wifiber/services/registrant_service.dart';

class RegistrantListScreen extends StatefulWidget {
  const RegistrantListScreen({super.key});

  @override
  State<RegistrantListScreen> createState() => _RegistrantListScreenState();
}

class _RegistrantListScreenState extends State<RegistrantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  RegistrantStatus? _selectedStatus;

  RegistrantProvider? _registrantProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<RegistrantProvider>(
          context,
          listen: false,
        ).loadRegistrants();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registrantProvider = Provider.of<RegistrantProvider>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _registrantProvider = null;
    super.dispose();
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'registrant':
        return 'Calon Pelanggan';
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
      case 'registrant':
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

  void _clearFilter() {
    setState(() {
      _selectedStatus = null;
      _searchController.clear();
    });
    if (_registrantProvider != null) {
      _registrantProvider!.loadRegistrants();
    }
  }

  void _onSearchChanged(String query) {
    if (_registrantProvider != null) {
      if (query.isEmpty) {
        _registrantProvider!.loadRegistrants(status: _selectedStatus);
      } else {
        _registrantProvider!.searchRegistrants(query, status: _selectedStatus);
      }
    }
  }

  void _navigateToForm({Registrant? registrant}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegistrantFormScreen(
          registrant: registrant,
          isEdit: registrant != null,
        ),
      ),
    );

    if (mounted && _registrantProvider != null) {
      _registrantProvider!.refresh();
    }
  }

  void _showOptionsMenu(Registrant registrant) {
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
                      backgroundColor: _getStatusColor(registrant.status),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            registrant.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(registrant.phone),
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
                _navigateToForm(registrant: registrant);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                // Use the new delete modal instead of the old dialog
                RegistrantDeleteModal.show(context, registrant);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRegistrantDetail(Registrant registrant) {
    RegistrantDetailModal.show(context, registrant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Data Calon Pelanggan'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              if (_registrantProvider != null) {
                _registrantProvider!.refresh();
              }
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
                            _clearFilter();
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
              child: Consumer<RegistrantProvider>(
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

                  if (provider.registrants.isEmpty) {
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
                            'Tidak Ada Data Calon Pelanggan',
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
                      itemCount: provider.registrants.length,
                      itemBuilder: (context, index) {
                        final registrant = provider.registrants[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.all(0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(
                                registrant.status,
                              ),
                              child: Text(
                                registrant.name.isNotEmpty
                                    ? registrant.name[0].toUpperCase()
                                    : 'N',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              registrant.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(registrant.phone),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(registrant.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusDisplayName(registrant.status),
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
                              onPressed: () => _showOptionsMenu(registrant),
                            ),
                            onLongPress: () => _showOptionsMenu(registrant),
                            onTap: () => _showRegistrantDetail(registrant),
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
        tooltip: 'Tambah Calon Pelanggan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
