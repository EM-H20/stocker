import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../note/domain/model/note.dart';
import '../../../note/presentation/provider/note_provider.dart';
import '../../../../app/config/app_routes.dart';
import '../../../../app/config/app_theme.dart';

/// 노트 섹션 위젯 - 실제 Note 기능과 연결됨
class NoteSection extends StatelessWidget {
  const NoteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          // 최대 3개까지만 표시
          final displayNotes = noteProvider.notes.take(3).toList();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '노트',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (noteProvider.notes.length > 3)
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.noteList),
                          child: Text(
                            '더보기',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      if (noteProvider.notes.length > 3)
                        SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.noteEditor),
                        child: Icon(
                          Icons.add,
                          size: 24.sp,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.primaryColor.withValues(alpha: 0.85)
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (noteProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (displayNotes.isEmpty)
                _buildEmptyState(context)
              else
                ...displayNotes.map((note) => _buildNoteItem(context, note)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, Note note) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.noteEditor, extra: note),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _generatePreview(note.content),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 48.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          Text(
            '아직 작성된 노트가 없어요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () => context.go(AppRoutes.noteEditor),
            child: Text('첫 노트 만들기'),
          ),
        ],
      ),
    );
  }

  /// content에서 미리보기 텍스트 생성 (Quill Delta JSON에서 텍스트 추출)
  String _generatePreview(String content) {
    try {
      // 빈 내용인 경우
      if (content.isEmpty) return '내용 없음';
      
      // Quill Delta JSON 파싱 시도
      if (content.startsWith('{') && content.contains('ops')) {
        try {
          // JSON 파싱해서 텍스트만 추출
          final jsonData = content.replaceAll(RegExp(r'\s+'), ' ').trim();
          
          // 간단한 정규식으로 "insert" 값들 추출
          final insertMatches = RegExp(r'"insert":\s*"([^"]*)"').allMatches(jsonData);
          final textParts = insertMatches.map((match) => match.group(1) ?? '').toList();
          
          if (textParts.isNotEmpty) {
            final plainText = textParts.join(' ').trim();
            if (plainText.isNotEmpty) {
              return plainText.length > 100 ? '${plainText.substring(0, 100)}...' : plainText;
            }
          }
        } catch (e) {
          // JSON 파싱 실패시 fallback
        }
      }
      
      // 일반 텍스트로 처리 (fallback)
      final plainText = content.replaceAll(RegExp(r'[{}"\\]'), '').trim();
      if (plainText.isEmpty) return '내용 없음';
      
      return plainText.length > 100 ? '${plainText.substring(0, 100)}...' : plainText;
    } catch (e) {
      return '미리보기 생성 실패';
    }
  }
}
