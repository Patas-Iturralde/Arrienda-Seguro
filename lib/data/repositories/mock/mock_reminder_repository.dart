import '../../models/reminder.dart';
import '../reminder_repository.dart';
import '../../services/mock_data_service.dart';

class MockReminderRepository implements ReminderRepository {
  MockReminderRepository(this._data);

  final MockDataService _data;

  @override
  Future<List<Reminder>> getReminders({String? userId, DateTime? month}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    var reminders = List<Reminder>.from(_data.reminders);

    if (userId != null) {
      final contractIds = _data.contracts
          .where((c) =>
              c.arrendadorId == userId || c.arrendatarioId == userId)
          .map((c) => c.id)
          .toSet();
      reminders =
          reminders.where((r) => contractIds.contains(r.contractId)).toList();
    }

    if (month != null) {
      reminders = reminders
          .where((r) =>
              r.fecha.year == month.year && r.fecha.month == month.month)
          .toList();
    }

    reminders.sort((a, b) => a.fecha.compareTo(b.fecha));
    return reminders;
  }
}
