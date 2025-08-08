import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wifiber/services/http_service.dart';

class Odp {
  final String id;
  final String odcId;
  final String kodeOdp;
  final String name;
  final String description;
  final String status;
  final String latitude;
  final String longitude;
  final String totalPort;
  final String createdAt;
  final String kodeOdc;
  final String odcName;
  final String odcDescription;
  final String odcStatus;
  final String odcTotalPort;

  Odp({
    required this.id,
    required this.odcId,
    required this.kodeOdp,
    required this.name,
    required this.description,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.totalPort,
    required this.createdAt,
    required this.kodeOdc,
    required this.odcName,
    required this.odcDescription,
    required this.odcStatus,
    required this.odcTotalPort,
  });

  factory Odp.fromJson(Map<String, dynamic> json) {
    return Odp(
      id: json['id'] as String,
      odcId: json['odc_id'] as String,
      kodeOdp: json['kode_odp'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      totalPort: json['total_port'] as String,
      createdAt: json['created_at'] as String,
      kodeOdc: json['kode_odc'] as String,
      odcName: json['odc_name'] as String,
      odcDescription: json['odc_description'] as String,
      odcStatus: json['odc_status'] as String,
      odcTotalPort: json['odc_total_port'] as String,
    );
  }
}

typedef OdpSelectedCallback = void Function(Odp odp);

class OdpButtonSelector extends StatefulWidget {
  final String? selectedOdpId;
  final String? selectedOdpName;
  final OdpSelectedCallback onOdpSelected;

  const OdpButtonSelector({
    super.key,
    this.selectedOdpId,
    this.selectedOdpName,
    required this.onOdpSelected,
  });

  @override
  State<OdpButtonSelector> createState() => _OdpButtonSelectorState();
}

class _OdpButtonSelectorState extends State<OdpButtonSelector> {
  final HttpService _http = HttpService();

  List<Odp> _odps = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOdps();
  }

  Future<void> _fetchOdps() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _http.get('/odps', requiresAuth: true);
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        final List list = jsonResponse['data'];
        _odps = list.map((e) => Odp.fromJson(e)).toList();
      } else {
        _error = 'Failed to load ODPs';
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    setState(() {
      _loading = false;
    });
  }

  void _showOdpPicker() {
    if (_loading) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.router, color: Colors.blue, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Pilih ODP',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            shape: const CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: Colors.grey.shade300),

                  // Content
                  Expanded(child: _buildContent(scrollController)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat ODP...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchOdps,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_odps.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'Tidak ada ODP tersedia',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _odps.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final odp = _odps[index];
        final isSelected = odp.id == widget.selectedOdpId;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Colors.blue.withValues(alpha: 0.05)
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pop(context);
                widget.onOdpSelected(odp);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // ODP Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.router,
                        color: isSelected ? Colors.blue : Colors.grey[600],
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ODP Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                odp.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.blue[700]
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  odp.kodeOdp,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            odp.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.blue[600]
                                  : Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.withValues(alpha: 0.2)
                                      : Colors.purple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${odp.totalPort} Port',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.blue[700]
                                        : Colors.purple[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: odp.status == 'active'
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  odp.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: odp.status == 'active'
                                        ? Colors.green[600]
                                        : Colors.orange[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Selection Indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.blue : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.selectedOdpName ?? '';

    return GestureDetector(
      onTap: _showOdpPicker,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Pilih ODP',
            hintText: 'Pilih ODP',
            prefixIcon: const Icon(Icons.router),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
          ),
          controller: TextEditingController(text: displayText),
          readOnly: true,
        ),
      ),
    );
  }
}
