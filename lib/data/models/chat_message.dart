class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
