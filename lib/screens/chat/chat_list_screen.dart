import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/chat_room.dart';
import '../../providers/app_providers.dart';
import '../../routing/app_routes.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis conversaciones'),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: ServiceLocator.instance.chatRepository.watchRoomsForUser(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar las conversaciones.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          }

          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return const Center(
              child: Text(
                'No tienes conversaciones aún',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final otherName = user.id == room.arrendadorId
                  ? room.arrendatarioName
                  : room.arrendadorName;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.chat, color: AppColors.primary),
                ),
                title: Text(room.propertyName),
                subtitle: Text(
                  '$otherName${room.lastMessage != null ? ' · ${room.lastMessage}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: room.lastMessageAt != null
                    ? Text(
                        Formatters.dateShort(room.lastMessageAt!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : null,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.chat,
                  arguments: room.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
