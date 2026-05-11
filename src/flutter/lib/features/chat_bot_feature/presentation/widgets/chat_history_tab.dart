import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/chat_bot_feature/data/cubit/chat_cubit.dart';
import 'package:campus_ai/features/chat_bot_feature/data/cubit/chat_history_cubit.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatHistoryTab extends StatefulWidget {
  final VoidCallback onSessionSelected;

  const ChatHistoryTab({super.key, required this.onSessionSelected});

  @override
  State<ChatHistoryTab> createState() => _ChatHistoryTabState();
}

class _ChatHistoryTabState extends State<ChatHistoryTab> {

  /// Group sessions by date sections
  String _sectionLabel(DateTime date) {
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

  String _titleForSession(
    String sessionId,
    List<ChatMessage> messages,
    Map<String, String> sessionTitles,
  ) {
    // Use persisted title from Firestore if available
    if (sessionTitles.containsKey(sessionId)) {
      return sessionTitles[sessionId]!;
    }
    final userMsg = messages.firstWhere(
      (m) => m.role == MessageRole.user,
      orElse: () => messages.first,
    );
    final content = userMsg.content.trim();
    return content.length > 50 ? '${content.substring(0, 50)}...' : content;
  }

  /// Sort sessions from newest to oldest based on the first message
  List<MapEntry<String, List<ChatMessage>>> _sortedSessions(
    Map<String, List<ChatMessage>> grouped,
  ) {
    final entries = grouped.entries.toList();
    entries.sort((a, b) {
      final aTime = a.value.first.timestamp;
      final bTime = b.value.first.timestamp;
      return bTime.compareTo(aTime);
    });
    return entries;
  }

  void _showRenameDialog(BuildContext context, String sessionId, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Rename Chat',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                context.read<ChatHistoryCubit>().renameSession(
                  sessionId,
                  newTitle,
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Chat',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        content: const Text('This will permanently delete this chat and all its messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatHistoryCubit>().deleteSession(sessionId);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
      builder: (context, state) {
        if (state is ChatHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatHistoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.red),
                const SizedBox(height: 12),
                Text(
                  'Failed to load history',
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        if (state is! ChatHistoryLoaded || state.sessions.isEmpty) {
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

        final sessions = _sortedSessions(state.sessions);

        // Build the list with section headers
        final List<Widget> items = [];
        String? lastSection;

        for (final entry in sessions) {
          final sessionId = entry.key;
          final sessionMessages = entry.value;
          final firstDate = sessionMessages.first.timestamp;
          final section = _sectionLabel(firstDate);

          if (section != lastSection) {
            items.add(_SectionHeader(label: section));
            lastSection = section;
          }

          final title = _titleForSession(sessionId, sessionMessages, state.sessionTitles);
          final messageCount = sessionMessages.length;

          items.add(
            Dismissible(
              key: ValueKey(sessionId),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              confirmDismiss: (_) async {
                _confirmDelete(context, sessionId);
                return false; // We handle deletion in the dialog
              },
              child: _HistoryItem(
                title: title,
                sessionId: sessionId,
                messageCount: messageCount,
                isActiveSession: sessionId == context.read<ChatCubit>().currentSessionId,
                onTap: () {
                  context.read<ChatCubit>().loadSession(sessionId);
                  widget.onSessionSelected();
                },
                onRename: () => _showRenameDialog(context, sessionId, title),
                onDelete: () => _confirmDelete(context, sessionId),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: items,
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
  final String sessionId;
  final int messageCount;
  final bool isActiveSession;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _HistoryItem({
    required this.title,
    required this.sessionId,
    required this.messageCount,
    required this.isActiveSession,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActiveSession
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActiveSession
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1)
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActiveSession
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: isActiveSession
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActiveSession ? FontWeight.w600 : FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$messageCount messages',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // More options menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'rename') {
                    onRename();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text('Rename', style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
