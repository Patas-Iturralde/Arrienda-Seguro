import 'dart:async';

import '../../models/app_notification.dart';
import '../notification_repository.dart';
import '../../services/mock_data_service.dart';

class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository(this._data);

  final MockDataService _data;
  final _controller = StreamController<List<AppNotification>>.broadcast();

  @override
  int get unreadCount =>
      _data.notifications.where((n) => !n.leida).length;

  @override
  Future<List<AppNotification>> getNotifications({String? userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List.from(_data.notifications)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _data.notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      final n = _data.notifications[index];
      _data.notifications[index] = AppNotification(
        id: n.id,
        titulo: n.titulo,
        descripcion: n.descripcion,
        fecha: n.fecha,
        type: n.type,
        group: n.group,
        contractId: n.contractId,
        leida: true,
      );
      _controller.add(List.from(_data.notifications));
    }
  }

  @override
  Future<void> createNotification(AppNotification notification) async {
    _data.notifications.insert(0, notification);
    _controller.add(List.from(_data.notifications));
  }

  @override
  Stream<List<AppNotification>> watchNotifications({String? userId}) {
    _controller.add(List.from(_data.notifications));
    return _controller.stream;
  }

  void dispose() => _controller.close();
}
