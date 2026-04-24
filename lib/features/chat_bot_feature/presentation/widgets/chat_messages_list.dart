import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/widgets/message_bubble.dart';
import 'package:flutter/material.dart';

class ChatMessagesList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController controller;

  const ChatMessagesList({
    super.key,
    required this.messages,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // reverse: true,
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (_, index) {
        return MessageBubble(message: messages[index]);
      },
    );
  }
}
