class SpendingLimit {
	final String? id;
	final String user_id;
	final String name;
	final double amount;
	final String categories;
	final String accounts;
	final String repeat_frequency;
	final String start_date;
	final String? end_date;
	final int carry_forward;
	final int is_deleted;
	final String created_at;

	SpendingLimit({
		this.id,
		required this.user_id,
		required this.name,
		required this.amount,
		this.categories = '',
		this.accounts = '',
		this.repeat_frequency = 'Hàng tháng',
		required this.start_date,
		this.end_date,
		this.carry_forward = 0,
		this.is_deleted = 0,
		required this.created_at,
	});

	factory SpendingLimit.fromMap(Map<String, dynamic> map) {
		return SpendingLimit(
			id: map['id']?.toString(),
			user_id: map['user_id']?.toString() ?? '',
			name: map['name']?.toString() ?? '',
			amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
			categories: map['categories']?.toString() ?? '',
			accounts: map['accounts']?.toString() ?? '',
			repeat_frequency: map['repeat_frequency']?.toString() ?? 'Hàng tháng',
			start_date: map['start_date']?.toString() ?? DateTime.now().toIso8601String().split('T').first,
			end_date: map['end_date']?.toString(),
			carry_forward: map['carry_forward'] is int ? map['carry_forward'] as int : int.tryParse(map['carry_forward']?.toString() ?? '0') ?? 0,
			is_deleted: map['is_deleted'] is int ? map['is_deleted'] as int : int.tryParse(map['is_deleted']?.toString() ?? '0') ?? 0,
			created_at: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
		);
	}

	Map<String, dynamic> toMap() {
		return {
			if (id != null) 'id': id,
			'user_id': user_id,
			'name': name,
			'amount': amount,
			'categories': categories,
			'accounts': accounts,
			'repeat_frequency': repeat_frequency,
			'start_date': start_date,
			'end_date': end_date,
			'carry_forward': carry_forward,
			'is_deleted': is_deleted,
			'created_at': created_at,
		};
	}

	SpendingLimit copyWith({
		String? id,
		String? user_id,
		String? name,
		double? amount,
		String? categories,
		String? accounts,
		String? repeat_frequency,
		String? start_date,
		String? end_date,
		int? carry_forward,
		int? is_deleted,
		String? created_at,
	}) {
		return SpendingLimit(
			id: id ?? this.id,
			user_id: user_id ?? this.user_id,
			name: name ?? this.name,
			amount: amount ?? this.amount,
			categories: categories ?? this.categories,
			accounts: accounts ?? this.accounts,
			repeat_frequency: repeat_frequency ?? this.repeat_frequency,
			start_date: start_date ?? this.start_date,
			end_date: end_date ?? this.end_date,
			carry_forward: carry_forward ?? this.carry_forward,
			is_deleted: is_deleted ?? this.is_deleted,
			created_at: created_at ?? this.created_at,
		);
	}
}

