import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/contract.dart';
import '../../providers/app_providers.dart';
import '../../widgets/info_row.dart';
import '../../widgets/step_indicator.dart';

class RenewContractScreen extends StatefulWidget {
  const RenewContractScreen({super.key, required this.contractId});

  final String contractId;

  @override
  State<RenewContractScreen> createState() => _RenewContractScreenState();
}

class _RenewContractScreenState extends State<RenewContractScreen> {
  Contract? _contract;
  bool _loading = false;
  late DateTime _nuevaFechaFin;
  late double _nuevoCanon;

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  Future<void> _loadContract() async {
    final contract =
        await context.read<ContractProvider>().getById(widget.contractId);
    if (contract != null && mounted) {
      setState(() {
        _contract = contract;
        _nuevaFechaFin = contract.fechaFin.add(const Duration(days: 365));
        _nuevoCanon = contract.canonMensual;
      });
    }
  }

  Future<void> _confirmRenewal() async {
    setState(() => _loading = true);
    await context.read<ContractProvider>().renewContract(
          widget.contractId,
          _nuevaFechaFin,
          _nuevoCanon,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contrato renovado exitosamente'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Renovar Contrato')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: StepIndicator(currentStep: 1, totalSteps: 3),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revisar información',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          InfoRow(label: 'Inmueble', value: contract.propertyName),
                          const Divider(),
                          InfoRow(
                            label: 'Vencimiento actual',
                            value: Formatters.date(contract.fechaFin),
                          ),
                          const Divider(),
                          InfoRow(
                            label: 'Nuevo vencimiento',
                            value: Formatters.date(_nuevaFechaFin),
                          ),
                          const Divider(),
                          InfoRow(
                            label: 'Canon actual',
                            value: Formatters.currency(contract.canonMensual),
                          ),
                          const Divider(),
                          InfoRow(
                            label: 'Nuevo canon',
                            value: Formatters.currency(_nuevoCanon),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nuevo canon mensual',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final parsed = double.tryParse(v.replaceAll('.', ''));
                      if (parsed != null) setState(() => _nuevoCanon = parsed);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Nueva fecha de vencimiento'),
                    subtitle: Text(Formatters.date(_nuevaFechaFin)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _nuevaFechaFin,
                        firstDate: contract.fechaFin,
                        lastDate: DateTime(2035),
                      );
                      if (date != null) setState(() => _nuevaFechaFin = date);
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _confirmRenewal,
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Confirmar renovación'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
