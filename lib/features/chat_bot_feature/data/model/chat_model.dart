import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    String? id,
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.isError = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp = timestamp ?? DateTime.now();

  /// 🔹 Convert object to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'isError': isError,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final dynamic rawTimestamp = json['timestamp'];

    DateTime parsedTimestamp;

    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.parse(rawTimestamp);
    } else {
      parsedTimestamp = DateTime.now();
    }

    return ChatMessage(
      id: json['id'],
      content: json['content'] ?? '',
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: parsedTimestamp,
      isError: json['isError'] ?? false,
    );
  }
}


