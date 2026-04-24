import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final _messagesRef = FirebaseFirestore.instance.collection('messages');


  Stream<List<ChatMessage>> getMessages({String? userId}) {


    return _messagesRef
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ChatMessage.fromJson({
              ...data,
              'timestamp': data['timestamp'] ?? Timestamp.now(),
            });
          }).toList();
        });
  }

  Future<void> saveMessage({
    required String content,
    required MessageRole role,
    String? userId,
  }) async {

    await _messagesRef.add({
      'content': content.trim(),
      'role': role.name,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}