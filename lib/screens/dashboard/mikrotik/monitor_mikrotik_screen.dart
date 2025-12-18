import 'dart:async';
import 'dart:math' as math;

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

class _MonitorMikrotikScreenState extends State<MonitorMikrotikScreen>
    with SingleTickerProviderStateMixin {
  static const int _trafficHistoryLimit = 24;
  static const int _maxInterfacesForTraffic = 6;

  late Future<List<Map<String, String>>> _resourceFuture;
  late Future<List<Map<String, String>>> _interfacesFuture;
  late TabController _tabController;

  final List<Map<String, String>> _interfacesCache = [];
  final List<TrafficSample> _trafficHistory = [];
  final Map<String, InterfaceTraffic> _interfaceTraffic = {};

  Timer? _trafficTimer;
  bool _isFetchingTraffic = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reloadData();
    _startTrafficPolling();
  }

  @override
  void dispose() {
    _trafficTimer?.cancel();
    _tabController.dispose();
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
    final interfaces = await widget.client.runCommand(
      '/interface/print',
      parameters: {'.proplist': 'name,type,running,disabled,comment'},
    );

    _interfacesCache
      ..clear()
      ..addAll(interfaces);

    return interfaces;
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

  void _startTrafficPolling() {
    _trafficTimer?.cancel();
    _trafficTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshTraffic(),
    );
    _refreshTraffic();
  }

  Future<void> _refreshTraffic() async {
    if (_isFetchingTraffic) {
      return;
    }

    _isFetchingTraffic = true;

    try {
      if (_interfacesCache.isEmpty) {
        await _fetchInterfaces();
      }

      final trafficMap = <String, InterfaceTraffic>{};
      double totalDownloadMbps = 0;
      double totalUploadMbps = 0;

      final ispInterfaces = _interfacesCache
          .where((iface) {
            final name = iface['name'] ?? '';
            return name.toUpperCase().startsWith('ISP');
          })
          .toList(growable: false);

      final availableSlots = math.max(
        0,
        _maxInterfacesForTraffic - ispInterfaces.length,
      );
      final otherInterfaces = _interfacesCache
          .where((iface) {
            final name = iface['name'] ?? '';
            return name.isNotEmpty && !name.toUpperCase().startsWith('ISP');
          })
          .take(availableSlots)
          .toList(growable: false);

      final targets = <Map<String, String>>[
        ...ispInterfaces,
        ...otherInterfaces,
      ];

      for (final iface in targets) {
        final ifaceName = iface['name'];
        if (ifaceName == null || ifaceName.isEmpty) {
          continue;
        }

        try {
          final result = await widget.client.runCommand(
            '/interface/monitor-traffic',
            parameters: {
              'interface': ifaceName,
              'once': 'true',
              '.proplist': 'rx-bits-per-second,tx-bits-per-second',
            },
          );

          if (result.isEmpty) {
            continue;
          }

          final data = result.first;
          final rxBits =
              double.tryParse(data['rx-bits-per-second'] ?? '') ?? 0.0;
          final txBits =
              double.tryParse(data['tx-bits-per-second'] ?? '') ?? 0.0;

          final rxMbps = rxBits / 1e6;
          final txMbps = txBits / 1e6;
          final ifaceTraffic = InterfaceTraffic(
            name: ifaceName,
            downloadMbps: rxMbps,
            uploadMbps: txMbps,
          );

          trafficMap[ifaceName] = ifaceTraffic;
          if (ifaceName.toUpperCase().startsWith('ISP')) {
            totalDownloadMbps += rxMbps;
            totalUploadMbps += txMbps;
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _interfaceTraffic
            ..clear()
            ..addAll(trafficMap);

          _trafficHistory.add(
            TrafficSample(
              timestamp: DateTime.now(),
              downloadMbps: totalDownloadMbps,
              uploadMbps: totalUploadMbps,
            ),
          );

          if (_trafficHistory.length > _trafficHistoryLimit) {
            _trafficHistory.removeRange(
              0,
              _trafficHistory.length - _trafficHistoryLimit,
            );
          }
        });
      }
    } catch (_) {
    } finally {
      _isFetchingTraffic = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: AppColors.primary,
      ),
      child: AuthGuard(
        requiredPermissions: const ['integration'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monitor "${widget.router.name}"'),
                Text(widget.client.host, style: const TextStyle(fontSize: 12)),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  _refreshData();
                  _refreshTraffic();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([_refreshData(), _refreshTraffic()]);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTrafficSection(),
                  const SizedBox(height: 16),
                  _buildConnectionSection(),
                  const SizedBox(height: 16),
                  _buildMetricsTabs(),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionSection() {
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
            _buildInfoRow('Nama Router', widget.router.name),
            _buildInfoRow('Alamat', widget.router.host),
            _buildInfoRow('Username', widget.username),
            _buildInfoRow('Port', widget.port.toString()),
            _buildInfoRow('Protokol', widget.useSsl ? 'SSL/TLS' : 'TCP'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficSection() {
    final latest = _trafficHistory.isNotEmpty ? _trafficHistory.last : null;
    final latestValue = latest?.totalMbps ?? 0.0;
    final maxPortTraffic = _interfaceTraffic.values.fold<double>(
      0,
      (previousValue, traffic) => math.max(previousValue, traffic.totalMbps),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Trafik',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Trafik Yang Ada Pada Router',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_formatMbps(latestValue)} Mb/s',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 180,
              child: TrafficChart(
                samples: List.unmodifiable(_trafficHistory),
                downloadColor: Colors.red,
                uploadColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            if (latest != null) ...[
              Row(
                children: [
                  _buildTrafficLegend(
                    color: AppColors.primary,
                    label: 'Unggah',
                    value: _formatMbps(latest.uploadMbps),
                  ),
                  const SizedBox(width: 12),
                  _buildTrafficLegend(
                    color: Colors.red,
                    label: 'Unduh',
                    value: _formatMbps(latest.downloadMbps),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            if (_interfaceTraffic.isEmpty)
              Text(
                'Menunggu data trafik interface...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _interfaceTraffic.values.map((traffic) {
                  final ratio = maxPortTraffic <= 0
                      ? 0.0
                      : (traffic.totalMbps / maxPortTraffic)
                            .clamp(0.0, 1.0)
                            .toDouble();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                traffic.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              'D ${_formatMbps(traffic.downloadMbps)} / U ${_formatMbps(traffic.uploadMbps)} Mb/s',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficLegend({
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label: $value Mb/s',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsTabs() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey.shade600,
            tabs: const [
              Tab(text: 'Sumber Daya Sistem'),
              Tab(text: 'Daftar Interface'),
            ],
          ),
          const Divider(height: 1),
          SizedBox(
            height: 360,
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSystemResourceTab(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildInterfacesTab(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemResourceTab() {
    return FutureBuilder<List<Map<String, String>>>(
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

        return ListView.builder(
          itemCount: entries.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
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
            );
          },
        );
      },
    );
  }

  Widget _buildInterfacesTab() {
    return FutureBuilder<List<Map<String, String>>>(
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

        return ListView.builder(
          itemCount: interfaces.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final iface = interfaces[index];
            return Container(
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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          },
        );
      },
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
            width: 125,
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
          onPressed: () {
            _refreshData();
            _refreshTraffic();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      ],
    );
  }

  String _formatMbps(double value) {
    if (value >= 100) {
      return value.toStringAsFixed(0);
    }
    if (value >= 10) {
      return value.toStringAsFixed(1);
    }
    return value.toStringAsFixed(2);
  }
}

class InterfaceTraffic {
  InterfaceTraffic({
    required this.name,
    required this.downloadMbps,
    required this.uploadMbps,
  });

  final String name;
  final double downloadMbps;
  final double uploadMbps;

  double get totalMbps => downloadMbps + uploadMbps;
}

class TrafficSample {
  TrafficSample({
    required this.timestamp,
    required this.downloadMbps,
    required this.uploadMbps,
  });

  final DateTime timestamp;
  final double downloadMbps;
  final double uploadMbps;

  double get totalMbps => downloadMbps + uploadMbps;
}

class TrafficChart extends StatelessWidget {
  const TrafficChart({
    super.key,
    required this.samples,
    required this.downloadColor,
    required this.uploadColor,
  });

  final List<TrafficSample> samples;
  final Color downloadColor;
  final Color uploadColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrafficChartPainter(
        samples: samples,
        downloadColor: downloadColor,
        uploadColor: uploadColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class TrafficChartPainter extends CustomPainter {
  TrafficChartPainter({
    required this.samples,
    required this.downloadColor,
    required this.uploadColor,
  });

  final List<TrafficSample> samples;
  final Color downloadColor;
  final Color uploadColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty || size.isEmpty) return;

    final horizontalPadding = 0.0;
    final verticalPadding = 12.0;
    final chartWidth = size.width - (horizontalPadding * 2);
    final chartHeight = size.height - (verticalPadding * 2);

    final maxValue = samples.fold<double>(
      0,
      (prev, s) => math.max(prev, math.max(s.downloadMbps, s.uploadMbps)),
    );
    final effectiveMax = maxValue <= 0 ? 1.0 : maxValue;
    final dx = chartWidth / math.max(1, samples.length - 1);

    Path smoothPath(List<double> values) {
      final path = Path();
      if (values.isEmpty) return path;

      List<Offset> points = [
        for (var i = 0; i < values.length; i++)
          Offset(
            horizontalPadding + dx * i,
            verticalPadding +
                chartHeight * (1 - (values[i] / effectiveMax).clamp(0.0, 1.0)),
          ),
      ];

      if (points.length < 2) return path;
      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = i > 0 ? points[i - 1] : points[i];
        final p1 = points[i];
        final p2 = points[i + 1];
        final p3 = i != points.length - 2 ? points[i + 2] : p2;

        final cp1 = Offset(
          p1.dx + (p2.dx - p0.dx) / 6,
          p1.dy + (p2.dy - p0.dy) / 6,
        );
        final cp2 = Offset(
          p2.dx - (p3.dx - p1.dx) / 6,
          p2.dy - (p3.dy - p1.dy) / 6,
        );
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
      }

      return path;
    }

    final downloadValues = samples.map((e) => e.downloadMbps).toList();
    final uploadValues = samples.map((e) => e.uploadMbps).toList();

    final downloadPath = smoothPath(downloadValues);
    final uploadPath = smoothPath(uploadValues);

    final downloadFill = Path.from(downloadPath)
      ..lineTo(
        horizontalPadding + dx * (samples.length - 1),
        chartHeight + verticalPadding,
      )
      ..lineTo(horizontalPadding, chartHeight + verticalPadding)
      ..close();

    final uploadFill = Path.from(uploadPath)
      ..lineTo(
        horizontalPadding + dx * (samples.length - 1),
        chartHeight + verticalPadding,
      )
      ..lineTo(horizontalPadding, chartHeight + verticalPadding)
      ..close();

    final downloadFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = downloadColor.withValues(alpha: 0.1)
      ..isAntiAlias = true;
    final uploadFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = uploadColor.withValues(alpha: 0.1)
      ..isAntiAlias = true;

    canvas.drawPath(downloadFill, downloadFillPaint);
    canvas.drawPath(uploadFill, uploadFillPaint);

    final downloadLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = downloadColor
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final uploadLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = uploadColor
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(downloadPath, downloadLinePaint);
    canvas.drawPath(uploadPath, uploadLinePaint);
  }

  @override
  bool shouldRepaint(covariant TrafficChartPainter old) =>
      old.samples != samples ||
      old.downloadColor != downloadColor ||
      old.uploadColor != uploadColor;
}
