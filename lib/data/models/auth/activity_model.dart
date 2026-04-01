enum ActivityType {
  sale,
  debt,
  stockIn,
  stockOut,
  debtPayment,
  productAdded,
  productUpdated,
  productDeleted,
}

class ActivityModel {
  final String id;
  final ActivityType type;
  final String description;
  final String? relatedId;
  final double? amount;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.type,
    required this.description,
    this.relatedId,
    this.amount,
    required this.createdAt,
  });

  String get typeDisplayName {
    switch (type) {
      case ActivityType.sale:
        return 'Sale';
      case ActivityType.debt:
        return 'Debt Added';
      case ActivityType.stockIn:
        return 'Stock In';
      case ActivityType.stockOut:
        return 'Stock Out';
      case ActivityType.debtPayment:
        return 'Debt Payment';
      case ActivityType.productAdded:
        return 'Product Added';
      case ActivityType.productUpdated:
        return 'Product Updated';
      case ActivityType.productDeleted:
        return 'Product Deleted';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'relatedId': relatedId,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.sale,
      ),
      description: map['description'] ?? '',
      relatedId: map['relatedId'],
      amount: map['amount']?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}