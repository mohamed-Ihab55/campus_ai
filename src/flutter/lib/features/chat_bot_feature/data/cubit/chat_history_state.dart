part of 'chat_history_cubit.dart';

abstract class ChatHistoryState extends Equatable {
  const ChatHistoryState();

  @override
  List<Object?> get props => [];
}

class ChatHistoryInitial extends ChatHistoryState {
  const ChatHistoryInitial();
}

class ChatHistoryLoading extends ChatHistoryState {
  const ChatHistoryLoading();
}

class ChatHistoryLoaded extends ChatHistoryState {
  final Map<String, List<ChatMessage>> sessions;

  /// Custom session titles from Firestore (sessionId → title)
  final Map<String, String> sessionTitles;

  const ChatHistoryLoaded(this.sessions, {this.sessionTitles = const {}});

  @override
  List<Object?> get props => [sessions, sessionTitles];
}

class ChatHistoryError extends ChatHistoryState {
  final String message;

  const ChatHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
