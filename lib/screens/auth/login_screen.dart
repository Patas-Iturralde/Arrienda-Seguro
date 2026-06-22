import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/id_document_type.dart';
import '../../data/models/marital_status.dart';
import '../../data/models/user_role.dart';
import '../../providers/app_providers.dart';
import '../../widgets/base64_image_picker.dart';
import '../../widgets/id_document_picker.dart';
import '../../widgets/terms_and_conditions_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context.read<AuthProvider>().signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _loading = false);
    } else {
      setState(() {
        _loading = false;
        _error = result.error ?? 'No se pudo iniciar sesión.';
      });
    }
  }

  void _quickLogin(String email) {
    _emailController.text = email;
    _login();
  }

  Future<void> _openRegister() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final useFirebase = firebaseEnabled;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.home_work,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Arrienda Seguro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Administra tus arriendos de forma segura',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loading ? null : _openRegister,
                child: Text(useFirebase ? 'Crear cuenta' : 'Registrarse (demo)'),
              ),
              if (!useFirebase) ...[
                const SizedBox(height: 32),
                const Text(
                  'Acceso rápido (demo)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _DemoUserTile(
                  role: UserRole.admin,
                  email: 'admin@arriendaseguro.com',
                  onTap: () => _quickLogin('admin@arriendaseguro.com'),
                ),
                _DemoUserTile(
                  role: UserRole.arrendador,
                  email: 'juan.perez@email.com',
                  onTap: () => _quickLogin('juan.perez@email.com'),
                ),
                _DemoUserTile(
                  role: UserRole.arrendatario,
                  email: 'maria.gonzalez@email.com',
                  onTap: () => _quickLogin('maria.gonzalez@email.com'),
                ),
              ] else ...[
                const SizedBox(height: 24),
                const Text(
                  'Con Firebase activo debes crear una cuenta real o usar '
                  'un usuario que exista en Authentication.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _ocupacionController = TextEditingController();
  final _domicilioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _role = UserRole.arrendatario;
  MaritalStatus _estadoCivil = MaritalStatus.soltero;
  IdDocumentType _tipoDocumento = IdDocumentType.cedula;
  DateTime _fechaNacimiento = DateTime(1995, 1, 1);
  String? _fotoBase64;
  String? _documentoIdentidadBase64;
  bool _acceptedTerms = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _cedulaController.dispose();
    _ocupacionController.dispose();
    _domicilioController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_documentoIdentidadBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes subir la foto de tu documento de identidad'),
        ),
      );
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context.read<AuthProvider>().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
          telefono: _telefonoController.text.trim(),
          cedula: _cedulaController.text.trim(),
          role: _role,
          estadoCivil: _estadoCivil,
          ocupacion: _ocupacionController.text.trim(),
          domicilio: _domicilioController.text.trim(),
          tipoDocumentoIdentidad: _tipoDocumento,
          fechaNacimiento: _fechaNacimiento,
          documentoIdentidadBase64: _documentoIdentidadBase64!,
          fotoBase64: _fotoBase64,
        );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _loading = false;
        _error = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isAuthenticated) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Datos personales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  EditableProfilePhoto(
                    fotoBase64: _fotoBase64,
                    iniciales: _nombreController.text.isNotEmpty &&
                            _apellidoController.text.isNotEmpty
                        ? '${_nombreController.text[0]}${_apellidoController.text[0]}'
                            .toUpperCase()
                        : '?',
                    loading: false,
                    onPhotoChanged: (foto) =>
                        setState(() => _fotoBase64 = foto),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Foto de perfil (opcional)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_fotoBase64 != null) ...[
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => setState(() => _fotoBase64 = null),
                      child: const Text('Quitar foto'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apellidoController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Apellido *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa tu apellido' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cedulaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cédula / documento *',
                hintText: 'Ej: 1234567890',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa tu número de documento';
                }
                if (v.trim().length < 5) {
                  return 'Documento inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                hintText: 'Ej: +57 300 123 4567',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa tu teléfono';
                }
                if (v.trim().length < 7) {
                  return 'Teléfono inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MaritalStatus>(
              initialValue: _estadoCivil,
              decoration: const InputDecoration(labelText: 'Estado civil *'),
              items: MaritalStatus.values
                  .map(
                    (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _estadoCivil = v);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ocupacionController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Ocupación *',
                hintText: 'Ej: Ingeniero, Estudiante',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa tu ocupación' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _domicilioController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Domicilio *',
                hintText: 'Dirección de residencia',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa tu domicilio' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de nacimiento *'),
              subtitle: Text(Formatters.date(_fechaNacimiento)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _fechaNacimiento,
                  firstDate: DateTime(1940),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _fechaNacimiento = date);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IdDocumentType>(
              initialValue: _tipoDocumento,
              decoration: const InputDecoration(
                labelText: 'Tipo de documento *',
              ),
              items: IdDocumentType.values
                  .map(
                    (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _tipoDocumento = v);
              },
            ),
            const SizedBox(height: 16),
            IdDocumentPicker(
              tipoDocumento: _tipoDocumento,
              documentoBase64: _documentoIdentidadBase64,
              onChanged: (value) =>
                  setState(() => _documentoIdentidadBase64 = value),
            ),
            const SizedBox(height: 24),
            const Text(
              'Acceso a la cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico *',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa tu correo';
                }
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña *',
                hintText: 'Mínimo 6 caracteres',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) =>
                  v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña *',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Confirma tu contraseña';
                }
                if (v != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              initialValue: _role,
              decoration: const InputDecoration(
                labelText: 'Tipo de usuario *',
              ),
              items: const [
                DropdownMenuItem(
                  value: UserRole.arrendatario,
                  child: Text('Arrendatario'),
                ),
                DropdownMenuItem(
                  value: UserRole.arrendador,
                  child: Text('Arrendador'),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _role = v);
              },
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  activeColor: AppColors.primary,
                  onChanged: _loading
                      ? null
                      : (value) =>
                          setState(() => _acceptedTerms = value ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _loading
                        ? null
                        : () => setState(
                              () => _acceptedTerms = !_acceptedTerms,
                            ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Acepto los '),
                          InkWell(
                            onTap: () =>
                                TermsAndConditionsDialog.show(context),
                            child: const Text(
                              'términos y condiciones',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Text(' de Arrienda Seguro *'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoUserTile extends StatelessWidget {
  const _DemoUserTile({
    required this.role,
    required this.email,
    required this.onTap,
  });

  final UserRole role;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Icon(
            switch (role) {
              UserRole.admin => Icons.admin_panel_settings,
              UserRole.arrendador => Icons.person,
              UserRole.arrendatario => Icons.person_outline,
            },
            color: AppColors.primary,
          ),
        ),
        title: Text(role.label),
        subtitle: Text(email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
