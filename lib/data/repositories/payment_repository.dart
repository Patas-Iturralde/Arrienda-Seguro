import '../models/payment.dart';

/// Contrato abstracto para pagos.
/// Implementar con FirebasePaymentRepository cuando se conecte Firebase.
abstract class PaymentRepository {
  Future<List<Payment>> getPaymentsByContract(String contractId);
  Future<List<Payment>> getPendingPayments({String? userId, String? role});
  Future<Payment?> getNextPayment({String? userId, String? role});
  Future<Payment> registerPayment(String paymentId, {DateTime? fechaPago});
  Future<Payment> createPayment(Payment payment);
  Stream<List<Payment>> watchPaymentsByContract(String contractId);
}
