import '../models/reminder.dart';

/// Contrato abstracto para recordatorios.
abstract class ReminderRepository {
  Future<List<Reminder>> getReminders({String? userId, DateTime? month});
}
