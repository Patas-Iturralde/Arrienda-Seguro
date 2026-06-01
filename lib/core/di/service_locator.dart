import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/contract_repository.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/repositories/mock/mock_auth_repository.dart';
import '../../data/repositories/mock/mock_contract_repository.dart';
import '../../data/repositories/mock/mock_document_repository.dart';
import '../../data/repositories/mock/mock_notification_repository.dart';
import '../../data/repositories/mock/mock_payment_repository.dart';
import '../../data/repositories/mock/mock_reminder_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../data/services/mock_data_service.dart';

/// Contenedor de dependencias.
/// Para Firebase: reemplazar implementaciones mock por Firebase*Repository.
class ServiceLocator {
  ServiceLocator._();
  static final instance = ServiceLocator._();

  final mockData = MockDataService.instance;

  late final AuthRepository authRepository =
      MockAuthRepository(mockData);
  late final ContractRepository contractRepository =
      MockContractRepository(mockData);
  late final PaymentRepository paymentRepository =
      MockPaymentRepository(mockData);
  late final NotificationRepository notificationRepository =
      MockNotificationRepository(mockData);
  late final DocumentRepository documentRepository =
      MockDocumentRepository(mockData);
  late final ReminderRepository reminderRepository =
      MockReminderRepository(mockData);
}
