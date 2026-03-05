class SavingLog {
  int? id;
  int savingId;
  int? transactionId;
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
      id: map['id'],
      savingId: map['saving_id'],
      transactionId: map['transaction_id'],
      changeAmount: map['change_amount'],
      type: map['type'],
      note: map['note'],
      createdAt: map['created_at'],
    );
  }
}