import '../models/SpendingLimit.dart';
import '../repositories/SpendingLimitRepository.dart';

class SpendingLimitController {
  final SpendingLimitRepository _repo = SpendingLimitRepository();

  Future<void> addSpendingLimit({
    required String name,
    required double amount,
    required String categories,
    required String accounts,
    required String repeatFrequency,
    required String startDate,
    String? endDate,
    required bool carryForward,
  }) async {
    final limit = SpendingLimit(
      user_id: 1, // TODO: Get from logged user
      name: name,
      amount: amount,
      categories: categories,
      accounts: accounts,
      repeat_frequency: repeatFrequency,
      start_date: startDate,
      end_date: endDate,
      carry_forward: carryForward ? 1 : 0,
      created_at: DateTime.now(),
    );

    await _repo.insertSpendingLimit(limit);
  }

  Future<List<SpendingLimit>> getSpendingLimits() async {
    return await _repo.getSpendingLimitsByUserId(
      1,
    ); // TODO: Get from logged user
  }

  Future<void> updateSpendingLimit(SpendingLimit limit) async {
    await _repo.updateSpendingLimit(limit);
  }

  Future<void> deleteSpendingLimit(int id) async {
    await _repo.deleteSpendingLimit(id);
  }

  Future<bool> checkNameExists(String name, {int? excludeId}) async {
    return await _repo.isNameExists(
      userId: 1, // TODO: Get from logged user
      name: name,
      excludeId: excludeId,
    );
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _addCycle(DateTime value, String repeatFrequency) {
    switch (repeatFrequency) {
      case 'Hàng ngày':
        return value.add(const Duration(days: 1));
      case 'Hàng tuần':
        return value.add(const Duration(days: 7));
      case 'Hàng quý':
        return DateTime(value.year, value.month + 3, value.day);
      case 'Hàng năm':
        return DateTime(value.year + 1, value.month, value.day);
      case 'Không lặp lại':
      case 'Hàng tháng':
      default:
        return DateTime(value.year, value.month + 1, value.day);
    }
  }

  ({DateTime cycleStart, DateTime cycleEnd}) _resolveCycleRange(
    SpendingLimit limit,
    DateTime now,
  ) {
    final start = _dateOnly(DateTime.parse(limit.start_date));

    if (limit.end_date != null && limit.end_date!.trim().isNotEmpty) {
      final end = _dateOnly(DateTime.parse(limit.end_date!));
      return (cycleStart: start, cycleEnd: end);
    }

    final today = _dateOnly(now);
    if (today.isBefore(start)) {
      final end = _dateOnly(
        _addCycle(
          start,
          limit.repeat_frequency,
        ).subtract(const Duration(days: 1)),
      );
      return (cycleStart: start, cycleEnd: end);
    }

    var cycleStart = start;
    var cycleEnd = _dateOnly(
      _addCycle(
        cycleStart,
        limit.repeat_frequency,
      ).subtract(const Duration(days: 1)),
    );

    while (today.isAfter(cycleEnd)) {
      cycleStart = _addCycle(cycleStart, limit.repeat_frequency);
      cycleEnd = _dateOnly(
        _addCycle(
          cycleStart,
          limit.repeat_frequency,
        ).subtract(const Duration(days: 1)),
      );
    }

    return (cycleStart: cycleStart, cycleEnd: cycleEnd);
  }

  Future<Map<String, dynamic>?> getSpendingLimitDetailMetrics(
    int limitId,
  ) async {
    final limit = await _repo.getSpendingLimitById(limitId);
    if (limit == null) return null;

    final now = _dateOnly(DateTime.now());
    final cycle = _resolveCycleRange(limit, now);
    final cycleStart = cycle.cycleStart;
    final cycleEnd = cycle.cycleEnd;

    final effectiveToday = now.isAfter(cycleEnd) ? cycleEnd : now;
    final spent = await _repo.getSpentAmountForLimit(
      userId: limit.user_id,
      limit: limit,
      fromDate: cycleStart,
      toDate: effectiveToday,
    );

    final totalDays = cycleEnd.difference(cycleStart).inDays + 1;
    final elapsedDays = effectiveToday.isBefore(cycleStart)
        ? 0
        : effectiveToday.difference(cycleStart).inDays + 1;
    final remainingDays = cycleEnd.difference(effectiveToday).inDays;

    final amountRemaining = limit.amount - spent;

    final actualDailySpend = elapsedDays > 0 ? spent / elapsedDays : 0.0;
    final shouldDailySpend = remainingDays > 0
        ? amountRemaining / remainingDays
        : amountRemaining;
    final projectedSpending = (actualDailySpend * remainingDays) + spent;

    return {
      'limit': limit,
      'cycleStart': cycleStart,
      'cycleEnd': cycleEnd,
      'spent': spent,
      'amountRemaining': amountRemaining,
      'totalDays': totalDays,
      'elapsedDays': elapsedDays,
      'remainingDays': remainingDays,
      'actualDailySpend': actualDailySpend,
      'shouldDailySpend': shouldDailySpend,
      'projectedSpending': projectedSpending,
    };
  }
}
