class SavingRespone {
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

  SavingRespone({
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
}