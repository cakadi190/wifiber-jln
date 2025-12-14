import 'package:flutter/material.dart';
import 'package:wifiber/providers/registrant_provider.dart';
import 'package:wifiber/services/registrant_service.dart';

class RegistrantController {
  final RegistrantProvider _provider;
  final BuildContext context;

  RegistrantController({
    required RegistrantProvider provider,
    required this.context,
  }) : _provider = provider;

  Future<void> getAllRegistrants({
    RegistrantStatus? status,
    int? routerId,
    int? areaId,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _showLoadingDialog();
    }

    await _provider.loadRegistrants(
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

  Future<void> getRegistrantById(String id) async {
    _showLoadingDialog();

    await _provider.loadRegistrantById(id);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (_provider.error != null) {
      _showErrorDialog(_provider.error!);
    }
  }

  Future<bool> createRegistrant(Map<String, dynamic> registrantData) async {
    _showLoadingDialog();

    final success = await _provider.createRegistrant(registrantData);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      _showSuccessDialog('Registrant berhasil dibuat');
      return true;
    } else {
      _showErrorDialog(_provider.error ?? 'Gagal membuat registrant');
      return false;
    }
  }

  Future<bool> updateRegistrant(
    String id,
    Map<String, dynamic> registrantData,
  ) async {
    _showLoadingDialog();

    final success = await _provider.updateRegistrant(id, registrantData);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      _showSuccessDialog('Registrant berhasil diupdate');
      return true;
    } else {
      _showErrorDialog(_provider.error ?? 'Gagal mengupdate registrant');
      return false;
    }
  }

  Future<bool> deleteRegistrant(String id) async {
    final confirmed = await _showConfirmationDialog(
      'Hapus Registrant',
      'Apakah Anda yakin ingin menghapus registrant ini?',
    );

    if (!confirmed) return false;

    _showLoadingDialog();

    final success = await _provider.deleteRegistrant(id);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      _showSuccessDialog('Registrant berhasil dihapus');
      return true;
    } else {
      _showErrorDialog(_provider.error ?? 'Gagal menghapus registrant');
      return false;
    }
  }

  Future<void> searchRegistrants(String query) async {
    if (query.isEmpty) {
      await getAllRegistrants(showLoading: false);
      return;
    }

    await _provider.searchRegistrants(query);

    if (_provider.error != null) {
      _showErrorDialog(_provider.error!);
    }
  }

  Future<void> getRegistrantsByStatus(String status) async {
    _showLoadingDialog();

    await _provider.getRegistrantsByStatus(status);

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

  void clearSelectedRegistrant() {
    _provider.clearSelectedRegistrant();
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
      builder: (context) => SafeArea(
        top: false,
        bottom: true,
        child: Container(
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
                  getAllRegistrants();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Registrant'),
                onTap: () {
                  Navigator.pop(context);
                  getAllRegistrants(status: RegistrantStatus.registrant);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_off),
                title: const Text('Inactive'),
                onTap: () {
                  Navigator.pop(context);
                  getAllRegistrants(status: RegistrantStatus.inactive);
                },
              ),
              ListTile(
                leading: const Icon(Icons.free_breakfast),
                title: const Text('Free'),
                onTap: () {
                  Navigator.pop(context);
                  getAllRegistrants(status: RegistrantStatus.free);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Isolir'),
                onTap: () {
                  Navigator.pop(context);
                  getAllRegistrants(status: RegistrantStatus.isolir);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
