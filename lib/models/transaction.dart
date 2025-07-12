class Transaction {
  final int id;
  final int amount;
  final String description;
  final String? proof;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? type;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.proof,
    this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: int.parse(json['id']),
      amount: int.parse(json['nominal']),
      description: json['description'],
      proof: json['proof'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'proof': proof,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type': type,
    };
  }
}
