
// FILE: lib/features/note/presentation/widgets/template_picker_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/note_templates.dart';

/// 새 노트 작성 시 템플릿을 선택하는 다이얼로그
class TemplatePickerDialog extends StatelessWidget {
  const TemplatePickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 12.h),
        child: Row(
          children: [
            Icon(
              Icons.note_add_outlined,
              color: Theme.of(context).primaryColor,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              '노트 템플릿 선택',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 320.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              height: 1.h,
              thickness: 1.h,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 300.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: NoteTemplates.templates.length,
                itemBuilder: (context, index) {
                  final template = NoteTemplates.templates[index];
                  final isLast = index == NoteTemplates.templates.length - 1;
                  
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(template),
                      splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          border: !isLast ? Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                              width: 1.h,
                            ),
                          ) : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: _getTemplateColor(template.name, context),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                _getTemplateIcon(template.name),
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).textTheme.titleMedium?.color,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _getTemplateDescription(template.name),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12.sp,
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              '취소',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getTemplateColor(String templateName, BuildContext context) {
    switch (templateName) {
      case '빈 노트':
        return Theme.of(context).primaryColor;
      case '주식 분석 노트':
        return Colors.green;
      case '뉴스 스크랩':
        return Colors.orange;
      case '학습 노트':
        return Colors.blue;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  IconData _getTemplateIcon(String templateName) {
    switch (templateName) {
      case '빈 노트':
        return Icons.edit_outlined;
      case '주식 분석 노트':
        return Icons.trending_up;
      case '뉴스 스크랩':
        return Icons.article_outlined;
      case '학습 노트':
        return Icons.school_outlined;
      default:
        return Icons.note_outlined;
    }
  }

  String _getTemplateDescription(String templateName) {
    switch (templateName) {
      case '빈 노트':
        return '자유롭게 내용을 작성할 수 있어요';
      case '주식 분석 노트':
        return '종목별 분석과 투자 전략을 기록해보세요';
      case '뉴스 스크랩':
        return '중요한 뉴스와 소식을 정리해보세요';
      case '학습 노트':
        return '배운 내용을 체계적으로 정리해보세요';
      default:
        return '노트를 작성해보세요';
    }
  }
}