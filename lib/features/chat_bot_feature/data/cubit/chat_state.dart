part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  final List<ChatMessage> messages;

  const ChatState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatInitial extends ChatState {
  const ChatInitial() : super(const []);
}

class ChatLoading extends ChatState {
  const ChatLoading(super.messages);
}

class ChatSuccess extends ChatState {
  const ChatSuccess(super.messages);
}

class ChatError extends ChatState {
  final String errorMessage;

  const ChatError(super.messages, this.errorMessage);

  @override
  List<Object?> get props => [messages, errorMessage];
}
