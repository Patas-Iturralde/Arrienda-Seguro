class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.arrendadorId,
    required this.arrendadorName,
    required this.arrendatarioId,
    required this.arrendatarioName,
    this.lastMessage,
    this.lastMessageAt,
  });

  final String id;
  final String propertyId;
  final String propertyName;
  final String arrendadorId;
  final String arrendadorName;
  final String arrendatarioId;
  final String arrendatarioName;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  Map<String, dynamic> toMap() => {
        'propertyId': propertyId,
        'propertyName': propertyName,
        'arrendadorId': arrendadorId,
        'arrendadorName': arrendadorName,
        'arrendatarioId': arrendatarioId,
        'arrendatarioName': arrendatarioName,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt?.toIso8601String(),
      };

  factory ChatRoom.fromMap(String id, Map<String, dynamic> map) {
    return ChatRoom(
      id: id,
      propertyId: map['propertyId'] as String? ?? '',
      propertyName: map['propertyName'] as String? ?? '',
      arrendadorId: map['arrendadorId'] as String? ?? '',
      arrendadorName: map['arrendadorName'] as String? ?? '',
      arrendatarioId: map['arrendatarioId'] as String? ?? '',
      arrendatarioName: map['arrendatarioName'] as String? ?? '',
      lastMessage: map['lastMessage'] as String?,
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.tryParse(map['lastMessageAt'] as String)
          : null,
    );
  }
}
