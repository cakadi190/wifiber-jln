import 'package:flutter/material.dart';
import 'package:wifiber/providers/customer_provider.dart';
import 'package:wifiber/services/customer_service.dart';

class CustomerController {
  final CustomerProvider _provider;
  final BuildContext context;

  CustomerController({
    required CustomerProvider provider,
    required this.context,
  }) : _provider = provider;

  Future<void> getAllCustomers({
    CustomerStatus? status,
    int? routerId,
    int? areaId,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _showLoadingDialog();
    }

    await _provider.loadCustomers(
      status: status,
      routerId: routerId,
      areaId: areaId,
    );

    if (showLoading && context.mounted) {
      Navigator.of(context).pop();
    }

    if (_provider.error != null) {
      _showErrorDialog(_provider.error!);
    }
  }

  Future<void> getCustomerById(String id) async {
    _showLoadingDialog();

    await _provider.loadCustomerById(id);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (_provider.error != null) {
      _showErrorDialog(_provider.error!);
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> customerData) async {
    _showLoadingDialog();

    final success = await _provider.createCustomer(customerData);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      _showSuccessDialog('Customer berhasil dibuat');
      return true;
    } else {
      _showErrorDialog(_provider.error ?? 'Gagal membuat customer');
      return false;
    }
  }

  Future<bool> updateCustomer(
    String id,
    Map<String, dynamic> customerData,
  ) async {
    _showLoadingDialog();

    final success = await _provider.updateCustomer(id, customerData);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      _showSuccessDialog('Customer berhasil diupdate');
      return true;
    } else {
      _showErrorDialog(_provider.error ?? 'Gagal mengupdate customer');
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    final confirmed = await _showConfirmationDialog(
      'Hapus Customer',
      'Apakah Anda yakin ingin menghapus customer ini?',
    );

    if (!confirmed) return false;

    _showLoadingDialog();

    final success = await _provider.deleteCustomer(id);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      _showSuccessDialog('Customer berhasil dihapus');
      return true;
    } else {
      _showErrorDialog(_provider.error ?? 'Gagal menghapus customer');
      return false;
    }
  }

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      await getAllCustomers(showLoading: false);
      return;
    }

    await _provider.searchCustomers(query);

    if (_provider.error != null) {
      _showErrorDialog(_provider.error!);
    }
  }

  Future<void> getCustomersByStatus(String status) async {
    _showLoadingDialog();

    await _provider.getCustomersByStatus(status);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (_provider.error != null) {
      _showErrorDialog(_provider.error!);
    }
  }

  Future<void> refreshData() async {
    await _provider.refresh();

    if (_provider.error != null) {
      _showErrorDialog(_provider.error!);
    }
  }

  void clearSelectedCustomer() {
    _provider.clearSelectedCustomer();
  }

  void clearData() {
    _provider.clearData();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.error, color: Colors.red, size: 48),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void showStatusFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Semua'),
              onTap: () {
                Navigator.pop(context);
                getAllCustomers();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Customer'),
              onTap: () {
                Navigator.pop(context);
                getAllCustomers(status: CustomerStatus.customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off),
              title: const Text('Inactive'),
              onTap: () {
                Navigator.pop(context);
                getAllCustomers(status: CustomerStatus.inactive);
              },
            ),
            ListTile(
              leading: const Icon(Icons.free_breakfast),
              title: const Text('Free'),
              onTap: () {
                Navigator.pop(context);
                getAllCustomers(status: CustomerStatus.free);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Isolir'),
              onTap: () {
                Navigator.pop(context);
                getAllCustomers(status: CustomerStatus.isolir);
              },
            ),
          ],
        ),
      ),
    );
  }
}
