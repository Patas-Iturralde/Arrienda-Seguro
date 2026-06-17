import '../models/chat_message.dart';
import '../models/chat_room.dart';

abstract class ChatRepository {
  Stream<List<ChatRoom>> watchRoomsForUser(String userId);
  Stream<List<ChatMessage>> watchMessages(String roomId);
  Future<ChatRoom> getOrCreateRoom({
    required String propertyId,
    required String propertyName,
    required String arrendadorId,
    required String arrendadorName,
    required String arrendatarioId,
    required String arrendatarioName,
  });
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String text,
  });
}
