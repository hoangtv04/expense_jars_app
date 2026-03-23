class Saving {
  final String? id;
  final String userId;
  final String? jarId;
  final String name;
  final double principal;
  final double? interestRate;
  final String startDate;
  final String? endDate;
  final String status;
  final String? note;
  final String? createdAt;
  final int is_synced; // Giữ lại cái này để sau này biết cái nào đã đẩy lên Supabase

  Saving({
    this.id,
    required this.userId,
    this.jarId,
    required this.name,
    required this.principal,
    this.interestRate,
    required this.startDate,
    this.endDate,
    this.status = 'active',
    this.note,
    this.createdAt,
    this.is_synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'jar_id': jarId,
      'name': name,
      'principal': principal,
      'interest_rate': interestRate,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'note': note,
      'created_at': createdAt,
      'is_synced': is_synced,
      // 🔥 ĐÃ XÓA DÒNG 'is_deleted' Ở ĐÂY
    };
  }

  factory Saving.fromMap(Map<String, dynamic> map) {
    return Saving(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? '',
      jarId: map['jar_id']?.toString(),
      name: map['name'] ?? '',
      principal: (map['principal'] as num?)?.toDouble() ?? 0.0,
      interestRate: (map['interest_rate'] as num?)?.toDouble(),
      startDate: map['start_date'] ?? '',
      endDate: map['end_date'],
      status: map['status'] ?? 'active',
      note: map['note'],
      createdAt: map['created_at'],
      is_synced: map['is_synced'] ?? 0,
      // 🔥 ĐÃ XÓA DÒNG 'is_deleted' Ở ĐÂY
    );
  }

  Saving copyWith({
    String? id,
    String? userId,
    String? jarId,
    String? name,
    double? principal,
    double? interestRate,
    String? startDate,
    String? endDate,
    String? status,
    String? note,
    String? createdAt,
    int? isSynced,
  }) {
    return Saving(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jarId: jarId ?? this.jarId,
      name: name ?? this.name,
      principal: principal ?? this.principal,
      interestRate: interestRate ?? this.interestRate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      is_synced: isSynced ?? this.is_synced,
    );
  }
}