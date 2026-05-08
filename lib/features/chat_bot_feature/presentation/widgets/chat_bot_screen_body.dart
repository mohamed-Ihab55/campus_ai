import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/chat_bot_feature/data/cubit/chat_cubit.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/widgets/chat_error_banner.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/widgets/chat_input_field.dart';
import 'package:campus_ai/features/chat_bot_feature/presentation/widgets/chat_messages_list.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBotScreenBody extends StatefulWidget {
  const ChatBotScreenBody({super.key});

  @override
  State<ChatBotScreenBody> createState() => _ChatBotScreenBodyState();
}

class _ChatBotScreenBodyState extends State<ChatBotScreenBody> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(ChatState state) {
    final text = _controller.text.trim();
    if (text.isEmpty || state is ChatLoading) return;

    context.read<ChatCubit>().sendMessage(text);
    _controller.clear();
    _scrollBottom();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatError) _scrollBottom();
      },
      builder: (context, state) {
        final messages = state.messages;

        return Scaffold(
          backgroundColor: AppColors.bgColor,
          body: Column(
            children: [
              SizedBox(height: 50,),
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/d3bs.png',width: 160,),
                            // const SizedBox(height: 16),
                             RichText(
                              text: TextSpan(
                                text: "Start a conversation with ",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: "D3bs",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    : ChatMessagesList(
                        messages: messages,
                        controller: _scrollController,
                      ),
              ),
              if (state is ChatError)
                ChatErrorBanner(message: state.errorMessage),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ChatInputField(
                  controller: _controller,
                  isLoading: state is ChatLoading,
                  onSend: () => _send(state),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
