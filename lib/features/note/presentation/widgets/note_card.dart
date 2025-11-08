// FILE: lib/features/note/presentation/widgets/note_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/note.dart';
import 'dart:convert';
import '../../../../app/core/widgets/app_card.dart';

/// 노트 목록에 표시될 개별 노트 카드 위젯
class NoteCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final plainContent = _extractTextFromQuill(note.content);

    return AppCard.compact(
      margin: EdgeInsets.only(bottom: 16.h),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.6),
                  size: 22.sp,
                ),
                onPressed: onDelete,
                splashRadius: 20.r,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            plainContent.isEmpty ? '내용 없음' : plainContent,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.7),
                  height: 1.4,
                ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최종 수정: ${DateFormat('yyyy년 MM월 dd일').format(note.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.5),
                    ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '노트',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10.sp,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
