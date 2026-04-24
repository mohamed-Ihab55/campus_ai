import 'package:bloc/bloc.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final trimmedMessage = message.trim();

    final userMessage = ChatMessage(
      content: trimmedMessage,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final currentMessages = List<ChatMessage>.from(state.messages);

    // 🔹 Emit loading with user message
    emit(ChatLoading([...currentMessages, userMessage]));

    // try {
    //   /// 🔹 Save user message
    //   await ChatRepository().saveMessage(
    //     content: userMessage.content,
    //     role: MessageRole.user,
    //     userId: userId,
    //   );

    /// 🔹 Call Gemini API
    // final response = await geminiService.sendMessage(
    //   message: trimmedMessage,
    //   conversationHistory: currentMessages,
    // );

    // final assistantMessage = ChatMessage(
    //   content: response,
    //   role: MessageRole.assistant,
    //   timestamp: DateTime.now(),
    // );

    /// 🔹 Save assistant message
    // await ChatRepository().saveMessage(
    //   content: assistantMessage.content,
    //   role: MessageRole.assistant,
    //   userId: userId,
    // );

    //   emit(ChatSuccess([
    //     ...currentMessages,
    //     userMessage,
    //     assistantMessage,
    //   ]));
    // } catch (e) {
    //   /// 🔥 تحسين: اعرض error message كويس
    //   final errorMessage = ChatMessage(
    //     content: "Something went wrong. Please try again.",
    //     role: MessageRole.assistant,
    //     timestamp: DateTime.now(),
    //     isError: true,
    //   );

    // emit(ChatError(
    //   [...currentMessages, userMessage, errorMessage],
    //   e.toString(),
    // ));
    // }
  }
}
