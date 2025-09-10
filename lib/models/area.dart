import 'package:meta/meta.dart';

@immutable
class AreaModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String status;
  final String? createdAt;

  const AreaModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.status,
    this.createdAt,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'].toString(),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] as String?,
      status: json['status'] ?? '',
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'status': status,
      'created_at': createdAt,
    };
  }
}
