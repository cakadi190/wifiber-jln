import 'package:flutter/material.dart';

class InfrastructureItem {
  final String? id;
  final String? oltId;
  final String? odcId;
  final String? kodeOlt;
  final String? kodeOdp;
  final String? kodeOdc;
  final String? name;
  final String? description;
  final String? status;
  final String? totalPort;
  final String? latitude;
  final String? longitude;
  final String? oltName;
  final String? odcName;

  InfrastructureItem({
    this.id,
    this.oltId,
    this.kodeOlt,
    this.kodeOdp,
    this.odcId,
    this.kodeOdc,
    this.name,
    this.description,
    this.status,
    this.totalPort,
    this.latitude,
    this.longitude,
    this.oltName,
    this.odcName,
  });

  factory InfrastructureItem.fromJson(Map<String, dynamic> json) {
    return InfrastructureItem(
      id: json['id']?.toString(),
      oltId: json['olt_id']?.toString(),
      odcId: json['odc_id']?.toString(),
      kodeOlt: json['kode_olt'],
      kodeOdp: json['kode_odp'],
      kodeOdc: json['kode_odc'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      totalPort: json['total_port']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      oltName: json['olt_name'],
      odcName: json['odc_name'],
    );
  }

  String getCode(InfrastructureType type) {
    switch (type) {
      case InfrastructureType.olt:
        return kodeOlt ?? 'N/A';
      case InfrastructureType.odp:
        return kodeOdp ?? 'N/A';
      case InfrastructureType.odc:
        return kodeOdc ?? 'N/A';
    }
  }

  bool hasValidCoordinates() {
    final lat = double.tryParse(latitude ?? '');
    final lng = double.tryParse(longitude ?? '');
    return lat != null && lng != null;
  }

  double? get lat => double.tryParse(latitude ?? '');
  double? get lng => double.tryParse(longitude ?? '');
}

enum InfrastructureType { olt, odp, odc }

extension InfrastructureTypeExtension on InfrastructureType {
  String get displayName {
    switch (this) {
      case InfrastructureType.olt:
        return 'OLT';
      case InfrastructureType.odp:
        return 'ODP';
      case InfrastructureType.odc:
        return 'ODC';
    }
  }

  String get endpoint {
    switch (this) {
      case InfrastructureType.olt:
        return 'olts';
      case InfrastructureType.odp:
        return 'odps';
      case InfrastructureType.odc:
        return 'odcs';
    }
  }

  IconData get icon {
    switch (this) {
      case InfrastructureType.olt:
        return Icons.router;
      case InfrastructureType.odp:
        return Icons.cable;
      case InfrastructureType.odc:
        return Icons.hub;
    }
  }
}