import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/property.dart';
import '../../providers/app_providers.dart';
import '../../providers/property_provider.dart';

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key, this.property});

  final Property? property;

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _direccionController;
  late final TextEditingController _ciudadController;
  late final TextEditingController _valorController;
  late final TextEditingController _tipoController;
  late final TextEditingController _fotosController;
  late final TextEditingController _serviciosController;
  late bool _disponible;
  bool _saving = false;

  bool get _isEditing => widget.property != null;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _descripcionController = TextEditingController(text: p?.descripcion ?? '');
    _direccionController = TextEditingController(text: p?.direccion ?? '');
    _ciudadController = TextEditingController(text: p?.ciudad ?? '');
    _valorController = TextEditingController(
      text: p != null ? p.valor.toStringAsFixed(0) : '',
    );
    _tipoController = TextEditingController(text: p?.tipo ?? 'Departamento');
    _fotosController = TextEditingController(text: p?.fotos.join('\n') ?? '');
    _serviciosController =
        TextEditingController(text: p?.servicios.join('\n') ?? '');
    _disponible = p?.disponible ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _valorController.dispose();
    _tipoController.dispose();
    _fotosController.dispose();
    _serviciosController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    final fotos = _fotosController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final servicios = _serviciosController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final property = Property(
      id: widget.property?.id ?? const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      direccion: _direccionController.text.trim(),
      ciudad: _ciudadController.text.trim(),
      valor: double.parse(_valorController.text.trim()),
      arrendadorId: user.id,
      arrendadorNombre: user.nombreCompleto,
      tipo: _tipoController.text.trim(),
      fotos: fotos,
      servicios: servicios,
      disponible: _disponible,
    );

    try {
      await context.read<PropertyProvider>().save(
            property,
            isNew: !_isEditing,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar departamento' : 'Nuevo departamento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del lugar *',
                hintText: 'Ej: Apartamento moderno en Chapinero',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor del departamento (mensual) *',
                prefixText: '\$ ',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                if (double.tryParse(v.trim()) == null) return 'Número inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección *',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ciudadController,
              decoration: const InputDecoration(
                labelText: 'Ciudad *',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tipoController,
              decoration: const InputDecoration(
                labelText: 'Tipo de inmueble',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fotosController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Fotografías (URLs, una por línea)',
                hintText: 'https://...\nhttps://...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviciosController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Servicios (uno por línea)',
                hintText: 'WiFi incluido\nParqueadero',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Disponible'),
              subtitle: const Text(
                'Los arrendatarios solo ven departamentos disponibles',
              ),
              value: _disponible,
              activeTrackColor: AppColors.primaryLight,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _disponible = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isEditing ? 'Guardar cambios' : 'Publicar departamento'),
            ),
          ],
        ),
      ),
    );
  }
}
