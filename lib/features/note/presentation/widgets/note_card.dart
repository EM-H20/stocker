// FILE: lib/features/note/presentation/widgets/note_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/model/note.dart';
import 'dart:convert';

/// 노트 목록에 표시될 개별 노트 카드 위젯
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  // Quill Delta(JSON)에서 순수 텍스트만 추출하는 함수
  String _extractTextFromQuill(String content) {
    try {
      final List<dynamic> delta = jsonDecode(content);
      final buffer = StringBuffer();
      for (var op in delta) {
        if (op is Map && op.containsKey('insert')) {
          final text = op['insert'];
          if (text is String) {
            buffer.write(text.replaceAll('\\n', ' ').trim());
          }
        }
      }
      return buffer.toString();
    } catch (e) {
      return '내용을 불러올 수 없습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final plainContent = _extractTextFromQuill(note.content);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plainContent.isEmpty ? '내용 없음' : plainContent,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Text(
                '최종 수정: ${DateFormat('yyyy년 MM월 dd일').format(note.updatedAt)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}