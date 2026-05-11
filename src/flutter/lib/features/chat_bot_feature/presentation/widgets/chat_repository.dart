import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/model/chat_model.dart';

class ChatRepository {
  final _messagesRef =
  FirebaseFirestore.instance.collection('messages');

  final _sessionsRef =
  FirebaseFirestore.instance.collection('chat_sessions');

  User? get _currentUser =>
      FirebaseAuth.instance.currentUser;

  /// Get messages for a specific session (or all if no sessionId)
  Stream<List<ChatMessage>> getMessages({
    String? userId,
    String? sessionId,
  }) {
    final uid = userId ?? _currentUser?.uid;

    if (uid == null) {
      return const Stream.empty();
    }
    var query = _messagesRef.where('uid', isEqualTo: uid);

    if (sessionId != null) {
      query = query.where('sessionId', isEqualTo: sessionId);
    }
    return query
      .snapshots()
      .map((snapshot) {
        final messages = snapshot.docs.map((doc) {
          return ChatMessage.fromJson({...doc.data(), 'docId': doc.id});
        }).toList();
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return messages;
      });
  }

  /// Get ALL messages for a user (used by ChatHistoryCubit)
  Stream<List<ChatMessage>> getAllMessages({required String userId}) {
    return _messagesRef
        .where('uid', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs.map((doc) {
            return ChatMessage.fromJson({...doc.data(), 'docId': doc.id});
          }).toList();
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        });
  }

  /// Save message
  Future<void> saveMessage({
    String? id,
    required String content,
    required MessageRole role,
    required String userId,
    bool isError = false,
    String? sessionId,
  }) async {
    final email = _currentUser?.email;

    await _messagesRef.add({
      'messageId': id,
      'content': content.trim(),
      'role': role.name,
      'sessionId': sessionId,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': userId,
      'email': email,
      'isError': isError,
    });
  }

  /// Delete all messages for a specific session + its metadata
  Future<void> deleteSession({
    required String userId,
    required String sessionId,
  }) async {
    // Delete all messages
    final snapshot = await _messagesRef
        .where('uid', isEqualTo: userId)
        .where('sessionId', isEqualTo: sessionId)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete session metadata (title)
    final sessionDoc = await _sessionsRef
        .where('uid', isEqualTo: userId)
        .where('sessionId', isEqualTo: sessionId)
        .get();
    for (final doc in sessionDoc.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Rename a session (persisted to Firestore)
  Future<void> renameSession({
    required String userId,
    required String sessionId,
    required String title,
  }) async {
    // Check if a metadata doc already exists for this session
    final existing = await _sessionsRef
        .where('uid', isEqualTo: userId)
        .where('sessionId', isEqualTo: sessionId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Update existing doc
      await existing.docs.first.reference.update({'title': title});
    } else {
      // Create new metadata doc
      await _sessionsRef.add({
        'uid': userId,
        'sessionId': sessionId,
        'title': title,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get all session titles for a user (sessionId → title)
  Stream<Map<String, String>> getSessionTitles({required String userId}) {
    return _sessionsRef
        .where('uid', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final Map<String, String> titles = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final sessionId = data['sessionId']?.toString();
        final title = data['title']?.toString();
        if (sessionId != null && title != null) {
          titles[sessionId] = title;
        }
      }
      return titles;
    });
  }
}