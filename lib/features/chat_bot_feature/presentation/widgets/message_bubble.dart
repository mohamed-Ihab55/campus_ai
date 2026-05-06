import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/chat_bot_feature/data/model/chat_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                style: const TextStyle(color: Colors.white, fontSize: 14),
              )
                  : MarkdownBody(
                data: message.content,
                selectable: true,

                builders: {
                  'table': _ProTableBuilder(),
                  'tr': _ProTableBuilder(),
                  'td': _ProTableBuilder(),
                  'th': _ProTableBuilder(),
                },

                styleSheet: MarkdownStyleSheet(
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
        ],
      ),
    );
  }
}

/// 🚀 PROFESSIONAL TABLE BUILDER (ChatGPT style)
class _ProTableBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag != 'table') return null;

    final List<TableRow> rows = [];
    bool isHeader = true;

    for (final row in element.children ?? []) {
      if (row is md.Element && row.tag == 'tr') {
        final cells = row.children!
            .whereType<md.Element>()
            .map((e) => e.textContent)
            .toList();

        rows.add(
          TableRow(
            decoration: BoxDecoration(
              color: isHeader
                  ? Colors.grey.shade200
                  : rows.length.isEven
                  ? Colors.grey.shade50
                  : Colors.white,
            ),
            children: cells
                .map(
                  (cell) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12),
                child: Text(
                  cell,
                  textAlign:
                  isHeader ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                    isHeader ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ),
            )
                .toList(),
          ),
        );

        isHeader = false;
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder(
              horizontalInside:
              BorderSide(color: Colors.grey.shade300, width: 0.8),
            ),
            children: rows,
          ),
        ),
      ),
    );
  }
}