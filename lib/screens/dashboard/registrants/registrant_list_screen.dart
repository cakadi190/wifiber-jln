import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/reusables/options_bottom_sheet.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/providers/registrant_provider.dart';
import 'package:wifiber/models/registrant.dart';
import 'package:wifiber/screens/dashboard/registrants/registrant_form_screen.dart';
import 'package:wifiber/screens/dashboard/registrants/registrant_detail_modal.dart';
import 'package:wifiber/screens/dashboard/registrants/registrant_delete_modal.dart';
import 'package:wifiber/services/registrant_service.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/mixins/scroll_to_hide_fab_mixin.dart';
import 'package:wifiber/components/reusables/hideable_fab_wrapper.dart';

class RegistrantListScreen extends StatefulWidget {
  const RegistrantListScreen({super.key});

  @override
  State<RegistrantListScreen> createState() => _RegistrantListScreenState();
}

class _RegistrantListScreenState extends State<RegistrantListScreen>
    with ScrollToHideFabMixin {
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
    showOptionModalBottomSheet<void>(
      context: context,
      header: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getStatusColor(registrant.status),
            child: const Icon(Icons.verified_user, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registrant.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${registrant.customerId} - ${registrant.phone}",
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
            _showRegistrantDetail(registrant);
          },
        ),
        OptionMenuItem(
          icon: Icons.edit,
          title: 'Ubah Data',
          subtitle: 'Ubah data pelanggan',
          onTap: () {
            Navigator.pop(context);
            _navigateToForm(registrant: registrant);
          },
        ),
        OptionMenuItem(
          icon: Icons.delete,
          title: 'Hapus Data',
          subtitle: 'Hapus data dari daftar',
          isDestructive: true,
          onTap: () {
            Navigator.pop(context);
            RegistrantDeleteModal.show(context, registrant);
          },
        ),
      ],
    );
  }

  void _showRegistrantDetail(Registrant registrant) {
    RegistrantDetailModal.show(context, registrant);
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      requiredPermissions: const ['registrant'],
      child: Scaffold(
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
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Badge row (Status + PPPoE)
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              registrant.status,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            _getStatusDisplayName(
                                              registrant.status,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            registrant.pppoeSecret,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Registrant ID
                                    Text(
                                      registrant.customerId,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // Registrant Name
                                    Text(
                                      registrant.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "${registrant.phone}${registrant.areaName != null ? ' - ${registrant.areaName}' : ''}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
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
        ),
        floatingActionButton: HideableFabWrapper(
          visible: isFabVisible,
          child: PermissionWidget(
            permissions: const ['registrant'],
            child: FloatingActionButton(
              onPressed: () => _navigateToForm(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              tooltip: 'Tambah Calon Pelanggan',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
