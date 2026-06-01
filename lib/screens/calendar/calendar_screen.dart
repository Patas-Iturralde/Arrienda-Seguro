import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/reminder.dart';
import '../../providers/app_providers.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final user = context.read<AuthProvider>().currentUser;
    final reminders = await ServiceLocator.instance.reminderRepository
        .getReminders(userId: user?.id);
    if (mounted) setState(() => _reminders = reminders);
  }

  List<Reminder> _remindersForDay(DateTime day) {
    return _reminders
        .where((r) =>
            r.fecha.year == day.year &&
            r.fecha.month == day.month &&
            r.fecha.day == day.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedReminders =
        _selectedDay != null ? _remindersForDay(_selectedDay!) : <Reminder>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario y recordatorios')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              locale: 'es',
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: _remindersForDay,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onPageChanged: (focused) => _focusedDay = focused,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recordatorios',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (selectedReminders.isNotEmpty)
            ...selectedReminders.map(_ReminderTile.new)
          else
            ..._reminders.map(_ReminderTile.new),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile(this.reminder);

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final isPayment = reminder.type == ReminderType.pagoArriendo;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isPayment ? AppColors.successLight : AppColors.warningLight,
          child: Icon(
            isPayment ? Icons.notifications_active : Icons.event_busy,
            color: isPayment ? AppColors.success : AppColors.warning,
          ),
        ),
        title: Text(reminder.titulo),
        subtitle: Text(Formatters.date(reminder.fecha)),
        trailing: Icon(
          Icons.notifications,
          color: isPayment ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}
