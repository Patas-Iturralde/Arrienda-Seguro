import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/constants/property_types.dart';
import '../../data/models/contract.dart';
import '../../core/di/service_locator.dart';
import '../../data/models/rental_request.dart';
import '../../data/models/contract_generation_args.dart';
import '../../data/models/contract_status.dart';
import '../../data/models/user_role.dart';
import '../../providers/app_providers.dart';
import '../../widgets/step_indicator.dart';

class GenerateContractScreen extends StatefulWidget {
  const GenerateContractScreen({super.key, this.args});

  final ContractGenerationArgs? args;

  @override
  State<GenerateContractScreen> createState() => _GenerateContractScreenState();
}

class _GenerateContractScreenState extends State<GenerateContractScreen> {
  int _step = 0;
  bool _loading = false;

  String? _propertyId;
  String? _arrendadorId;
  String? _arrendatarioId;

  String _selectedTipo = PropertyTypes.all.first;
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _nombreInmuebleController = TextEditingController();

  final _arrendadorNombreController = TextEditingController();
  final _arrendadorApellidoController = TextEditingController();
  final _arrendadorCedulaController = TextEditingController();
  final _arrendadorEmailController = TextEditingController();

  final _arrendatarioNombreController = TextEditingController();
  final _arrendatarioApellidoController = TextEditingController();
  final _arrendatarioCedulaController = TextEditingController();
  final _arrendatarioEmailController = TextEditingController();

  final _canonController = TextEditingController();
  final _depositoController = TextEditingController();
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    _prefillFromArgs();
  }

  void _prefillFromArgs() {
    final args = widget.args;
    if (args == null) return;

    _propertyId = args.propertyId;
    _arrendadorId = args.arrendadorId;
    _arrendatarioId = args.arrendatarioId;

    _selectedTipo = _resolvePropertyTipo(args.propertyTipo);
    _nombreInmuebleController.text = args.propertyName;
    _direccionController.text = args.direccion;
    _ciudadController.text = args.ciudad;

    _arrendadorNombreController.text = args.arrendadorNombre;
    _arrendadorApellidoController.text = args.arrendadorApellido;
    _arrendadorCedulaController.text = args.arrendadorCedula;
    _arrendadorEmailController.text = args.arrendadorEmail;

    _arrendatarioNombreController.text = args.arrendatarioNombre;
    _arrendatarioApellidoController.text = args.arrendatarioApellido;
    _arrendatarioCedulaController.text = args.arrendatarioCedula;
    _arrendatarioEmailController.text = args.arrendatarioEmail;

    _canonController.text = args.canonMensual.toStringAsFixed(0);
    _depositoController.text = args.canonMensual.toStringAsFixed(0);
  }

  String _resolvePropertyTipo(String? tipo) {
    final normalized = PropertyTypes.normalize(tipo);
    if (PropertyTypes.all.contains(normalized)) return normalized;
    if (tipo?.trim().toLowerCase() == 'apartamento') return 'Departamento';
    return PropertyTypes.all.first;
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _ciudadController.dispose();
    _nombreInmuebleController.dispose();
    _arrendadorNombreController.dispose();
    _arrendadorApellidoController.dispose();
    _arrendadorCedulaController.dispose();
    _arrendadorEmailController.dispose();
    _arrendatarioNombreController.dispose();
    _arrendatarioApellidoController.dispose();
    _arrendatarioCedulaController.dispose();
    _arrendatarioEmailController.dispose();
    _canonController.dispose();
    _depositoController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _createContract();
    }
  }

  Future<void> _createContract() async {
    setState(() => _loading = true);

    final user = context.read<AuthProvider>().currentUser!;
    final arrendadorName =
        '${_arrendadorNombreController.text} ${_arrendadorApellidoController.text}';
    final arrendatarioName =
        '${_arrendatarioNombreController.text} ${_arrendatarioApellidoController.text}';

    final contract = Contract(
      id: const Uuid().v4(),
      propertyId: _propertyId ?? const Uuid().v4(),
      arrendadorId: _arrendadorId ??
          (user.role == UserRole.arrendador ? user.id : 'arrendador-1'),
      arrendatarioId: _arrendatarioId ?? 'arrendatario-new',
      propertyName: _nombreInmuebleController.text,
      arrendadorName: arrendadorName,
      arrendatarioName: arrendatarioName,
      direccion: '${_direccionController.text}, ${_ciudadController.text}',
      canonMensual: double.tryParse(_canonController.text.replaceAll('.', '')) ?? 0,
      deposito: double.tryParse(_depositoController.text.replaceAll('.', '')) ?? 0,
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      status: ContractStatus.activo,
      clausulas: MockDataServiceClauses.defaultClauses,
    );

    final contractProvider = context.read<ContractProvider>();
    final paymentProvider = context.read<PaymentProvider>();

    await contractProvider.createContract(contract);
    await paymentProvider.loadDashboardData(user);

    final rentalRequestId = widget.args?.rentalRequestId;
    if (rentalRequestId != null) {
      await ServiceLocator.instance.rentalRequestRepository.updateStatus(
        rentalRequestId,
        RentalRequestStatus.contratoGenerado,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Contrato generado. Se creó el calendario de pagos mensuales.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args != null ? 'Contrato de arriendo' : 'Generar Contrato',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: StepIndicator(currentStep: _step, totalSteps: 3),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: switch (_step) {
                0 => _buildPropertyStep(),
                1 => _buildPartiesStep(),
                _ => _buildTermsStep(),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _next,
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_step < 2 ? 'Siguiente' : 'Generar contrato'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          if (_step > 0) {
                            setState(() => _step--);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                  child: Text(_step > 0 ? 'Anterior' : 'Cancelar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos del Inmueble',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedTipo),
          initialValue: _selectedTipo,
          decoration: const InputDecoration(labelText: 'Tipo de inmueble'),
          items: PropertyTypes.all
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedTipo = v);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nombreInmuebleController,
          decoration: const InputDecoration(labelText: 'Nombre del inmueble'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _direccionController,
          decoration: const InputDecoration(labelText: 'Dirección'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ciudadController,
          decoration: const InputDecoration(labelText: 'Ciudad'),
        ),
      ],
    );
  }

  Widget _buildPartiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos de las partes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        const Text(
          'Arrendador',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _arrendadorNombreController,
          decoration: const InputDecoration(labelText: 'Nombres'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _arrendadorApellidoController,
          decoration: const InputDecoration(labelText: 'Apellidos'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _arrendadorCedulaController,
          decoration: const InputDecoration(labelText: 'Número de cédula'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _arrendadorEmailController,
          decoration: const InputDecoration(labelText: 'Correo electrónico'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        const Text(
          'Arrendatario',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _arrendatarioNombreController,
          decoration: const InputDecoration(labelText: 'Nombres'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _arrendatarioApellidoController,
          decoration: const InputDecoration(labelText: 'Apellidos'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _arrendatarioCedulaController,
          decoration: const InputDecoration(labelText: 'Número de cédula'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _arrendatarioEmailController,
          decoration: const InputDecoration(labelText: 'Correo electrónico'),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildTermsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Términos del contrato',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _canonController,
          decoration: const InputDecoration(labelText: 'Canon mensual'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _depositoController,
          decoration: const InputDecoration(labelText: 'Depósito en garantía'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Fecha inicio'),
          subtitle: Text(Formatters.date(_fechaInicio)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _fechaInicio,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) setState(() => _fechaInicio = date);
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Fecha fin'),
          subtitle: Text(Formatters.date(_fechaFin)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _fechaFin,
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );
            if (date != null) setState(() => _fechaFin = date);
          },
        ),
      ],
    );
  }
}

/// Cláusulas por defecto reutilizables
class MockDataServiceClauses {
  static const defaultClauses = [
    ContractClause(
      titulo: 'Objeto del contrato',
      contenido:
          'El ARRENDADOR cede en arrendamiento al ARRENDATARIO el inmueble descrito.',
    ),
    ContractClause(
      titulo: 'Canon de arrendamiento',
      contenido:
          'El canon mensual será pagado dentro de los primeros cinco días de cada mes.',
    ),
    ContractClause(
      titulo: 'Depósito en garantía',
      contenido:
          'El ARRENDATARIO entrega un depósito reembolsable al finalizar el contrato.',
    ),
  ];
}
