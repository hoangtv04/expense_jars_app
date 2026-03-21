import 'Category.dart';

class Transaction {
  final String? id;
  final String userId;
  final String jarId;
  final String categoryId;
  final double amount;
  final String? note;
  final String? date;
  final String? status;
  final int isDeleted;
  final int isSynced; // THÊM: 0 = chưa sync, 1 = đã sync
  final String? createdAt;
  final CategoryType? type;
  final bool isRecurring;
  final String? recurringType; // daily, weekly, monthly
  final String? nextRunDate;

  Transaction({
    this.id,
    required this.userId,
    required this.jarId,
    required this.categoryId,
    required this.amount,
    this.note,
    this.date,
    this.status = 'completed',
    this.isDeleted = 0,
    this.isSynced = 0, // Mặc định là 0 khi tạo mới tại local
    this.createdAt,
    this.type,
    this.isRecurring = false,
    this.recurringType,
    this.nextRunDate,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toString(),
      userId: map['user_id'].toString(),
      jarId: map['jar_id'].toString(),
      categoryId: map['category_id'].toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      note: map['note'],
      date: map['date'],
      status: map['status'] ?? 'completed',
      isDeleted: map['is_deleted'] ?? 0,
      isSynced: map['is_synced'] ?? 0, // THÊM: Lấy dữ liệu từ DB
      createdAt: map['created_at'],
      type: CategoryType.values.firstWhere(
            (e) => e.name.toLowerCase() == (map['type']?.toString().toLowerCase().trim() ?? ""),
        orElse: () => CategoryType.expense,
      ),
      isRecurring: map['is_recurring'] == 1,
      recurringType: map['recurring_type'],
      nextRunDate: map['next_run_date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'jar_id': jarId,
      'category_id': categoryId,
      'amount': amount,
      'note': note,
      'date': date,
      'status': status,
      'is_deleted': isDeleted,
      'is_synced': isSynced, // THÊM: Để lưu vào SQLite
      'created_at': createdAt,
      'is_recurring': isRecurring ? 1 : 0,
      'recurring_type': recurringType,
      'next_run_date': nextRunDate,
    };
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? jarId,
    String? categoryId,
    double? amount,
    String? note,
    String? date,
    String? status,
    int? isDeleted,
    int? isSynced, // Thêm vào copyWith
    String? createdAt,
    CategoryType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jarId: jarId ?? this.jarId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced, // Cập nhật trạng thái sync
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }
}