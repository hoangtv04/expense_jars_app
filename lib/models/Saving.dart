class Saving {
  String? id;            // int? -> String?
  String userId;         // int -> String (UUID từ Supabase Auth)
  String? jarId;         // int? -> String? (UUID của hũ liên kết)
  String name;
  double principal;
  double? interestRate;
  String startDate;
  String? endDate;
  String status;
  String? note;
  String? createdAt;

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
    };
  }

  factory Saving.fromMap(Map<String, dynamic> map) {
    return Saving(
      id: map['id']?.toString(), // Đảm bảo trả về String UUID
      userId: map['user_id'].toString(),
      jarId: map['jar_id']?.toString(),
      name: map['name'] ?? '',
      principal: (map['principal'] as num).toDouble(),
      interestRate: (map['interest_rate'] as num?)?.toDouble(),
      startDate: map['start_date'] ?? '',
      endDate: map['end_date'],
      status: map['status'] ?? 'active',
      note: map['note'],
      createdAt: map['created_at'],
    );
  }
}