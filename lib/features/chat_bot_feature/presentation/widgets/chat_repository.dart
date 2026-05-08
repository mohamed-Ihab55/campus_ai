import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/model/chat_model.dart';

class ChatRepository {
  final _messagesRef =
  FirebaseFirestore.instance.collection('messages');

  User? get _currentUser =>
      FirebaseAuth.instance.currentUser;

  /// Get messages
  Stream<List<ChatMessage>> getMessages({
    String? userId,
  }) {
    final uid = userId ?? _currentUser?.uid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _messagesRef
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return ChatMessage.fromJson({
          ...data,
          'docId': doc.id,
          'timestamp':
          data['timestamp'] ?? Timestamp.now(),
        });
      }).toList();
    });
  }

  /// Save message
  Future<void> saveMessage({
    String? id,
    required String content,
    required MessageRole role,
    required String userId,
    bool isError = false,
  }) async {
    final email = _currentUser?.email;

    await _messagesRef.add({
      'messageId': id,
      'content': content.trim(),
      'role': role.name,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': userId,
      'email': email,
      'isError': isError,
    });
  }
}