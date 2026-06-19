import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/payment.dart';
import '../../data/models/payment_status.dart';
import '../../providers/app_providers.dart';
import '../../routing/app_routes.dart';

/// Lista de pagos del arrendatario para registrar comprobantes desde Perfil.
class TenantRegisterPaymentScreen extends StatefulWidget {
  const TenantRegisterPaymentScreen({super.key});

  @override
  State<TenantRegisterPaymentScreen> createState() =>
      _TenantRegisterPaymentScreenState();
}

class _TenantRegisterPaymentScreenState
    extends State<TenantRegisterPaymentScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final contractProvider = context.read<ContractProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    setState(() => _loading = true);
    await contractProvider.loadContracts(user);
    await paymentProvider.loadAllForUser(user);
    if (mounted) setState(() => _loading = false);
  }

  String _title(Payment payment) {
    if (payment.esDeposito) return payment.concepto.label;
    return Formatters.monthYear(payment.periodo);
  }

  Color _statusColor(PaymentStatus status) {
    return switch (status) {
      PaymentStatus.pagado => AppColors.success,
      PaymentStatus.enRevision => AppColors.warning,
      PaymentStatus.rechazado => AppColors.error,
      PaymentStatus.vencido => AppColors.error,
      PaymentStatus.pendiente => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final payments = context.watch<PaymentProvider>().payments;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar pago')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: payments.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Icon(Icons.payments_outlined,
                            size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'No tienes pagos programados',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: payments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        final canRegister = payment.status.puedeRegistrar;

                        return Card(
                          child: ListTile(
                            onTap: canRegister
                                ? () async {
                                    await Navigator.pushNamed(
                                      context,
                                      AppRoutes.registerPayment,
                                      arguments: payment.id,
                                    );
                                    if (!context.mounted) return;
                                    await _load();
                                  }
                                : null,
                            leading: CircleAvatar(
                              backgroundColor:
                                  _statusColor(payment.status).withValues(
                                alpha: 0.15,
                              ),
                              child: Icon(
                                canRegister
                                    ? Icons.upload_file
                                    : Icons.info_outline,
                                color: _statusColor(payment.status),
                              ),
                            ),
                            title: Text(_title(payment)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Formatters.currency(payment.monto),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Vence: ${Formatters.dateShort(payment.fechaVencimiento)}',
                                ),
                                Text(
                                  payment.status.label,
                                  style: TextStyle(
                                    color: _statusColor(payment.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (payment.rechazoMotivo != null)
                                  Text(
                                    'Motivo: ${payment.rechazoMotivo}',
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: canRegister
                                ? const Icon(Icons.chevron_right)
                                : null,
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
