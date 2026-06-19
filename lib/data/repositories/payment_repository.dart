import '../models/contract.dart';
import '../models/payment.dart';

/// Contrato abstracto para pagos.
abstract class PaymentRepository {
  Future<List<Payment>> getPaymentsByContract(String contractId);
  Future<Payment?> getPaymentById(String paymentId);
  Future<List<Payment>> getPendingPayments({String? userId, String? role});
  Future<List<Payment>> getPaymentsPendingApproval(String landlordId);
  Future<List<Payment>> getAllPaymentsForUser({
    required String userId,
    required String role,
  });
  Future<Payment?> getNextPayment({String? userId, String? role});
  Future<Payment> submitPayment(
    String paymentId, {
    required String comprobanteBase64,
  });
  Future<Payment> approvePayment(String paymentId);
  Future<Payment> rejectPayment(String paymentId, {String? motivo});
  Future<Payment> createPayment(Payment payment);
  Future<List<Payment>> generateScheduleForContract(Contract contract);
  Stream<List<Payment>> watchPaymentsByContract(String contractId);
}
