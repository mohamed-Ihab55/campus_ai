import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/chat_bot_feature/data/cubit/chat_cubit.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatHistoryTab extends StatelessWidget {
  const ChatHistoryTab({super.key});

  Map<String, List<ChatMessage>> _groupByDate(List<ChatMessage> messages) {
    final Map<String, List<ChatMessage>> grouped = {};
    for (final msg in messages) {
      final key = DateFormat('yyyy-MM-dd').format(msg.timestamp);
      grouped.putIfAbsent(key, () => []).add(msg);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: grouped[k]!};
  }

  String _sectionLabel(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff <= 7) return 'Previous 7 days';
    if (diff <= 30) return 'Previous 30 days';
    return DateFormat('MMMM yyyy').format(date);
  }

  String _titleForDay(List<ChatMessage> messages) {
    final userMsg = messages.firstWhere(
      (m) => m.role == MessageRole.user,
      orElse: () => messages.first,
    );
    final content = userMsg.content.trim();
    return content.length > 50 ? '${content.substring(0, 50)}...' : content;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final messages = state.messages;

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No conversations yet',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final grouped = _groupByDate(messages);

        // اعمل sections مش مكررة
        final List<MapEntry<String, String>> sections = [];
        String? lastLabel;
        for (final entry in grouped.entries) {
          final label = _sectionLabel(entry.key);
          if (label != lastLabel) {
            sections.add(MapEntry(label, entry.key));
            lastLabel = label;
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: grouped.length + sections.length,
          itemBuilder: (context, index) {
            // بنبني القائمة: section header + items
            int realIndex = 0;
            String? currentSection;
            for (final dateKey in grouped.keys) {
              final label = _sectionLabel(dateKey);
              if (label != currentSection) {
                if (index == realIndex) {
                  return _SectionHeader(label: label);
                }
                realIndex++;
                currentSection = label;
              }
              if (index == realIndex) {
                return _HistoryItem(title: _titleForDay(grouped[dateKey]!));
              }
              realIndex++;
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  const _HistoryItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 17,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
