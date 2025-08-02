import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/services/http_service.dart';

class _AlwaysWinPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'alwaysWin';
}

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

  List<dynamic> _olts = [];
  List<dynamic> _odps = [];
  List<dynamic> _odcs = [];

  bool _isLoadingOlts = false;
  bool _isLoadingOdps = false;
  bool _isLoadingOdcs = false;

  String? _errorOlts;
  String? _errorOdps;
  String? _errorOdcs;

  String _activeFilter = 'OLT';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadInitialData();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _loadInitialData() {
    _loadOlts();
  }

  Future<void> _loadOlts() async {
    setState(() {
      _isLoadingOlts = true;
      _errorOlts = null;
    });

    try {
      final response = await _http.get('olts', requiresAuth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _olts = data['data'] ?? [];
          _isLoadingOlts = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorOlts = e.toString();
        _isLoadingOlts = false;
      });
    }
  }

  Future<void> _loadOdps() async {
    setState(() {
      _isLoadingOdps = true;
      _errorOdps = null;
    });

    try {
      final response = await _http.get('odps', requiresAuth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _odps = data['data'] ?? [];
          _isLoadingOdps = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorOdps = e.toString();
        _isLoadingOdps = false;
      });
    }
  }

  Future<void> _loadOdcs() async {
    setState(() {
      _isLoadingOdcs = true;
      _errorOdcs = null;
    });

    try {
      final response = await _http.get('odcs', requiresAuth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _odcs = data['data'] ?? [];
          _isLoadingOdcs = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorOdcs = e.toString();
        _isLoadingOdcs = false;
      });
    }
  }

  void _onFilterTap(String filter) {
    setState(() {
      _activeFilter = filter;
    });

    switch (filter) {
      case 'OLT':
        _loadOlts();
        break;
      case 'ODP':
        _loadOdps();
        break;
      case 'ODC':
        _loadOdcs();
        break;
    }
  }

  List<dynamic> get _currentData {
    switch (_activeFilter) {
      case 'OLT':
        return _olts;
      case 'ODP':
        return _odps;
      case 'ODC':
        return _odcs;
      default:
        return [];
    }
  }

  bool get _isCurrentLoading {
    switch (_activeFilter) {
      case 'OLT':
        return _isLoadingOlts;
      case 'ODP':
        return _isLoadingOdps;
      case 'ODC':
        return _isLoadingOdcs;
      default:
        return false;
    }
  }

  String? get _currentError {
    switch (_activeFilter) {
      case 'OLT':
        return _errorOlts;
      case 'ODP':
        return _errorOdps;
      case 'ODC':
        return _errorOdcs;
      default:
        return null;
    }
  }

  void _refreshCurrentData() {
    switch (_activeFilter) {
      case 'OLT':
        _loadOlts();
        break;
      case 'ODP':
        _loadOdps();
        break;
      case 'ODC':
        _loadOdcs();
        break;
    }
  }

  List<Marker> _buildMapMarkers() {
    List<Marker> markers = [];

    for (var odp in _odps) {
      if (odp['latitude'] != null && odp['longitude'] != null) {
        final lat = double.tryParse(odp['latitude'].toString());
        final lng = double.tryParse(odp['longitude'].toString());
        if (lat != null && lng != null) {
          markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showMarkerInfo(odp, 'ODP'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.router, color: Colors.white, size: 20),
                ),
              ),
            ),
          );
        }
      }
    }

    for (var odc in _odcs) {
      if (odc['latitude'] != null && odc['longitude'] != null) {
        final lat = double.tryParse(odc['latitude'].toString());
        final lng = double.tryParse(odc['longitude'].toString());
        if (lat != null && lng != null) {
          markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showMarkerInfo(odc, 'ODC'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.hub, color: Colors.white, size: 20),
                ),
              ),
            ),
          );
        }
      }
    }

    return markers;
  }

  void _showMarkerInfo(dynamic item, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$type Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kode: ${item['kode_${type.toLowerCase()}'] ?? 'N/A'}'),
              Text('Nama: ${item['name'] ?? 'N/A'}'),
              Text('Status: ${item['status'] ?? 'N/A'}'),
              Text('Total Port: ${item['total_port'] ?? 'N/A'}'),
              if (item['description'] != null)
                Text('Deskripsi: ${item['description']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup'),
            ),
          ],
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
    String createdAt = '';
    List<Widget> additionalInfo = [];

    switch (_activeFilter) {
      case 'OLT':
        kode = item['kode_olt'] ?? 'N/A';
        name = item['name'] ?? 'N/A';
        description = item['description'] ?? 'N/A';
        status = item['status'] ?? 'N/A';
        totalPort = item['total_port'] ?? 'N/A';
        createdAt = item['created_at'] ?? 'N/A';
        break;
      case 'ODP':
        kode = item['kode_odp'] ?? 'N/A';
        name = item['name'] ?? 'N/A';
        description = item['description'] ?? 'N/A';
        status = item['status'] ?? 'N/A';
        totalPort = item['total_port'] ?? 'N/A';
        createdAt = item['created_at'] ?? 'N/A';
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
                'ODC: ${item['kode_odc']} - ${item['odc_name'] ?? 'N/A'}',
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
        createdAt = item['created_at'] ?? 'N/A';
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
                'OLT: ${item['kode_olt']} - ${item['olt_name'] ?? 'N/A'}',
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

    return Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              const Spacer(),
              Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                createdAt.split(' ')[0],
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
          ...additionalInfo,
        ],
      ),
    );
  }

  Widget _buildScrollableContent(ScrollController scrollController) {
    if (_isCurrentLoading) {
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

    if (_currentError != null) {
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
                    _currentError!,
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

            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.filter_list, color: Colors.white),
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
                          RawGestureDetector(
                            gestures: <Type, GestureRecognizerFactory>{
                              _AlwaysWinPanGestureRecognizer:
                                  GestureRecognizerFactoryWithHandlers<
                                    _AlwaysWinPanGestureRecognizer
                                  >(() => _AlwaysWinPanGestureRecognizer(), (
                                    _AlwaysWinPanGestureRecognizer instance,
                                  ) {
                                    instance
                                      ..onStart = (details) {
                                        print(
                                          'Pan start: ${details.localPosition}',
                                        );
                                      }
                                      ..onUpdate = (details) {
                                        double currentSize =
                                            _draggableController.size;
                                        double delta =
                                            details.delta.dy /
                                            MediaQuery.of(context).size.height;
                                        double newSize = currentSize - delta;
                                        newSize = newSize.clamp(0.1, 0.9);

                                        _draggableController.animateTo(
                                          newSize,
                                          duration: const Duration(
                                            milliseconds: 50,
                                          ),
                                          curve: Curves.linear,
                                        );
                                      }
                                      ..onEnd = (details) {
                                        double currentSize =
                                            _draggableController.size;
                                        double velocity =
                                            details.velocity.pixelsPerSecond.dy;

                                        double targetSize;
                                        if (velocity.abs() > 500) {
                                          if (velocity < 0) {
                                            targetSize = currentSize < 0.4
                                                ? 0.5
                                                : 0.9;
                                          } else {
                                            targetSize = currentSize > 0.6
                                                ? 0.5
                                                : 0.25;
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
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeOut,
                                        );
                                      };
                                  }),
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 16, top: 8),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 40,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[400],
                                          borderRadius: BorderRadius.circular(
                                            3,
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
