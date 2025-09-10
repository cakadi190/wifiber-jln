import 'package:meta/meta.dart';

@immutable
class PackageModel {
  final String id;
  final String name;
  final String? description;
  final int price;
  final int ppnPercent;
  final String status;
  final String? createdAt;
  final int? priceWithPpn;

  const PackageModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.ppnPercent,
    required this.status,
    this.createdAt,
    this.priceWithPpn,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] as String?,
      price: json['price'] is int
          ? json['price']
          : int.tryParse(json['price'].toString()) ?? 0,
      ppnPercent: json['ppn_percent'] is int
          ? json['ppn_percent']
          : int.tryParse(json['ppn_percent'].toString()) ?? 0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] as String?,
      priceWithPpn: json['price_with_ppn'] is int
          ? json['price_with_ppn']
          : int.tryParse(json['price_with_ppn']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'ppn_percent': ppnPercent,
      'status': status,
      'created_at': createdAt,
      'price_with_ppn': priceWithPpn,
    };
  }
}
