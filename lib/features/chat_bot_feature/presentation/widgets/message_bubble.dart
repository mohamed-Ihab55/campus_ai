import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.smart_toy,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),

              child: isUser
                  ? Text(
                message.content,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              )
                  : Directionality(
                textDirection: TextDirection.rtl,
                    child: MarkdownBody(
                                    data: message.content.replaceAll("\u200B", ''),
                                    selectable: true,

                                    builders: {
                    'table': _ProTableBuilder(),
                                    },

                                    styleSheet: MarkdownStyleSheet(
                                      tableCellsPadding: const EdgeInsets.all(12),
                    tableBorder: TableBorder.all(color: AppColors.textTertiary),
                    p: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color,
                      height: 1.5,
                    ),

                    code: TextStyle(
                      fontSize: 13,
                      backgroundColor: Colors.grey.shade200,
                      fontFamily: 'monospace',
                    ),

                    codeblockDecoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    listBullet: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                                    ),
                                  ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProTableBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag != 'table') return null;

    final rows = element.children
        ?.whereType<md.Element>()
        .where((e) => e.tag == 'tr')
        .toList() ??
        [];

    if (rows.isEmpty) return const SizedBox();
    final headerCells = rows.first.children
        ?.whereType<md.Element>()
        .where((e) => e.tag == 'th' || e.tag == 'td')
        .toList() ??
        [];

    final bodyRows = rows.skip(1).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textTertiary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Container(
                color: Colors.blueGrey.shade50,
                child: Row(
                  children: headerCells.map((cell) {
                    return _buildCell(
                      text: cell.textContent.trim(),
                      isHeader: true,
                    );
                  }).toList(),
                ),
              ),

              ...bodyRows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;

                final cells = row.children
                    ?.whereType<md.Element>()
                    .where((e) => e.tag == 'td')
                    .toList() ??
                    [];

                return Container(
                  color: index.isEven
                      ? Colors.white
                      : Colors.grey.shade50,
                  child: Row(
                    children: cells.map((cell) {
                      return _buildCell(
                        text: cell.textContent.trim(),
                        isHeader: false,
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell({
    required String text,
    required bool isHeader,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.textTertiary, width: 0.8),
          bottom: BorderSide(color: AppColors.textTertiary, width: 0.8),
        ),
      ),
      child: Text(
        text,
        textAlign: isHeader ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
          color: isHeader ? AppColors.textPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }
}