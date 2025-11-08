import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/core/widgets/action_button.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/config/app_routes.dart';
import '../../data/models/wrong_note_response.dart';
import '../../../../app/core/widgets/app_card.dart';

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
    return AppCard(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      backgroundColor: theme.brightness == Brightness.dark
          ? AppTheme.darkSurface
          : Colors.grey[50],
      borderColor: theme.brightness == Brightness.dark
          ? AppTheme.grey600.withValues(alpha: 0.3)
          : AppTheme.grey300.withValues(alpha: 0.5),
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isRetried
                      ? AppTheme.successColor.withValues(alpha: 0.15)
                      : AppTheme.warningColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isRetried
                        ? AppTheme.successColor.withValues(alpha: 0.3)
                        : AppTheme.warningColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRetried
                          ? Icons.check_circle_outline
                          : Icons.schedule_outlined,
                      color: isRetried
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isRetried ? '복습 완료 ✨' : '복습 대기',
                      style: TextStyle(
                        color: isRetried
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 복습 모드 안내 텍스트
                  Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: AppTheme.infoColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 12.sp,
                          color: AppTheme.infoColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '복습 모드 - 삭제되지 않아요 📚',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.infoColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 기존 버튼
                  ActionButton(
                    text: isRetried ? '다시 복습하기' : '다시 풀기',
                    icon: isRetried ? Icons.replay_outlined : Icons.refresh,
                    color:
                        isRetried ? AppTheme.infoColor : AppTheme.successColor,
                    onPressed: () {
                      // 단일 퀴즈 모드로 해당 문제 재시도 (읽기 전용 모드)
                      context.go(
                          '${AppRoutes.quiz}?chapterId=${wrongNote.chapterId}&quizId=${wrongNote.quizId}&readOnly=true');
                    },
                  ),
                ],
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
    if (wrongNote.correctAnswerText != null &&
        wrongNote.correctAnswerText!.isNotEmpty) {
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
