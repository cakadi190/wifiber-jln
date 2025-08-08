import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/services/http_service.dart';

class Package {
  final String id;
  final String name;
  final String description;
  final int price;
  final int ppnPercent;
  final String status;
  final int priceWithPpn;

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.ppnPercent,
    required this.status,
    required this.priceWithPpn,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      ppnPercent: json['ppn_percent'] as int,
      status: json['status'] as String,
      priceWithPpn: json['price_with_ppn'] as int,
    );
  }
}

typedef PackageSelectedCallback = void Function(Package package);

class PackageButtonSelector extends StatefulWidget {
  final String? selectedPackageId;
  final String? selectedPackageName;
  final PackageSelectedCallback onPackageSelected;

  const PackageButtonSelector({
    super.key,
    this.selectedPackageId,
    this.selectedPackageName,
    required this.onPackageSelected,
  });

  @override
  State<PackageButtonSelector> createState() => _PackageButtonSelectorState();
}

class _PackageButtonSelectorState extends State<PackageButtonSelector> {
  final HttpService _http = HttpService();

  List<Package> _packages = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _http.get('/packages', requiresAuth: true);
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        final List list = jsonResponse['data'];
        _packages = list.map((e) => Package.fromJson(e)).toList();
      } else {
        _error = 'Failed to load packages';
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    setState(() {
      _loading = false;
    });
  }

  void _showPackagePicker() {
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
                        const Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Pilih Paket',
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
            Text('Memuat paket...'),
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
              onPressed: _fetchPackages,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_packages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'Tidak ada paket tersedia',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _packages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final package = _packages[index];
        final isSelected = package.id == widget.selectedPackageId;

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
                widget.onPackageSelected(package);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Package Icon
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
                        Icons.wifi,
                        color: isSelected ? Colors.green : Colors.grey[600],
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Package Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
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
                            package.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.green[600]
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
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  CurrencyHelper.formatCurrency(
                                    package.priceWithPpn,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.green[700]
                                        : Colors.blue[700],
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
                                  color: package.status == 'active'
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  package.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: package.status == 'active'
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
                        color: isSelected ? Colors.green : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey[400]!,
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
    final displayText = widget.selectedPackageName ?? '';

    return GestureDetector(
      onTap: _showPackagePicker,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Pilih Paket',
            hintText: 'Pilih Paket',
            prefixIcon: const Icon(Icons.star),
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
