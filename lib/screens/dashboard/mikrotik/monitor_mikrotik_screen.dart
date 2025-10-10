import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/models/router.dart';
import 'package:wifiber/services/router_os_api_client.dart';

class MonitorMikrotikScreen extends StatefulWidget {
  final RouterModel router;
  final RouterOsApiClient client;
  final String username;
  final int port;
  final bool useSsl;

  const MonitorMikrotikScreen({
    super.key,
    required this.router,
    required this.client,
    required this.username,
    required this.port,
    required this.useSsl,
  });

  @override
  State<MonitorMikrotikScreen> createState() => _MonitorMikrotikScreenState();
}

class _MonitorMikrotikScreenState extends State<MonitorMikrotikScreen> {
  late Future<List<Map<String, String>>> _resourceFuture;
  late Future<List<Map<String, String>>> _interfacesFuture;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  @override
  void dispose() {
    unawaited(widget.client.close());
    super.dispose();
  }

  void _reloadData() {
    _resourceFuture = _fetchSystemResources();
    _interfacesFuture = _fetchInterfaces();
  }

  Future<List<Map<String, String>>> _fetchSystemResources() async {
    return widget.client.runCommand('/system/resource/print');
  }

  Future<List<Map<String, String>>> _fetchInterfaces() async {
    return widget.client.runCommand(
      '/interface/print',
      parameters: {'.proplist': 'name,type,running,disabled,comment'},
    );
  }

  Future<void> _refreshData() async {
    final resourceFuture = _fetchSystemResources();
    final interfacesFuture = _fetchInterfaces();

    setState(() {
      _resourceFuture = resourceFuture;
      _interfacesFuture = interfacesFuture;
    });

    await Future.wait([resourceFuture, interfacesFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: AuthGuard(
        requiredPermissions: const ['integration'],
        child: Scaffold(
          appBar: AppBar(
            title: Text('Monitor ${widget.router.name}'),
            actions: [
              IconButton(
                onPressed: () => _refreshData(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildConnectionCard(),
                const SizedBox(height: 16),
                _buildSystemResourceCard(),
                const SizedBox(height: 16),
                _buildInterfacesCard(),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Koneksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Alamat', widget.router.host),
            _buildInfoRow('Username', widget.username),
            _buildInfoRow('Port', widget.port.toString()),
            _buildInfoRow('Protokol', widget.useSsl ? 'SSL/TLS' : 'TCP'),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemResourceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, String>>>(
          future: _resourceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState('Mengambil data sistem...');
            }

            if (snapshot.hasError) {
              return _buildErrorState(
                'Gagal memuat informasi sistem',
                snapshot.error.toString(),
              );
            }

            final data = snapshot.data;
            final resource = data != null && data.isNotEmpty ? data.first : {};

            if (resource.isEmpty) {
              return const Text('Data sistem tidak tersedia.');
            }

            final entries = resource.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sumber Daya Sistem',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInterfacesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, String>>>(
          future: _interfacesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState('Mengambil data interface...');
            }

            if (snapshot.hasError) {
              return _buildErrorState(
                'Gagal memuat data interface',
                snapshot.error.toString(),
              );
            }

            final interfaces = snapshot.data ?? [];

            if (interfaces.isEmpty) {
              return const Text('Tidak ada data interface tersedia.');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Interface',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...interfaces
                    .take(10)
                    .map(
                      (iface) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.memory,
                                  color: (iface['running'] == 'true')
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    iface['name'] ?? 'Interface',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _buildStatusChip(iface),
                              ],
                            ),
                            if ((iface['comment'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                iface['comment']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              'Tipe: ${iface['type'] ?? '-'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (interfaces.length > 10)
                  Text(
                    '+ ${interfaces.length - 10} interface lainnya',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(Map<String, String> iface) {
    final isDisabled = iface['disabled'] == 'true';
    final isRunning = iface['running'] == 'true';

    Color color;
    String label;

    if (isDisabled) {
      color = Colors.red.shade600;
      label = 'Disabled';
    } else if (isRunning) {
      color = Colors.green.shade600;
      label = 'Running';
    } else {
      color = Colors.orange.shade600;
      label = 'Down';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String title, String details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          details,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      ],
    );
  }
}
