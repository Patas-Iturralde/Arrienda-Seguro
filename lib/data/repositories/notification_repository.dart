import '../models/app_notification.dart';

/// Contrato abstracto para notificaciones.
/// Implementar con FirebaseNotificationRepository cuando se conecte Firebase.
abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications({String? userId});
  Future<void> markAsRead(String notificationId);
  Future<void> createNotification(AppNotification notification);
  Stream<List<AppNotification>> watchNotifications({String? userId});
  int get unreadCount;
}
