import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/chat_message.dart';
import '../../models/chat_room.dart';
import '../chat_repository.dart';

class FirebaseChatRepository implements ChatRepository {
  FirebaseChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('chat_rooms');

  @override
  Stream<List<ChatRoom>> watchRoomsForUser(String userId) {
    return _rooms
        .where(Filter.or(
          Filter('arrendadorId', isEqualTo: userId),
          Filter('arrendatarioId', isEqualTo: userId),
        ))
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String roomId) {
    return _rooms
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
            .toList());
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
    final existing = await _rooms
        .where('propertyId', isEqualTo: propertyId)
        .where('arrendatarioId', isEqualTo: arrendatarioId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      return ChatRoom.fromMap(doc.id, doc.data());
    }

    final room = ChatRoom(
      id: '',
      propertyId: propertyId,
      propertyName: propertyName,
      arrendadorId: arrendadorId,
      arrendadorName: arrendadorName,
      arrendatarioId: arrendatarioId,
      arrendatarioName: arrendatarioName,
      lastMessageAt: DateTime.now(),
    );

    final doc = await _rooms.add(room.toMap());
    return room.copyWithId(doc.id);
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final now = DateTime.now();
    final message = ChatMessage(
      id: '',
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: now,
    );

    await _rooms.doc(roomId).collection('messages').add(message.toMap());
    await _rooms.doc(roomId).update({
      'lastMessage': text,
      'lastMessageAt': now.toIso8601String(),
    });
  }
}

extension on ChatRoom {
  ChatRoom copyWithId(String id) => ChatRoom(
        id: id,
        propertyId: propertyId,
        propertyName: propertyName,
        arrendadorId: arrendadorId,
        arrendadorName: arrendadorName,
        arrendatarioId: arrendatarioId,
        arrendatarioName: arrendatarioName,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
      );
}
