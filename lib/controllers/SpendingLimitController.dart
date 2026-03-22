import 'package:uuid/uuid.dart';
import '../models/SpendingLimit.dart';
import '../repositories/SpendingLimitRepository.dart';
import '../services/session_services.dart';

class SpendingLimitController {
  final SpendingLimitRepository _repo = SpendingLimitRepository();
  final _uuid = const Uuid();

  // Hàm hỗ trợ lấy UserId nhanh
  Future<String?> _getUserId() async {
    return await SessionService.getUserId();
  }

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
    final userId = await _getUserId();
    if (userId == null) return;

    final limit = SpendingLimit(
      id: _uuid.v4(),
      user_id: userId, // ✅ Đã đổi từ "aaa" sang userId động
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
    final userId = await _getUserId();
    if (userId == null) return []; // Trả về list rỗng thay vì null để tránh crash UI

    final limits = await _repo.getSpendingLimitsByUserId(userId);

    print('--- Danh sách Hạn mức của User: $userId ---');
    for (var l in limits) {
      print('Hạn mức: ${l.name} | ID: ${l.id}');
    }

    return limits;
  }

  Future<void> updateSpendingLimit(SpendingLimit limit) async {
    await _repo.updateSpendingLimit(limit);
  }

  Future<void> deleteSpendingLimit(String id) async {
    await _repo.deleteSpendingLimit(id);
  }

  Future<bool> checkNameExists(String name, {String? excludeId}) async {
    final userId = await _getUserId();
    if (userId == null) return false;

    return await _repo.isNameExists(
      userId: userId, // ✅ Đã sửa "aaa" thành userId động
      name: name,
      excludeId: excludeId,
    );
  }

  // Các hàm logic tính toán chu kỳ giữ nguyên vì không phụ thuộc database trực tiếp
  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _addCycle(DateTime value, String repeatFrequency) {
    switch (repeatFrequency) {
      case 'Hàng ngày': return value.add(const Duration(days: 1));
      case 'Hàng tuần': return value.add(const Duration(days: 7));
      case 'Hàng quý': return DateTime(value.year, value.month + 3, value.day);
      case 'Hàng năm': return DateTime(value.year + 1, value.month, value.day);
      case 'Hàng tháng':
      default: return DateTime(value.year, value.month + 1, value.day);
    }
  }

  ({DateTime cycleStart, DateTime cycleEnd}) _resolveCycleRange(SpendingLimit limit, DateTime now) {
    final start = _dateOnly(DateTime.parse(limit.start_date));
    if (limit.end_date != null && limit.end_date!.trim().isNotEmpty) {
      final end = _dateOnly(DateTime.parse(limit.end_date!));
      return (cycleStart: start, cycleEnd: end);
    }

    final today = _dateOnly(now);
    var cycleStart = start;
    var cycleEnd = _dateOnly(_addCycle(cycleStart, limit.repeat_frequency).subtract(const Duration(days: 1)));

    while (today.isAfter(cycleEnd)) {
      cycleStart = _addCycle(cycleStart, limit.repeat_frequency);
      cycleEnd = _dateOnly(_addCycle(cycleStart, limit.repeat_frequency).subtract(const Duration(days: 1)));
    }
    return (cycleStart: cycleStart, cycleEnd: cycleEnd);
  }

  Future<Map<String, dynamic>?> getSpendingLimitDetailMetrics(String limitId) async {
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
    final elapsedDays = effectiveToday.isBefore(cycleStart) ? 0 : effectiveToday.difference(cycleStart).inDays + 1;
    final remainingDays = cycleEnd.difference(effectiveToday).inDays;

    final amountRemaining = limit.amount - spent;
    final actualDailySpend = elapsedDays > 0 ? spent / elapsedDays : 0.0;
    final shouldDailySpend = remainingDays > 0 ? amountRemaining / remainingDays : amountRemaining;
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