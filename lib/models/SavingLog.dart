class SavingLog {
  String? id;            // int? -> String?
  String savingId;       // int -> String (UUID của khoản tiết kiệm)
  String? transactionId; // int? -> String? (UUID của giao dịch liên quan)
  double changeAmount;
  String type;
  String? note;
  String? createdAt;

  SavingLog({
    this.id,
    required this.savingId,
    this.transactionId,
    required this.changeAmount,
    required this.type,
    this.note,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saving_id': savingId,
      'transaction_id': transactionId,
      'change_amount': changeAmount,
      'type': type,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory SavingLog.fromMap(Map<String, dynamic> map) {
    return SavingLog(
      id: map['id']?.toString(), // Đảm bảo trả về String UUID
      savingId: map['saving_id'].toString(),
      transactionId: map['transaction_id']?.toString(),
      changeAmount: (map['change_amount'] as num).toDouble(), // Ép kiểu double an toàn
      type: map['type'] ?? '',
      note: map['note'],
      createdAt: map['created_at'],
    );
  }
}