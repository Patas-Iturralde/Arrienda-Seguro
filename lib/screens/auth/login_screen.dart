import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_role.dart';
import '../../providers/app_providers.dart';
import '../shell/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: '123456');
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
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
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (created == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.arrendatario;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context.read<AuthProvider>().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
          role: _role,
        );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _loading = false;
        _error = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apellidoController,
              decoration: const InputDecoration(labelText: 'Apellido'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo'),
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Correo inválido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña (mín. 6 caracteres)',
              ),
              validator: (v) =>
                  v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Tipo de usuario'),
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
                  : const Text('Registrarme'),
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
