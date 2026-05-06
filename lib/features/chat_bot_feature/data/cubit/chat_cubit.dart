import 'package:bloc/bloc.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';
import 'package:campus_ai/features/chat_bot_feature/data/services/chat_service.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/widgets/chat_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final ChatRemoteService _remoteService;
  final String _sessionId = const Uuid().v4(); // session ثابت للمستخدم

  ChatCubit({
    ChatRepository? repository,
    ChatRemoteService? remoteService,
  })  : _repository = repository ?? ChatRepository(),
        _remoteService = remoteService ?? ChatRemoteService(),
        super(const ChatInitial());

  Future<void> loadMessages() async {
    try {
      final messages = await _repository.loadMessages();
      emit(ChatSuccess(messages));
    } catch (e) {
      emit(ChatError(const [], 'Failed to load messages: ${e.toString()}'));
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final trimmedMessage = message.trim();
    final currentMessages = List<ChatMessage>.from(state.messages);

    final userMessage = ChatMessage(
      content: trimmedMessage,
      role: MessageRole.user,
    );

    // placeholder للـ assistant وهو بيكتب
    final streamingMessage = ChatMessage(
      content: '',
      role: MessageRole.assistant,
    );

    emit(ChatLoading([...currentMessages, userMessage, streamingMessage]));

    try {
      await _repository.saveMessage(
        content: userMessage.content,
        role: MessageRole.user,
        isError: false,
      );

      final StringBuffer responseBuffer = StringBuffer();

      await _remoteService.sendMessageStreaming(
        message: trimmedMessage,
        sessionId: _sessionId,
        onToken: (token) {
          responseBuffer.write(token);

          // حدّث الـ streaming message بكل token جديد
          final updatedMessages = List<ChatMessage>.from(
            [...currentMessages, userMessage],
          )..add(ChatMessage(
            content: responseBuffer.toString(),
            role: MessageRole.assistant,
          ));

          emit(ChatStreaming(updatedMessages));
        },
        onDone: () async {
          final fullReply = responseBuffer.toString().trim();

          final assistantMessage = ChatMessage(
            content: fullReply,
            role: MessageRole.assistant,
          );

          await _repository.saveMessage(
            content: fullReply,
            role: MessageRole.assistant,
            isError: false,
          );

          emit(ChatSuccess([
            ...currentMessages,
            userMessage,
            assistantMessage,
          ]));
        },
        onError: (error) async {
          final errorMessage = ChatMessage(
            content: 'حدث خطأ، حاول مرة أخرى.',
            role: MessageRole.assistant,
            isError: true,
          );

          await _repository.saveMessage(
            content: errorMessage.content,
            role: MessageRole.assistant,
            isError: true,
          );

          emit(ChatError(
            [...currentMessages, userMessage, errorMessage],
            error,
          ));
        },
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        content: 'حدث خطأ، حاول مرة أخرى.',
        role: MessageRole.assistant,
        isError: true,
      );

      emit(ChatError(
        [...currentMessages, userMessage, errorMessage],
        e.toString(),
      ));
    }
  }
}
