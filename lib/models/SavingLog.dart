class SavingLog {
  final String? id;
  final String userId;       // 🔥 THÊM: Để quản lý theo người dùng
  final String savingId;
  final String? transactionId;
  final double changeAmount;
  final String type;
  final String? note;
  final String? createdAt;
  final int is_synced;

  SavingLog({
    this.id,
    required this.userId,    // 🔥 Bắt buộc khi tạo Log
    required this.savingId,
    this.transactionId,
    required this.changeAmount,
    required this.type,
    this.note,
    this.createdAt,
    this.is_synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,     // 🔥 Lưu vào DB
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
      userId: map['user_id']?.toString() ?? "", // 🔥 Đọc từ DB
      savingId: map['saving_id'].toString(),
      transactionId: map['transaction_id']?.toString(),
      changeAmount: (map['change_amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      note: map['note'],
      createdAt: map['created_at'],
      is_synced: map['is_synced'] ?? 0,
    );
  }

  SavingLog copyWith({
    String? id,
    String? userId,         // 🔥 Thêm vào copyWith
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
      userId: userId ?? this.userId,
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