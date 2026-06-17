import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/user_role.dart';
import '../../providers/app_providers.dart';
import '../../routing/app_routes.dart';
import '../../widgets/user_avatar.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  UserAvatar(user: user, radius: 40),
                  const SizedBox(height: 16),
                  Text(
                    user.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role.label,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ContactRow(icon: Icons.email_outlined, text: user.email),
                  const SizedBox(height: 8),
                  _ContactRow(icon: Icons.phone_outlined, text: user.telefono),
                  const SizedBox(height: 8),
                  _ContactRow(
                    icon: Icons.badge_outlined,
                    text: 'C.C. ${user.cedula}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.chat_bubble_outline,
            title: 'Mis conversaciones',
            onTap: () => Navigator.pushNamed(context, AppRoutes.chatList),
          ),
          _MenuTile(
            icon: Icons.security,
            title: 'Seguridad',
            onTap: () => _showPlaceholder(context, 'Seguridad'),
          ),
          _MenuTile(
            icon: Icons.payment,
            title: 'Métodos de pago',
            onTap: () => _showPlaceholder(context, 'Métodos de pago'),
          ),
          _MenuTile(
            icon: Icons.help_outline,
            title: 'Ayuda y soporte',
            onTap: () => _showPlaceholder(context, 'Ayuda y soporte'),
          ),
          if (user.role == UserRole.admin || user.role == UserRole.arrendador)
            _MenuTile(
              icon: Icons.description_outlined,
              title: 'Generar contrato',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.generateContract),
            ),
          _MenuTile(
            icon: Icons.folder_outlined,
            title: 'Documentos',
            onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
          ),
          _MenuTile(
            icon: Icons.calendar_month,
            title: 'Calendario',
            onTap: () => Navigator.pushNamed(context, AppRoutes.calendar),
          ),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            color: AppColors.error,
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title - próximamente')),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(
          title,
          style: TextStyle(color: color),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
