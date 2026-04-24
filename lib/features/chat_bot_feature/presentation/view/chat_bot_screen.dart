import 'package:campus_ai/features/chat_bot_feature/data/cubit/chat_cubit.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/widgets/chat_bot_screen_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => ChatCubit(),
        child: const ChatBotScreenBody(),
      ),
    );
  }
}
