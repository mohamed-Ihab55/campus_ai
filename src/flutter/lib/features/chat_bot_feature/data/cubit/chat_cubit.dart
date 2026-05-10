import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';
import 'package:campus_ai/features/chat_bot_feature/data/services/chat_service.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/widgets/chat_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final ChatRemoteService _remoteService;

  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  ChatCubit({ChatRepository? repository, ChatRemoteService? remoteService})
    : _repository = repository ?? ChatRepository(),
      _remoteService = remoteService ?? ChatRemoteService(),
      super(const ChatInitial());

  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  Future<void> loadMessages() async {
    try {
      await _messagesSubscription?.cancel();

      _messagesSubscription = _repository
          .getMessages(userId: _userId)
          .listen(
            (messages) {
              emit(ChatSuccess(messages)); // Firestore is source of truth
            },
            onError: (error) {
              emit(ChatError(state.messages, error.toString()));
            },
          );
    } catch (e) {
      emit(ChatError(state.messages, e.toString()));
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final trimmedMessage = message.trim();

    final userMessage = ChatMessage(
      content: trimmedMessage,
      role: MessageRole.user,
      userId: _userId,
    );

    await _repository.saveMessage(
      content: userMessage.content,
      role: MessageRole.user,
      userId: _userId,
      isError: false,
    );

    final responseBuffer = StringBuffer();
    String? apiMessageId;

    await _remoteService.sendMessageStreaming(
      message: trimmedMessage,
      userId: _userId,

      onMessageId: (id) {
        apiMessageId = id;
      },

      onToken: (token) {
        responseBuffer.write(token);

        final updated = [
          ...state.messages,
          ChatMessage(
            id: apiMessageId,
            content: responseBuffer.toString(),
            role: MessageRole.assistant,
            userId: _userId,
          ),
        ];

        emit(ChatStreaming(updated));
      },

      onDone: () async {
        final fullReply = responseBuffer.toString().trim();

        final assistantMessage = ChatMessage(
          id: apiMessageId,
          content: fullReply,
          role: MessageRole.assistant,
          userId: _userId,
        );

        await _repository.saveMessage(
          id: apiMessageId,
          content: fullReply,
          role: MessageRole.assistant,
          userId: _userId,
          isError: false,
        );

        // 🔥 DO NOT rebuild manually — Firestore will push update
      },

      onError: (error) async {
        final errorMessage = ChatMessage(
          content: error.toString(),
          role: MessageRole.assistant,
          userId: _userId,
          isError: true,
        );

        await _repository.saveMessage(
          content: errorMessage.content,
          role: MessageRole.assistant,
          userId: _userId,
          isError: true,
        );

        emit(ChatError([...state.messages, errorMessage], error));
      },
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
