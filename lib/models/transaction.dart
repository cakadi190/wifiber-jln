class Transaction {
  final int id;
  final int nominal;
  final String description;
  final String? image;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? type;
  final String? createdBy;

  Transaction({
    required this.id,
    required this.nominal,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.image,
    this.type,
    this.createdBy,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: int.parse(json['id']),
      nominal: int.parse(json['nominal']),
      description: json['description'],
      image: json['image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      type: json['type'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nominal': nominal,
      'description': description,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type': type,
      'created_by': createdBy,
    };
  }
}
