import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/contract.dart';
import '../../data/models/payment.dart';
import '../../data/models/payment_status.dart';
import '../../data/models/user_role.dart';
import '../../providers/app_providers.dart';
import '../../routing/app_routes.dart';
import '../../widgets/comprobante_picker.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    final user = context.read<AuthProvider>().currentUser;
    final contractProvider = context.read<ContractProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    await contractProvider.loadContracts(user);
    await paymentProvider.loadDashboardData(user);
  }

  String _paymentTitle(Payment payment) {
    if (payment.esDeposito) return payment.concepto.label;
    return Formatters.monthYear(payment.periodo);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final payments = context.watch<PaymentProvider>();
    final contracts = context.watch<ContractProvider>().contracts;
    final activeContracts =
        contracts.where((c) => c.status.name != 'finalizado').toList();
    final isLandlord = user?.role == UserRole.arrendador;

    return Scaffold(
      appBar: AppBar(title: const Text('Pagos')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: activeContracts.isEmpty && payments.pendingCount == 0
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.payments_outlined,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No tienes contratos con pagos',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (isLandlord && payments.approvals.isNotEmpty) ...[
                    const Text(
                      'Pagos por revisar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...payments.approvals.map(
                      (p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: AppColors.warningLight,
                        child: ListTile(
                          title: Text(_paymentTitle(p)),
                          subtitle: Text(
                            '${Formatters.currency(p.monto)} · ${p.status.label}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.landlordPaymentReview,
                              arguments: p.id,
                            );
                            if (!context.mounted) return;
                            await _reload();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!isLandlord && payments.nextPayment != null)
                    Card(
                      color: AppColors.mintCard,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Próximo pago por registrar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _paymentTitle(payments.nextPayment!),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
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
                            const Text(
                              'Toca un pago pendiente en Pagos para registrarlo',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (activeContracts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        isLandlord
                            ? 'No hay comprobantes pendientes de revisión.'
                            : 'Revisa el estado de tus pagos en cada contrato.',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Contratos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...activeContracts.map(
                    (c) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(c.propertyName),
                        subtitle: Text(
                          'Canon: ${Formatters.currency(c.canonMensual)}'
                          '${c.deposito > 0 ? ' · Depósito: ${Formatters.currency(c.deposito)}' : ''}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.paymentRecord,
                          arguments: c.id,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
      final user = context.read<AuthProvider>().currentUser;
      context.read<PaymentProvider>().loadByContract(
            widget.contractId,
            user: user,
          );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isLandlord = user?.role == UserRole.arrendador;

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
        .where(
          (p) =>
              p.status != PaymentStatus.pagado,
        )
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
                _PaymentList(
                  payments: pending,
                  isHistory: false,
                  isLandlord: isLandlord,
                  onReview: isLandlord
                      ? (payment) async {
                          if (payment.status != PaymentStatus.enRevision) {
                            return;
                          }
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.landlordPaymentReview,
                            arguments: payment.id,
                          );
                          if (!context.mounted) return;
                          context.read<PaymentProvider>().loadByContract(
                                widget.contractId,
                                user: context.read<AuthProvider>().currentUser,
                              );
                        }
                      : null,
                  onRegister: !isLandlord
                      ? (payment) async {
                          if (!payment.status.puedeRegistrar) return;
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.registerPayment,
                            arguments: payment.id,
                          );
                          if (!context.mounted) return;
                          context.read<PaymentProvider>().loadByContract(
                                widget.contractId,
                                user: context.read<AuthProvider>().currentUser,
                              );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentList extends StatelessWidget {
  const _PaymentList({
    required this.payments,
    required this.isHistory,
    this.isLandlord = false,
    this.onReview,
    this.onRegister,
  });

  final List<Payment> payments;
  final bool isHistory;
  final bool isLandlord;
  final void Function(Payment payment)? onReview;
  final void Function(Payment payment)? onRegister;

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
      PaymentStatus.pendiente => AppColors.warning,
    };
  }

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
        final canReview =
            isLandlord && payment.status == PaymentStatus.enRevision;
        final canRegister =
            !isLandlord && payment.status.puedeRegistrar && onRegister != null;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: canReview && onReview != null
                ? () => onReview!(payment)
                : canRegister
                    ? () => onRegister!(payment)
                    : null,
            leading: CircleAvatar(
              backgroundColor: _statusColor(payment.status).withValues(
                alpha: 0.15,
              ),
              child: Icon(
                isHistory
                    ? Icons.check
                    : canRegister
                        ? Icons.upload_file
                        : Icons.schedule,
                color: _statusColor(payment.status),
              ),
            ),
            title: Text(_title(payment)),
            subtitle: Text(
              isHistory && payment.fechaPago != null
                  ? 'Aprobado: ${Formatters.dateShort(payment.fechaPago!)}'
                  : payment.rechazoMotivo != null
                      ? '${payment.status.label} · ${payment.rechazoMotivo}'
                      : 'Vence: ${Formatters.dateShort(payment.fechaVencimiento)} · ${payment.status.label}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currency(payment.monto),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (canReview)
                  const Text(
                    'Revisar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else if (canRegister)
                  const Text(
                    'Registrar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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
  bool _loadingPayment = true;
  Payment? _payment;
  String? _comprobanteBase64;

  @override
  void initState() {
    super.initState();
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    final payment =
        await context.read<PaymentProvider>().getPaymentById(widget.paymentId);
    if (mounted) {
      setState(() {
        _payment = payment;
        _loadingPayment = false;
      });
    }
  }

  Future<void> _register() async {
    if (_comprobanteBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes adjuntar el comprobante de pago'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final paymentProvider = context.read<PaymentProvider>();
    final auth = context.read<AuthProvider>().currentUser;
    await paymentProvider.submitPayment(
      widget.paymentId,
      comprobanteBase64: _comprobanteBase64!,
    );
    await paymentProvider.loadDashboardData(auth);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Comprobante enviado. El arrendador debe aprobar el pago.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPayment) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final payment = _payment;
    if (payment == null || !payment.status.puedeRegistrar) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registrar pago')),
        body: Center(
          child: Text(
            payment == null
                ? 'Pago no encontrado'
                : 'Este pago no puede registrarse (${payment.status.label})',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar pago')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.mintCard,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.esDeposito
                          ? payment.concepto.label
                          : Formatters.monthYear(payment.periodo),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.currency(payment.monto),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vence: ${Formatters.date(payment.fechaVencimiento)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ComprobantePicker(
              comprobanteBase64: _comprobanteBase64,
              onChanged: (value) => setState(() => _comprobanteBase64 = value),
            ),
            const SizedBox(height: 32),
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
                  : const Text('Enviar comprobante'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
