import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/core/widgets/action_button.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/config/app_routes.dart';
import '../../data/models/wrong_note_response.dart';

/// 개별 오답 카드 위젯
///
/// 틀린 문제의 상세 정보와 다시 풀기 기능을 제공하는 카드
class WrongAnswerCard extends StatelessWidget {
  final WrongNoteItem wrongNote;
  final VoidCallback onRetry;
  final VoidCallback? onRemove;
  final bool isRetried; // 재시도 상태를 외부에서 받아옴

  const WrongAnswerCard({
    super.key,
    required this.wrongNote,
    required this.onRetry,
    required this.isRetried,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppTheme.darkSurface
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? AppTheme.grey600.withValues(alpha: 0.3)
              : AppTheme.grey300.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (챕터 정보 + 상태)
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  wrongNote.chapterTitle ?? '챕터 정보 없음',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isRetried
                      ? AppTheme.infoColor.withValues(alpha: 0.2)
                      : AppTheme.warningColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  isRetried ? '재시도 완료' : '미완료',
                  style: TextStyle(
                    color:
                        isRetried ? AppTheme.infoColor : AppTheme.warningColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 문제
          Text(
            '문제',
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? AppTheme.grey400
                  : AppTheme.grey600,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            wrongNote.question ?? '문제 정보 없음',
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.grey900,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),

          SizedBox(height: 12.h),

          // 정답 vs 내 답
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '정답',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '정답: ${_getCorrectAnswerText()}',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '내 답',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '내 답: ${wrongNote.selectedAnswerText}',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 해설
          Text(
            '해설',
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? AppTheme.grey400
                  : AppTheme.grey600,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            wrongNote.explanation ?? '해설 정보 없음',
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? AppTheme.grey300
                  : AppTheme.grey700,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          // 액션 버튼들
          Row(
            children: [
              Text(
                '${wrongNote.createdDate.month}/${wrongNote.createdDate.day}',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? AppTheme.grey500
                      : AppTheme.grey600,
                  fontSize: 12.sp,
                ),
              ),
              const Spacer(),
              if (!isRetried)
                ActionButton(
                  text: '다시 풀기',
                  icon: Icons.refresh,
                  color: AppTheme.successColor,
                  onPressed: () {
                    // 단일 퀴즈 모드로 해당 문제 재시도
                    context.go('${AppRoutes.quiz}?chapterId=${wrongNote.chapterId}&quizId=${wrongNote.quizId}');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 정답 텍스트 가져오기
  String _getCorrectAnswerText() {
    // correctAnswerText가 있으면 그것을 사용
    if (wrongNote.correctAnswerText != null && wrongNote.correctAnswerText!.isNotEmpty) {
      return wrongNote.correctAnswerText!;
    }
    
    // correctAnswerIndex와 options로 정답 텍스트 구성
    if (wrongNote.correctAnswerIndex != null && 
        wrongNote.options != null && 
        wrongNote.options!.isNotEmpty &&
        wrongNote.correctAnswerIndex! < wrongNote.options!.length) {
      final correctIndex = wrongNote.correctAnswerIndex!;
      return '${correctIndex + 1}번. ${wrongNote.options![correctIndex]}';
    }
    
    return '정답 정보 없음';
  }
}
