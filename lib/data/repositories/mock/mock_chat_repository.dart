import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../models/chat_message.dart';
import '../../models/chat_room.dart';
import '../../services/mock_data_service.dart';
import '../chat_repository.dart';

class MockChatRepository implements ChatRepository {
  MockChatRepository(this._data);

  final MockDataService _data;
  final _uuid = const Uuid();
  final _messagesController =
      StreamController<Map<String, List<ChatMessage>>>.broadcast();
  final _roomsController = StreamController<List<ChatRoom>>.broadcast();

  @override
  Stream<List<ChatRoom>> watchRoomsForUser(String userId) async* {
    yield _roomsForUser(userId);
    yield* _roomsController.stream.map((_) => _roomsForUser(userId));
  }

  List<ChatRoom> _roomsForUser(String userId) {
    return _data.chatRooms
        .where((r) => r.arrendadorId == userId || r.arrendatarioId == userId)
        .toList();
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String roomId) async* {
    yield List.from(_data.chatMessages[roomId] ?? []);
    yield* _messagesController.stream.map(
      (_) => List.from(_data.chatMessages[roomId] ?? []),
    );
  }

  @override
  Future<ChatRoom> getOrCreateRoom({
    required String propertyId,
    required String propertyName,
    required String arrendadorId,
    required String arrendadorName,
    required String arrendatarioId,
    required String arrendatarioName,
  }) async {
    final existing = _data.chatRooms.cast<ChatRoom?>().firstWhere(
          (r) =>
              r!.propertyId == propertyId &&
              r.arrendatarioId == arrendatarioId,
          orElse: () => null,
        );
    if (existing != null) return existing;

    final room = ChatRoom(
      id: _uuid.v4(),
      propertyId: propertyId,
      propertyName: propertyName,
      arrendadorId: arrendadorId,
      arrendadorName: arrendadorName,
      arrendatarioId: arrendatarioId,
      arrendatarioName: arrendatarioName,
      lastMessageAt: DateTime.now(),
    );
    _data.chatRooms.add(room);
    _data.chatMessages[room.id] = [];
    _roomsController.add(_data.chatRooms);
    return room;
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final message = ChatMessage(
      id: _uuid.v4(),
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
    );
    _data.chatMessages.putIfAbsent(roomId, () => []).add(message);

    final roomIndex = _data.chatRooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      final room = _data.chatRooms[roomIndex];
      _data.chatRooms[roomIndex] = ChatRoom(
        id: room.id,
        propertyId: room.propertyId,
        propertyName: room.propertyName,
        arrendadorId: room.arrendadorId,
        arrendadorName: room.arrendadorName,
        arrendatarioId: room.arrendatarioId,
        arrendatarioName: room.arrendatarioName,
        lastMessage: text,
        lastMessageAt: message.timestamp,
      );
    }

    _messagesController.add(_data.chatMessages);
    _roomsController.add(_data.chatRooms);
  }
}
