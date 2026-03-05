class Saving {
  int? id;
  int userId;
  int? jarId;
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
      id: map['id'],
      userId: map['user_id'],
      jarId: map['jar_id'],
      name: map['name'],
      principal: map['principal'],
      interestRate: map['interest_rate'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      status: map['status'],
      note: map['note'],
      createdAt: map['created_at'],
    );
  }
}