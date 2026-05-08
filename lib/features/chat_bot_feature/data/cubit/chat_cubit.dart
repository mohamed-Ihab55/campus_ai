import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';
import 'package:campus_ai/features/chat_bot_feature/data/services/chat_service.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/widgets/chat_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final ChatRemoteService _remoteService;

  final String _sessionId = const Uuid().v4();

  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  ChatCubit({ChatRepository? repository, ChatRemoteService? remoteService})
    : _repository = repository ?? ChatRepository(),
      _remoteService = remoteService ?? ChatRemoteService(),
      super(const ChatInitial());

  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  Future<void> loadMessages() async {
    try {
      emit(ChatLoading(state.messages));

      await _messagesSubscription?.cancel();

      _messagesSubscription = _repository
          .getMessages(userId: _userId)
          .listen(
            (messages) {
              emit(ChatSuccess(messages));
            },
            onError: (error) {
              emit(ChatError(state.messages, error.toString()));
            },
          );
    } catch (e) {
      emit(
        ChatError(state.messages, 'Failed to load messages: ${e.toString()}'),
      );
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final trimmedMessage = message.trim();

    final currentMessages = List<ChatMessage>.from(state.messages);

    final userMessage = ChatMessage(
      content: trimmedMessage,
      role: MessageRole.user,
      userId: _userId,
    );

    final streamingMessage = ChatMessage(
      content: '',
      role: MessageRole.assistant,
      userId: _userId,
    );

    emit(ChatLoading([...currentMessages, userMessage, streamingMessage]));

    try {
      await _repository.saveMessage(
        content: userMessage.content,
        role: MessageRole.user,
        userId: _userId,
        isError: false,
      );

      final StringBuffer responseBuffer = StringBuffer();

      String? apiMessageId;

      await _remoteService.sendMessageStreaming(
        message: trimmedMessage,
        sessionId: _sessionId,
        userId: _userId,

        onMessageId: (messageId) {
          apiMessageId = messageId;
        },

        onToken: (token) {
          responseBuffer.write(token);

          final updatedMessages =
              List<ChatMessage>.from([...currentMessages, userMessage])..add(
                ChatMessage(
                  id: apiMessageId,
                  content: responseBuffer.toString(),
                  role: MessageRole.assistant,
                  userId: _userId,
                ),
              );

          emit(ChatStreaming(updatedMessages));
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

          emit(
            ChatSuccess([...currentMessages, userMessage, assistantMessage]),
          );
        },

        onError: (error) async {
          final errorMessage = ChatMessage(
            role: MessageRole.assistant,
            userId: _userId,
            isError: true, content:error.toString(),
          );

          await _repository.saveMessage(
            content: errorMessage.content,
            role: MessageRole.assistant,
            userId: _userId,
            isError: true,
          );

          emit(
            ChatError([...currentMessages, userMessage, errorMessage], error),
          );
        },
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        role: MessageRole.assistant,
        userId: _userId,
        isError: true, content: e.toString(),
      );

      emit(
        ChatError([
          ...currentMessages,
          userMessage,
          errorMessage,
        ], e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
