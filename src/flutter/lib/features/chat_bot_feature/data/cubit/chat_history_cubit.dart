import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/widgets/chat_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'chat_history_state.dart';

class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  final ChatRepository _repository;
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<Map<String, String>>? _titlesSubscription;

  /// Cached data so we can combine messages + titles
  Map<String, List<ChatMessage>> _cachedSessions = {};
  Map<String, String> _cachedTitles = {};

  ChatHistoryCubit({
    ChatRepository? repository,
  })  : _repository = repository ?? ChatRepository(),
        super(const ChatHistoryInitial());

  /// Load all sessions for the user, grouped by sessionId
  void loadAllSessions() {
    emit(const ChatHistoryLoading());

    _messagesSubscription?.cancel();
    _titlesSubscription?.cancel();

    // Listen to messages
    _messagesSubscription = _repository
        .getAllMessages(userId: _userId)
        .listen(
          (messages) {
        final Map<String, List<ChatMessage>> grouped = {};
        for (final msg in messages) {
          final key = msg.sessionId ?? 'default';
          grouped.putIfAbsent(key, () => []).add(msg);
        }
        // Sort messages within each session by timestamp
        for (final key in grouped.keys) {
          grouped[key]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        }
        _cachedSessions = grouped;
        _emitLoaded();
      },
      onError: (error) {
        emit(ChatHistoryError(error.toString()));
      },
    );

    // Listen to session titles
    _titlesSubscription = _repository
        .getSessionTitles(userId: _userId)
        .listen(
          (titles) {
        _cachedTitles = titles;
        _emitLoaded();
      },
      onError: (_) {
        // Titles are optional, don't fail the whole history for this
      },
    );
  }

  void _emitLoaded() {
    emit(ChatHistoryLoaded(
      _cachedSessions,
      sessionTitles: _cachedTitles,
    ));
  }

  /// Rename a session (persisted to Firestore)
  Future<void> renameSession(String sessionId, String title) async {
    try {
      await _repository.renameSession(
        userId: _userId,
        sessionId: sessionId,
        title: title,
      );
      // The stream listener will automatically update the state
    } catch (e) {
      emit(ChatHistoryError('Failed to rename session: ${e.toString()}'));
    }
  }

  /// Delete a session and all its messages
  Future<void> deleteSession(String sessionId) async {
    try {
      await _repository.deleteSession(
        userId: _userId,
        sessionId: sessionId,
      );
      // The stream listener will automatically update the state
    } catch (e) {
      emit(ChatHistoryError('Failed to delete session: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _titlesSubscription?.cancel();
    return super.close();
  }
}
