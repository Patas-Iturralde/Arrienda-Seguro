import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/contract_status.dart';
import '../../providers/app_providers.dart';
import '../../routing/app_routes.dart';
import '../../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      context.read<ContractProvider>().loadContracts(auth.currentUser),
      context.read<PaymentProvider>().loadDashboardData(auth.currentUser),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final contracts = context.watch<ContractProvider>();
    final payments = context.watch<PaymentProvider>();
    final unread = ServiceLocator.instance.notificationRepository.unreadCount;

    final activeCount =
        contracts.contracts.where((c) => c.status != ContractStatus.finalizado).length;
    final expiring = contracts.contracts
        .where((c) => c.status == ContractStatus.porVencer)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('¡Hola, ${user.nombre}!'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SummaryCard(
              title: 'Resumen',
              children: [
                _SummaryItem(
                  icon: Icons.description,
                  label: '$activeCount Contratos activos',
                ),
                const SizedBox(height: 8),
                _SummaryItem(
                  icon: Icons.pending_actions,
                  label: '${payments.pendingCount} Pago${payments.pendingCount == 1 ? '' : 's'} pendiente${payments.pendingCount == 1 ? '' : 's'}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (payments.nextPayment != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Próximo pago',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        Formatters.currency(payments.nextPayment!.monto),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vence: ${Formatters.date(payments.nextPayment!.fechaVencimiento)}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
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
            ],
            if (expiring.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Próximo a vencer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...expiring.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.propertyName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Vence: ${Formatters.date(c.fechaFin)}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Faltan ${c.diasRestantes} días',
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ListTile(
              leading: const Icon(Icons.calendar_month, color: AppColors.primary),
              title: const Text('Calendario y recordatorios'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.calendar),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined, color: AppColors.primary),
              title: const Text('Documentos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}
