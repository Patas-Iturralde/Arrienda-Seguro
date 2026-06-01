import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/contract.dart';
import '../../data/models/contract_status.dart';
import '../../providers/app_providers.dart';
import '../../routing/app_routes.dart';
import '../../widgets/info_row.dart';
import '../../widgets/status_badge.dart';

class ContractDetailScreen extends StatefulWidget {
  const ContractDetailScreen({super.key, required this.contractId});

  final String contractId;

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen>
    with SingleTickerProviderStateMixin {
  Contract? _contract;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContract();
  }

  Future<void> _loadContract() async {
    final contract =
        await context.read<ContractProvider>().getById(widget.contractId);
    if (mounted) setState(() => _contract = contract);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_contract == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final contract = _contract!;

    return Scaffold(
      appBar: AppBar(
        title: Text(contract.propertyName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Cláusulas'),
            Tab(text: 'Documentos'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SummaryTab(contract: contract),
                _ClausesTab(contract: contract),
                _DocumentsTab(contractId: contract.id),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estado del contrato'),
                    StatusBadge(status: contract.status),
                  ],
                ),
                if (contract.status != ContractStatus.finalizado) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Faltan ${contract.diasRestantes} días',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.paymentRecord,
                    arguments: contract.id,
                  ),
                  child: const Text('Ver pagos'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Descarga simulada del contrato PDF'),
                      ),
                    );
                  },
                  child: const Text('Descargar contrato'),
                ),
                if (contract.status == ContractStatus.porVencer) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.renewContract,
                      arguments: contract.id,
                    ),
                    child: const Text('Renovar contrato'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.contract});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                InfoRow(label: 'Arrendador', value: contract.arrendadorName),
                const Divider(),
                InfoRow(label: 'Arrendatario', value: contract.arrendatarioName),
                const Divider(),
                InfoRow(label: 'Dirección', value: contract.direccion),
                const Divider(),
                InfoRow(
                  label: 'Canon mensual',
                  value: Formatters.currency(contract.canonMensual),
                ),
                const Divider(),
                InfoRow(
                  label: 'Fecha inicio',
                  value: Formatters.date(contract.fechaInicio),
                ),
                const Divider(),
                InfoRow(
                  label: 'Fecha fin',
                  value: Formatters.date(contract.fechaFin),
                ),
                const Divider(),
                InfoRow(
                  label: 'Depósito en garantía',
                  value: Formatters.currency(contract.deposito),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ClausesTab extends StatelessWidget {
  const _ClausesTab({required this.contract});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contract.clausulas.length,
      itemBuilder: (context, index) {
        final clause = contract.clausulas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clause.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  clause.contenido,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
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

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab({required this.contractId});

  final String contractId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text('Documentos del contrato'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.documents,
              arguments: contractId,
            ),
            child: const Text('Ver documentos'),
          ),
        ],
      ),
    );
  }
}
