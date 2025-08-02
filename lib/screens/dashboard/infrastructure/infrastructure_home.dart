import 'package:wifiber/config/app_colors.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:maps_launcher/maps_launcher.dart';

class InfrastructureHome extends StatefulWidget {
  const InfrastructureHome({super.key});

  @override
  State<InfrastructureHome> createState() => _InfrastructureHomeState();
}

class _InfrastructureHomeState extends State<InfrastructureHome> {
  late MapController _mapController;
  final HttpService _http = HttpService();
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();

  List<dynamic> _currentData = [];
  bool _isLoading = false;
  String? _error;
  String _activeFilter = 'OLT';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadDataForFilter(_activeFilter);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _loadDataForFilter(String filter) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String endpoint;
      switch (filter) {
        case 'OLT':
          endpoint = 'olts';
          break;
        case 'ODP':
          endpoint = 'odps';
          break;
        case 'ODC':
          endpoint = 'odcs';
          break;
        default:
          endpoint = 'olts';
      }

      final response = await _http.get(endpoint, requiresAuth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentData = data['data'] ?? [];
          _isLoading = false;
        });

        _animateMapToDataCenter();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _animateMapToDataCenter() {
    if (_currentData.isEmpty) return;

    List<LatLng> coordinates = [];

    for (var item in _currentData) {
      if (item['latitude'] != null && item['longitude'] != null) {
        final lat = double.tryParse(item['latitude'].toString());
        final lng = double.tryParse(item['longitude'].toString());
        if (lat != null && lng != null) {
          coordinates.add(LatLng(lat, lng));
        }
      }
    }

    if (coordinates.isEmpty) return;

    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (var coord in coordinates) {
      minLat = minLat < coord.latitude ? minLat : coord.latitude;
      maxLat = maxLat > coord.latitude ? maxLat : coord.latitude;
      minLng = minLng < coord.longitude ? minLng : coord.longitude;
      maxLng = maxLng > coord.longitude ? maxLng : coord.longitude;
    }

    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;

    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;
    double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    maxDiff = maxDiff * 1.2;

    double zoomLevel;
    if (maxDiff > 0.5) {
      zoomLevel = 9.0;
    } else if (maxDiff > 0.2) {
      zoomLevel = 10.5;
    } else if (maxDiff > 0.1) {
      zoomLevel = 11.5;
    } else if (maxDiff > 0.05) {
      zoomLevel = 12.5;
    } else if (maxDiff > 0.02) {
      zoomLevel = 13.5;
    } else {
      zoomLevel = 14.0;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController.move(LatLng(centerLat, centerLng), zoomLevel);
    });
  }

  void _onFilterTap(String filter) {
    if (_activeFilter == filter) return;

    setState(() {
      _activeFilter = filter;
    });

    _loadDataForFilter(filter);
  }

  void _refreshCurrentData() {
    _loadDataForFilter(_activeFilter);
  }

  List<Marker> _buildMapMarkers() {
    List<Marker> markers = [];

    for (var item in _currentData) {
      if (item['latitude'] != null && item['longitude'] != null) {
        final lat = double.tryParse(item['latitude'].toString());
        final lng = double.tryParse(item['longitude'].toString());
        if (lat != null && lng != null) {
          Color markerColor;
          IconData markerIcon;

          switch (_activeFilter) {
            case 'OLT':
              markerColor = Colors.purple;
              markerIcon = Icons.router_outlined;
              break;
            case 'ODP':
              markerColor = Colors.blue;
              markerIcon = Icons.router;
              break;
            case 'ODC':
              markerColor = Colors.green;
              markerIcon = Icons.hub;
              break;
            default:
              markerColor = Colors.grey;
              markerIcon = Icons.location_on;
          }

          markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showMarkerInfo(item, _activeFilter),
                child: Container(
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(markerIcon, color: Colors.white, size: 20),
                ),
              ),
            ),
          );
        }
      }
    }

    return markers;
  }

  // Added missing _buildMarkers method for modal bottom sheet
  List<Marker> _buildMarkers(dynamic item) {
    final lat = double.tryParse(item['latitude'].toString());
    final lng = double.tryParse(item['longitude'].toString());

    if (lat == null || lng == null) return [];

    Color markerColor;
    IconData markerIcon;

    switch (_activeFilter) {
      case 'OLT':
        markerColor = Colors.purple;
        markerIcon = Icons.router_outlined;
        break;
      case 'ODP':
        markerColor = Colors.blue;
        markerIcon = Icons.router;
        break;
      case 'ODC':
        markerColor = Colors.green;
        markerIcon = Icons.hub;
        break;
      default:
        markerColor = Colors.grey;
        markerIcon = Icons.location_on;
    }

    return [
      Marker(
        point: LatLng(lat, lng),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(markerIcon, color: Colors.white, size: 20),
        ),
      ),
    ];
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    Color? statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: statusColor ?? Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkerInfo(dynamic item, String type) {
    String kode = '';
    switch (type) {
      case 'OLT':
        kode = item['kode_olt'] ?? 'N/A';
        break;
      case 'ODP':
        kode = item['kode_odp'] ?? 'N/A';
        break;
      case 'ODC':
        kode = item['kode_odc'] ?? 'N/A';
        break;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection('$type Info', [
                  _buildDetailItem(Icons.info, 'Kode', kode),
                  _buildDetailItem(Icons.info, 'Nama', item['name'] ?? 'N/A'),
                  _buildDetailItem(
                    Icons.info,
                    'Status',
                    item['status'] ?? 'N/A',
                  ),
                  _buildDetailItem(
                    Icons.info,
                    'Total Port',
                    item['total_port'] ?? 'N/A',
                  ),
                  if (item['description'] != null)
                    _buildDetailItem(
                      Icons.info,
                      'Deskripsi',
                      item['description'] ?? 'N/A',
                    ),
                  if (item['latitude'] != null && item['longitude'] != null)
                    _buildDetailItem(
                      Icons.info,
                      'Koordinat',
                      '${item['latitude']}, ${item['longitude']}',
                    ),
                ]),
                if (item['latitude'] != null && item['longitude'] != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection('Peta', [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 300,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(
                              double.tryParse(item['latitude'].toString()) ??
                                  0.0,
                              double.tryParse(item['longitude'].toString()) ??
                                  0.0,
                            ),
                            initialZoom: 16,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: ['a', 'b', 'c'],
                            ),
                            MarkerLayer(markers: _buildMarkers(item)),
                          ],
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final lat = double.tryParse(
                            item['latitude'].toString(),
                          );
                          final lng = double.tryParse(
                            item['longitude'].toString(),
                          );
                          if (lat != null && lng != null) {
                            MapsLauncher.launchCoordinates(lat, lng);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primary,
                        ),
                        icon: const Icon(Icons.map),
                        label: const Text('Buka di Maps'),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text('Tutup'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(String label) {
    final isActive = _activeFilter == label;
    return InkWell(
      onTap: () => _onFilterTap(label),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: isActive ? Colors.blue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(24),
          color: isActive ? Colors.blue.shade50 : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDataItem(dynamic item) {
    String kode = '';
    String name = '';
    String description = '';
    String status = '';
    String totalPort = '';
    List<Widget> additionalInfo = [];

    switch (_activeFilter) {
      case 'OLT':
        kode = item['kode_olt'] ?? 'N/A';
        name = item['name'] ?? 'N/A';
        description = item['description'] ?? 'N/A';
        status = item['status'] ?? 'N/A';
        totalPort = item['total_port'] ?? 'N/A';
        break;
      case 'ODP':
        kode = item['kode_odp'] ?? 'N/A';
        name = item['name'] ?? 'N/A';
        description = item['description'] ?? 'N/A';
        status = item['status'] ?? 'N/A';
        totalPort = item['total_port'] ?? 'N/A';
        additionalInfo = [
          if (item['latitude'] != null && item['longitude'] != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Lat: ${item['latitude']}, Lng: ${item['longitude']}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
          if (item['kode_odc'] != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                '${item['kode_odc']} - ${item['odc_name'] ?? 'N/A'}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ];
        break;
      case 'ODC':
        kode = item['kode_odc'] ?? 'N/A';
        name = item['name'] ?? 'N/A';
        description = item['description'] ?? 'N/A';
        status = item['status'] ?? 'N/A';
        totalPort = item['total_port'] ?? 'N/A';
        additionalInfo = [
          if (item['latitude'] != null && item['longitude'] != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Lat: ${item['latitude']}, Lng: ${item['longitude']}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
          if (item['kode_olt'] != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Text(
                '${item['kode_olt']} - ${item['olt_name'] ?? 'N/A'}',
                style: TextStyle(
                  color: Colors.purple.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ];
        break;
    }

    return InkWell(
      onTap: () {
        _showMarkerInfo(item, _activeFilter);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$kode - $name',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'active'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: status == 'active'
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.settings_ethernet,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  'Port: $totalPort',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            ...additionalInfo,
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(ScrollController scrollController) {
    if (_isLoading) {
      return ListView(
        controller: scrollController,
        children: const [
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gagal memuat data',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refreshCurrentData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_currentData.isEmpty) {
      return ListView(
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada data $_activeFilter',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _currentData.length,
      itemBuilder: (context, index) {
        return _buildDataItem(_currentData[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: Colors.transparent,
        navigationBarColor: Colors.white,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: colorScheme.surface,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(-6.17511, 106.86503),
                  initialZoom: 13.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.kodinus.wifiber',
                  ),
                  MarkerLayer(markers: _buildMapMarkers()),
                ],
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            DraggableScrollableSheet(
              minChildSize: 0.1,
              initialChildSize: 0.25,
              maxChildSize: 0.9,
              snap: true,
              controller: _draggableController,
              snapSizes: const [0.25, 0.5, 0.9],
              builder:
                  (BuildContext context, ScrollController scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onVerticalDragStart: (details) {},
                            onVerticalDragUpdate: (details) {
                              double currentSize = _draggableController.size;
                              double delta =
                                  details.primaryDelta! /
                                  MediaQuery.of(context).size.height;
                              double newSize = currentSize - delta;
                              newSize = newSize.clamp(0.1, 0.9);
                              _draggableController.animateTo(
                                newSize,
                                duration: const Duration(milliseconds: 50),
                                curve: Curves.linear,
                              );
                            },
                            onVerticalDragEnd: (details) {
                              double currentSize = _draggableController.size;
                              double velocity = details.primaryVelocity ?? 0;
                              double targetSize;

                              if (velocity.abs() > 500) {
                                if (velocity < 0) {
                                  targetSize = currentSize < 0.4 ? 0.5 : 0.9;
                                } else {
                                  targetSize = currentSize > 0.6 ? 0.5 : 0.25;
                                }
                              } else {
                                if (currentSize < 0.35) {
                                  targetSize = 0.25;
                                } else if (currentSize < 0.7) {
                                  targetSize = 0.5;
                                } else {
                                  targetSize = 0.9;
                                }
                              }

                              _draggableController.animateTo(
                                targetSize,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: 16, top: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: SizedBox(
                                    width: 40,
                                    height: 6,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Row(
                              children: [
                                _buildFilterButton('OLT'),
                                const SizedBox(width: 8),
                                _buildFilterButton('ODP'),
                                const SizedBox(width: 8),
                                _buildFilterButton('ODC'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Expanded(
                            child: _buildScrollableContent(scrollController),
                          ),
                        ],
                      ),
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }
}
