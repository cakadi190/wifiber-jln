import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/models/infrastructure.dart';

class InfrastructureWidgets {
  static Widget buildFilterButton(
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
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

  static List<Marker> buildMapMarkers(
    List<InfrastructureItem> items,
    InfrastructureType activeType,
    Function(InfrastructureItem) onMarkerTap,
  ) {
    return items
        .where((item) => item.hasValidCoordinates())
        .map((item) => _buildMarker(item, activeType, onMarkerTap))
        .toList();
  }

  static Marker _buildMarker(
    InfrastructureItem item,
    InfrastructureType activeType,
    Function(InfrastructureItem) onMarkerTap,
  ) {
    final markerStyle = _getMarkerStyle(activeType);

    return Marker(
      point: LatLng(item.lat!, item.lng!),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => onMarkerTap(item),
        child: Container(
          decoration: BoxDecoration(
            color: markerStyle.color,
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
          child: Icon(markerStyle.icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  static Widget buildDataItem(
    InfrastructureItem item,
    InfrastructureType activeType,
    VoidCallback onTap,
  ) {
    final kode = item.getCode(activeType);
    final name = item.name ?? 'N/A';
    final description = item.description ?? 'N/A';
    final status = item.status ?? 'N/A';
    final totalPort = item.totalPort ?? 'N/A';

    return InkWell(
      onTap: onTap,
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
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 6),
            _buildPortInfo(totalPort),
            ..._buildAdditionalInfo(item, activeType),
          ],
        ),
      ),
    );
  }

  static Widget buildDetailSection(String title, List<Widget> items) {
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

  static Widget buildDetailItem(
    IconData icon,
    String label,
    dynamic value, {
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
                if (value is Widget) value,
                if (value is String)
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

  static Widget buildLoadingState(ScrollController scrollController) {
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

  static Widget buildErrorState(
    ScrollController scrollController,
    String error,
    VoidCallback onRetry,
  ) {
    return ListView(
      controller: scrollController,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
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
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildEmptyState(
    ScrollController scrollController,
    String activeFilter,
  ) {
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
                  'Tidak ada data $activeFilter',
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

  static MarkerStyle _getMarkerStyle(InfrastructureType type) {
    switch (type) {
      case InfrastructureType.olt:
        return MarkerStyle(Colors.purple, Icons.router_outlined);
      case InfrastructureType.odp:
        return MarkerStyle(Colors.blue, Icons.router);
      case InfrastructureType.odc:
        return MarkerStyle(Colors.green, Icons.hub);
      case InfrastructureType.customer:
        return MarkerStyle(Colors.orange, Icons.location_pin);
    }
  }

  static Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: status == 'active' ? Colors.green.shade100 : Colors.red.shade100,
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
    );
  }

  static Widget _buildPortInfo(String totalPort) {
    return Row(
      children: [
        Icon(Icons.settings_ethernet, size: 12, color: Colors.grey.shade500),
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
    );
  }

  static List<Widget> _buildAdditionalInfo(
    InfrastructureItem item,
    InfrastructureType activeType,
  ) {
    List<Widget> additionalInfo = [];

    if (item.hasValidCoordinates()) {
      additionalInfo.addAll([
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Lat: ${item.latitude}, Lng: ${item.longitude}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ),
          ],
        ),
      ]);
    }

    if (activeType == InfrastructureType.odp && item.kodeOdc != null) {
      additionalInfo.addAll([
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Text(
            '${item.kodeOdc} - ${item.odcName ?? 'N/A'}',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]);
    }

    if (activeType == InfrastructureType.odc && item.kodeOlt != null) {
      additionalInfo.addAll([
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Text(
            '${item.kodeOlt} - ${item.oltName ?? 'N/A'}',
            style: TextStyle(
              color: Colors.purple.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]);
    }

    return additionalInfo;
  }
}

class MarkerStyle {
  final Color color;
  final IconData icon;

  MarkerStyle(this.color, this.icon);
}
