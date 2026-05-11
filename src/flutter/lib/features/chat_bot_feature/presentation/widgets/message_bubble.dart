import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  color: AppColors.surface,
                  fontSize: 14,
                ),
              )
                  : _AssistantContent(content: message.content),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantContent extends StatelessWidget {
  final String content;

  const _AssistantContent({required this.content});

  List<_Segment> _parse(String text) {
    final segments = <_Segment>[];
    final lines = text.split('\n');
    final buffer = StringBuffer();
    final tableBuffer = StringBuffer();
    bool inTable = false;

    for (final line in lines) {
      final isTableLine = line.trimLeft().startsWith('|');

      if (isTableLine) {
        if (!inTable) {
          if (buffer.isNotEmpty) {
            segments.add(_Segment.markdown(buffer.toString()));
            buffer.clear();
          }
          inTable = true;
        }
        tableBuffer.writeln(line);
      } else {
        if (inTable) {
          segments.add(_Segment.table(tableBuffer.toString()));
          tableBuffer.clear();
          inTable = false;
        }
        buffer.writeln(line);
      }
    }

    if (inTable) segments.add(_Segment.table(tableBuffer.toString()));
    if (buffer.isNotEmpty) segments.add(_Segment.markdown(buffer.toString()));

    return segments;
  }

  @override
  Widget build(BuildContext context) {
    final segments = _parse(content.replaceAll('\u200B', ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((seg) {
        if (seg.isTable) {
          return _TableWidget(raw: seg.text);
        }
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MarkdownBody(
            data: seg.text,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
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
              listBullet: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Segment {
  final String text;
  final bool isTable;

  _Segment.markdown(this.text) : isTable = false;
  _Segment.table(this.text) : isTable = true;
}

class _TableWidget extends StatelessWidget {
  final String raw;

  const _TableWidget({required this.raw});

  String _forceEn(String text) {
    const Map<String, String> map = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    };
    String result = text;
    map.forEach((k, v) => result = result.replaceAll(k, v));
    return result;
  }

  List<List<String>> _parseRows(String raw) {
    final lines = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.startsWith('|') && !_isSeparator(l))
        .toList();

    return lines.map((line) {
      return line
          .split('|')
          .where((cell) => cell.isNotEmpty)
          .map((cell) => cell.trim())
          .toList();
    }).toList();
  }

  bool _isSeparator(String line) {
    return RegExp(r'^\|[\s\-:|]+\|$').hasMatch(line.trim()) ||
        line.replaceAll(RegExp(r'[\|\-\s:]'), '').isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _parseRows(raw);
    if (rows.isEmpty) return const SizedBox();

    final headers = rows.first;
    final body = rows.skip(1).toList();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textTertiary, width: 0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DataTable(
              headingRowColor:
              WidgetStateProperty.all(Colors.blueGrey.shade50),
              border: TableBorder.all(
                color: AppColors.textTertiary,
                width: 0.8,
              ),
              columnSpacing: 24,
              horizontalMargin: 16,
              headingRowHeight: 52,
              dataRowMinHeight: 48,
              dataRowMaxHeight: double.infinity,
              columns: headers
                  .map(
                    (h) => DataColumn(
                  label: SizedBox(
                    width: 100,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        _forceEn(h),
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  .toList(),
              rows: body.asMap().entries.map((entry) {
                final cells = entry.value;
                final paddedCells = List.generate(
                  headers.length,
                      (i) => i < cells.length ? cells[i] : '',
                );
                return DataRow(
                  color: WidgetStateProperty.resolveWith(
                        (states) => entry.key.isEven
                        ? Colors.white
                        : Colors.grey.shade50,
                  ),
                  cells: paddedCells
                      .map(
                        (c) => DataCell(
                      SizedBox(
                        width: 100,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            _forceEn(c),
                            textAlign: TextAlign.right,
                            softWrap: true,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      .toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}