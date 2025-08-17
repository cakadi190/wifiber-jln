import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wifiber/services/http_service.dart';

class Area {
  final String id;
  final String code;
  final String name;
  final String description;
  final String status;
  final String createdAt;

  Area({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

typedef AreaSelectedCallback = void Function(Area area);

class AreaButtonSelector extends StatefulWidget {
  final String? selectedAreaId;
  final String? selectedAreaName;
  final AreaSelectedCallback onAreaSelected;

  const AreaButtonSelector({
    super.key,
    this.selectedAreaId,
    this.selectedAreaName,
    required this.onAreaSelected,
  });

  @override
  State<AreaButtonSelector> createState() => _AreaButtonSelectorState();
}

class _AreaButtonSelectorState extends State<AreaButtonSelector> {
  final HttpService _http = HttpService();

  List<Area> _areas = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _http.get('/areas', requiresAuth: true);
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        final List list = jsonResponse['data'];
        _areas = list.map((e) => Area.fromJson(e)).toList();
      } else {
        _error = 'Failed to load areas';
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    setState(() {
      _loading = false;
    });
  }

  void _showAreaPicker() {
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
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.map, color: Colors.blue, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Pilih Area',
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
            Text('Memuat area...'),
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
              onPressed: _fetchAreas,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    if (_areas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'Tidak ada area tersedia',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _areas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final area = _areas[index];
        final isSelected = area.id == widget.selectedAreaId;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Colors.green.withValues(alpha: 0.05)
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
                widget.onAreaSelected(area);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.map,
                        color: isSelected ? Colors.green : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.green[700]
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            area.code,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.green[600]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.green : Colors.transparent,
                        border: Border.all(
                          color:
                              isSelected ? Colors.green : Colors.grey[400]!,
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
    final displayText = widget.selectedAreaName ?? '';
    return GestureDetector(
      onTap: _showAreaPicker,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Pilih Area',
            hintText: 'Pilih Area',
            prefixIcon: const Icon(Icons.map),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green[600]!),
            ),
          ),
          controller: TextEditingController(text: displayText),
          readOnly: true,
        ),
      ),
    );
  }
}

