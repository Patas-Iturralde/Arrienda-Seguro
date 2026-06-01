import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/contract.dart';
import '../../data/models/contract_status.dart';
import '../../providers/app_providers.dart';
import '../../routing/app_routes.dart';
import '../../widgets/status_badge.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ContractProvider>()
          .loadContracts(context.read<AuthProvider>().currentUser);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Contract> _filter(List<Contract> contracts, ContractStatus? status) {
    var filtered = contracts;
    if (status != null) {
      filtered = filtered.where((c) => c.status == status).toList();
    }
    if (_search.isNotEmpty) {
      filtered = filtered
          .where((c) =>
              c.propertyName.toLowerCase().contains(_search.toLowerCase()) ||
              c.arrendatarioName.toLowerCase().contains(_search.toLowerCase()) ||
              c.arrendadorName.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final contracts = context.watch<ContractProvider>().contracts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Contratos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Activos'),
            Tab(text: 'Por vencer'),
            Tab(text: 'Finalizados'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar contrato...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ContractList(
                  contracts: _filter(contracts, ContractStatus.activo),
                ),
                _ContractList(
                  contracts: _filter(contracts, ContractStatus.porVencer),
                ),
                _ContractList(
                  contracts: _filter(contracts, ContractStatus.finalizado),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractList extends StatelessWidget {
  const _ContractList({required this.contracts});

  final List<Contract> contracts;

  @override
  Widget build(BuildContext context) {
    if (contracts.isEmpty) {
      return const Center(
        child: Text(
          'No hay contratos en esta categoría',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contract = contracts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              contract.propertyName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(contract.arrendatarioName),
                const SizedBox(height: 4),
                Text(
                  '${Formatters.dateShort(contract.fechaInicio)} - ${Formatters.dateShort(contract.fechaFin)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                StatusBadge(status: contract.status),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.contractDetail,
              arguments: contract.id,
            ),
          ),
        );
      },
    );
  }
}
