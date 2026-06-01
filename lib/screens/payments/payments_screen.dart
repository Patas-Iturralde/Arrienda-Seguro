import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/contract.dart';
import '../../data/models/payment.dart';
import '../../data/models/payment_status.dart';
import '../../providers/app_providers.dart';
import '../../routing/app_routes.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<ContractProvider>().loadContracts(auth.currentUser);
      context.read<PaymentProvider>().loadDashboardData(auth.currentUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    final payments = context.watch<PaymentProvider>();
    final contracts = context.watch<ContractProvider>().contracts;

    return Scaffold(
      appBar: AppBar(title: const Text('Pagos')),
      body: payments.nextPayment == null && payments.pendingCount == 0
          ? const Center(
              child: Text(
                'No hay pagos pendientes',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (payments.nextPayment != null)
                  Card(
                    color: AppColors.mintCard,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Próximo pago pendiente',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Formatters.currency(payments.nextPayment!.monto),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Vence: ${Formatters.date(payments.nextPayment!.fechaVencimiento)}',
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.registerPayment,
                              arguments: payments.nextPayment!.id,
                            ),
                            child: const Text('Registrar pago'),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Contratos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...contracts
                    .where((c) => c.status.name != 'finalizado')
                    .map((c) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(c.propertyName),
                            subtitle: Text(
                              'Canon: ${Formatters.currency(c.canonMensual)}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.paymentRecord,
                              arguments: c.id,
                            ),
                          ),
                        )),
              ],
            ),
    );
  }
}

class PaymentRecordScreen extends StatefulWidget {
  const PaymentRecordScreen({super.key, required this.contractId});

  final String contractId;

  @override
  State<PaymentRecordScreen> createState() => _PaymentRecordScreenState();
}

class _PaymentRecordScreenState extends State<PaymentRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadByContract(widget.contractId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Contract? contract;
    for (final c in context.watch<ContractProvider>().contracts) {
      if (c.id == widget.contractId) {
        contract = c;
        break;
      }
    }
    final payments = context.watch<PaymentProvider>().payments;

    final history =
        payments.where((p) => p.status == PaymentStatus.pagado).toList();
    final pending = payments
        .where((p) =>
            p.status == PaymentStatus.pendiente ||
            p.status == PaymentStatus.vencido)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(contract?.propertyName ?? 'Registro de pagos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Historial'),
            Tab(text: 'Pendientes'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (contract != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.mintLight,
              child: Text(
                'Canon mensual: ${Formatters.currency(contract.canonMensual)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PaymentList(payments: history, isHistory: true),
                _PaymentList(payments: pending, isHistory: false),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: pending.isEmpty
                ? null
                : () => Navigator.pushNamed(
                      context,
                      AppRoutes.registerPayment,
                      arguments: pending.first.id,
                    ),
            child: const Text('Registrar nuevo pago'),
          ),
        ),
      ),
    );
  }
}

class _PaymentList extends StatelessWidget {
  const _PaymentList({required this.payments, required this.isHistory});

  final List<Payment> payments;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(
        child: Text(
          isHistory ? 'Sin historial de pagos' : 'No hay pagos pendientes',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isHistory
                  ? AppColors.successLight
                  : AppColors.warningLight,
              child: Icon(
                isHistory ? Icons.check : Icons.schedule,
                color: isHistory ? AppColors.success : AppColors.warning,
              ),
            ),
            title: Text(Formatters.monthYear(payment.periodo)),
            subtitle: Text(
              isHistory && payment.fechaPago != null
                  ? 'Pagado: ${Formatters.dateShort(payment.fechaPago!)}'
                  : 'Vence: ${Formatters.dateShort(payment.fechaVencimiento)}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currency(payment.monto),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  payment.status.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isHistory ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RegisterPaymentScreen extends StatefulWidget {
  const RegisterPaymentScreen({super.key, required this.paymentId});

  final String paymentId;

  @override
  State<RegisterPaymentScreen> createState() => _RegisterPaymentScreenState();
}

class _RegisterPaymentScreenState extends State<RegisterPaymentScreen> {
  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);
    await context.read<PaymentProvider>().registerPayment(widget.paymentId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pago registrado. Recibo generado automáticamente.'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar pago')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.payment, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Confirmar registro de pago',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Al registrar el pago se generará automáticamente un recibo PDF y se notificará al arrendador y arrendatario.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Confirmar pago'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
