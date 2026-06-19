import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/chat_message.dart';
import '../../models/chat_room.dart';
import '../chat_repository.dart';

class FirebaseChatRepository implements ChatRepository {
  FirebaseChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('chat_rooms');

  List<ChatRoom> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => ChatRoom.fromMap(doc.id, doc.data()))
        .toList();
  }

  List<ChatRoom> _mergeRooms(List<ChatRoom> landlord, List<ChatRoom> tenant) {
    final byId = <String, ChatRoom>{};
    for (final room in [...landlord, ...tenant]) {
      byId[room.id] = room;
    }
    final merged = byId.values.toList();
    merged.sort((a, b) {
      final aDate = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return merged;
  }

  /// Dos queries simples (arrendador / arrendatario) en lugar de OR + orderBy,
  /// que Firestore suele rechazar con PERMISSION_DENIED.
  @override
  Stream<List<ChatRoom>> watchRoomsForUser(String userId) {
    final controller = StreamController<List<ChatRoom>>.broadcast();
    var landlordRooms = <ChatRoom>[];
    var tenantRooms = <ChatRoom>[];

    void emit() {
      if (controller.isClosed) return;
      controller.add(_mergeRooms(landlordRooms, tenantRooms));
    }

    final landlordSub = _rooms
        .where('arrendadorId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        landlordRooms = _mapSnapshot(snapshot);
        emit();
      },
      onError: (Object error, StackTrace stack) {
        debugPrint('Error al leer chats como arrendador: $error');
        if (!controller.isClosed) controller.addError(error, stack);
      },
    );

    final tenantSub = _rooms
        .where('arrendatarioId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        tenantRooms = _mapSnapshot(snapshot);
        emit();
      },
      onError: (Object error, StackTrace stack) {
        debugPrint('Error al leer chats como arrendatario: $error');
        if (!controller.isClosed) controller.addError(error, stack);
      },
    );

    controller.onCancel = () {
      landlordSub.cancel();
      tenantSub.cancel();
    };

    return controller.stream;
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
        .where('arrendadorId', isEqualTo: arrendadorId)
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
