import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !isLoading,
            maxLines: null,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'Type your message...',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.bgColor),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            splashRadius: 26,
            onPressed: isLoading ? null : onSend,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: isLoading
                  ? const SizedBox(
                      key: ValueKey("loading"),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.bgColor,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      key: ValueKey("send"),
                      color: AppColors.bgColor,
                      size: 24,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
