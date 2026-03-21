class SavingLog {
  final String? id;
  final String savingId;
  final String? transactionId;
  final double changeAmount;
  final String type;
  final String? note;
  final String? createdAt;
  final int is_synced; // THÊM: 0 = chưa sync, 1 = đã sync

  SavingLog({
    this.id,
    required this.savingId,
    this.transactionId,
    required this.changeAmount,
    required this.type,
    this.note,
    this.createdAt,
    this.is_synced = 0, // Mặc định là 0 khi tạo mới tại máy
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
      'is_synced': is_synced,
    };
  }

  factory SavingLog.fromMap(Map<String, dynamic> map) {
    return SavingLog(
      id: map['id']?.toString(),
      savingId: map['saving_id'].toString(),
      transactionId: map['transaction_id']?.toString(),
      changeAmount: (map['change_amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      note: map['note'],
      createdAt: map['created_at'],
      is_synced: map['is_synced'] ?? 0,
    );
  }

  // Hàm copyWith để cập nhật trạng thái sau khi Sync
  SavingLog copyWith({
    String? id,
    String? savingId,
    String? transactionId,
    double? changeAmount,
    String? type,
    String? note,
    String? createdAt,
    int? isSynced,
  }) {
    return SavingLog(
      id: id ?? this.id,
      savingId: savingId ?? this.savingId,
      transactionId: transactionId ?? this.transactionId,
      changeAmount: changeAmount ?? this.changeAmount,
      type: type ?? this.type,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      is_synced: isSynced ?? this.is_synced,
    );
  }
}