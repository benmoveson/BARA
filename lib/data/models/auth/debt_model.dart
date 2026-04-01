class DebtModel {
  final String id;
  final String debtorName;
  final String? debtorPhone;
  final double totalAmount;
  final double paidAmount;
  final List<DebtPayment> payments;
  final DateTime createdAt;
  final DateTime updatedAt;

  DebtModel({
    required this.id,
    required this.debtorName,
    this.debtorPhone,
    required this.totalAmount,
    this.paidAmount = 0,
    List<DebtPayment>? payments,
    required this.createdAt,
    required this.updatedAt,
  }) : payments = payments ?? [];

  double get remainingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debtorName': debtorName,
      'debtorPhone': debtorPhone,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'payments': payments.map((p) => p.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] ?? '',
      debtorName: map['debtorName'] ?? '',
      debtorPhone: map['debtorPhone'],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      payments: map['payments'] != null
          ? (map['payments'] as List).map((p) => DebtPayment.fromMap(p)).toList()
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  DebtModel copyWith({
    String? id,
    String? debtorName,
    String? debtorPhone,
    double? totalAmount,
    double? paidAmount,
    List<DebtPayment>? payments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DebtModel(
      id: id ?? this.id,
      debtorName: debtorName ?? this.debtorName,
      debtorPhone: debtorPhone ?? this.debtorPhone,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DebtPayment {
  final String id;
  final double amount;
  final String? note;
  final DateTime createdAt;

  DebtPayment({
    required this.id,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DebtPayment.fromMap(Map<String, dynamic> map) {
    return DebtPayment(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      note: map['note'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}