import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveMessage({
    required String content,
    required MessageRole role,
    required bool isError,
  }) async {
    final message = ChatMessage(
      content: content,
      role: role,
      isError: isError,
    );

    await _firestore
        .collection('messages')
        .doc(message.id)
        .set(message.toJson());
  }

  Future<List<ChatMessage>> loadMessages() async {
    final snapshot = await _firestore
        .collection('messages')
        .orderBy('timestamp')
        .get();

    return snapshot.docs
        .map((doc) => ChatMessage.fromJson(doc.data()))
        .toList();
  }
}