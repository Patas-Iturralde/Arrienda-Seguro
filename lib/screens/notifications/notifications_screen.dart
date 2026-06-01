import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notifications = await ServiceLocator.instance.notificationRepository
        .getNotifications();
    if (mounted) setState(() => _notifications = notifications);
  }

  IconData _iconFor(NotificationType type) {
    return switch (type) {
      NotificationType.pagoRegistrado => Icons.check_circle,
      NotificationType.pagoProximo => Icons.schedule,
      NotificationType.contratoPorVencer => Icons.warning_amber,
      NotificationType.contratoRenovado => Icons.autorenew,
      NotificationType.recordatorio => Icons.notifications,
    };
  }

  Color _colorFor(NotificationType type) {
    return switch (type) {
      NotificationType.pagoRegistrado => AppColors.success,
      NotificationType.pagoProximo => AppColors.primary,
      NotificationType.contratoPorVencer => AppColors.warning,
      NotificationType.contratoRenovado => AppColors.success,
      NotificationType.recordatorio => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final groups = {
      'Hoy': _notifications
          .where((n) => n.group == NotificationGroup.hoy)
          .toList(),
      'Próximos': _notifications
          .where((n) => n.group == NotificationGroup.proximos)
          .toList(),
      'Anteriores': _notifications
          .where((n) => n.group == NotificationGroup.anteriores)
          .toList(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: groups.entries.expand((entry) {
          if (entry.value.isEmpty) return <Widget>[];
          return [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...entry.value.map((n) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _colorFor(n.type).withValues(alpha: 0.15),
                      child: Icon(_iconFor(n.type), color: _colorFor(n.type)),
                    ),
                    title: Text(
                      n.titulo,
                      style: TextStyle(
                        fontWeight:
                            n.leida ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(n.descripcion),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.timeAgo(n.fecha),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                )),
          ];
        }).toList(),
      ),
    );
  }
}
