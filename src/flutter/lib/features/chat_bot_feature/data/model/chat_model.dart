import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

class ChatMessage {
  final String? id;

  final String? docId;
final String? sessionId;
  final String? userId;

  final String content;

  final MessageRole role;

  final DateTime timestamp;

  final bool isError;

  ChatMessage({
    this.id,
    this.docId,
    this.sessionId,
    this.userId,
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? sessionId,
    String? id,
    String? docId,
    String? userId,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isError,
  }) {
    return ChatMessage(
       sessionId: sessionId ?? this.sessionId,
      id: id ?? this.id,
      docId: docId ?? this.docId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': id,
      'sessionId': sessionId,
      'docId': docId,
      'uid': userId,
      'content': content,
      'role': role.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'isError': isError,
    };
  }

  factory ChatMessage.fromJson(
      Map<String, dynamic> json,
      ) {
    final dynamic rawTimestamp = json['timestamp'];

    DateTime parsedTimestamp;

    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(
        rawTimestamp,
      ) ??
          DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return ChatMessage(
      sessionId: json['sessionId']?.toString(),
      id: json['messageId']?.toString(),

      docId: json['docId']?.toString(),

      userId: json['uid']?.toString(),

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