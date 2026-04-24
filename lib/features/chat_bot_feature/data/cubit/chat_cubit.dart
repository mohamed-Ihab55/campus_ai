import 'package:bloc/bloc.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';
import 'package:campus_ai/features/chat_bot_feature/data/services/chat_service.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/widgets/chat_repository.dart';
import 'package:equatable/equatable.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final ChatRemoteService _remoteService;

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

    emit(ChatLoading([...currentMessages, userMessage]));

    try {
      await _repository.saveMessage(
        content: userMessage.content,
        role: MessageRole.user,
        isError: false,
      );

      final reply = await _remoteService.sendMessage(
        message: trimmedMessage,
        conversationHistory: currentMessages,
      );

      final assistantMessage = ChatMessage(
        content: reply,
        role: MessageRole.assistant,
      );

      await _repository.saveMessage(
        content: assistantMessage.content,
        role: MessageRole.assistant,
        isError: false,
      );

      emit(ChatSuccess([
        ...currentMessages,
        userMessage,
        assistantMessage,
      ]));
    } catch (e) {
      final errorMessage = ChatMessage(
        content: 'Something went wrong. Please try again.',
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
        e.toString(),
      ));
    }
  }
}