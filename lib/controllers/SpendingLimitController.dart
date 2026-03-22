import 'package:uuid/uuid.dart';
import 'package:flutter_application_jars/services/session_services.dart';
import 'package:flutter_application_jars/repositories/SpendingLimitRepository.dart';

import '../models/SpendingLimit.dart';

class SpendingLimitController {
	final SpendingLimitRepository _repo = SpendingLimitRepository();

	Future<List<SpendingLimit>> getSpendingLimits() async {
		final userId = await SessionService.getUserId();
		if (userId == null) throw Exception('User chưa login');
		return await _repo.getSpendingLimitsByUserId(userId);
	}

	Future<void> addSpendingLimit({
		required String name,
		required double amount,
		String categories = '',
		String accounts = '',
		String repeatFrequency = 'Hàng tháng',
		required String startDate,
		String? endDate,
		bool carryForward = false,
	}) async {
		final userId = await SessionService.getUserId();
		if (userId == null) throw Exception('User chưa login');

		final id = const Uuid().v4();
		final now = DateTime.now().toIso8601String();

		final limit = SpendingLimit(
			id: id,
			user_id: userId,
			name: name,
			amount: amount,
			categories: categories,
			accounts: accounts,
			repeat_frequency: repeatFrequency,
			start_date: startDate,
			end_date: endDate,
			carry_forward: carryForward ? 1 : 0,
			is_deleted: 0,
			created_at: now,
		);

		await _repo.insertSpendingLimit(limit);
	}

	Future<void> updateSpendingLimit(SpendingLimit limit) async {
		await _repo.updateSpendingLimit(limit);
	}

	Future<void> deleteSpendingLimit(String id) async {
		await _repo.deleteSpendingLimit(id);
	}

	Future<bool> checkNameExists(String name, {String? excludeId}) async {
		final userId = await SessionService.getUserId();
		if (userId == null) throw Exception('User chưa login');
		return await _repo.isNameExists(userId: userId, name: name, excludeId: excludeId);
	}

	/// Returns a map with keys used by UI: 'limit', 'cycleStart', 'cycleEnd', 'spent',
	/// 'amountRemaining', 'remainingDays', 'actualDailySpend', 'shouldDailySpend', 'projectedSpending'
	Future<Map<String, dynamic>?> getSpendingLimitDetailMetrics(String limitId) async {
		final limit = await _repo.getSpendingLimitById(limitId);
		if (limit == null) return null;

		final cycleStart = DateTime.parse(limit.start_date);
		final cycleEnd = limit.end_date != null
				? DateTime.parse(limit.end_date!)
				: cycleStart.add(const Duration(days: 30));

		final spent = await _repo.getSpentAmountForLimit(
			userId: limit.user_id,
			limit: limit,
			fromDate: cycleStart,
			toDate: cycleEnd,
		);

		final amountRemaining = limit.amount - spent;

		final totalDays = cycleEnd.difference(cycleStart).inDays;
		final daysElapsed = DateTime.now().difference(cycleStart).inDays.clamp(0, totalDays == 0 ? 1 : totalDays);
		final remainingDays = cycleEnd.difference(DateTime.now()).inDays;

		final actualDailySpend = daysElapsed <= 0 ? spent : spent / (daysElapsed == 0 ? 1 : daysElapsed);
		final shouldDailySpend = totalDays <= 0 ? limit.amount : limit.amount / (totalDays == 0 ? 1 : totalDays);
		final projectedSpending = actualDailySpend * (totalDays == 0 ? 1 : totalDays);

		return {
			'limit': limit,
			'cycleStart': cycleStart,
			'cycleEnd': cycleEnd,
			'spent': spent,
			'amountRemaining': amountRemaining,
			'remainingDays': remainingDays < 0 ? 0 : remainingDays,
			'actualDailySpend': actualDailySpend,
			'shouldDailySpend': shouldDailySpend,
			'projectedSpending': projectedSpending,
		};
	}
}

