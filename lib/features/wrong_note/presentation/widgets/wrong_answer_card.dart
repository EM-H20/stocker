import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/core/widgets/action_button.dart';
import '../../../../app/config/app_theme.dart';
import '../../data/models/wrong_note_response.dart';

/// 개별 오답 카드 위젯
///
/// 틀린 문제의 상세 정보와 다시 풀기 기능을 제공하는 카드
class WrongAnswerCard extends StatelessWidget {
  final WrongNoteItem wrongNote;
  final VoidCallback onRetry;
  final VoidCallback? onRemove;

  const WrongAnswerCard({
    super.key, 
    required this.wrongNote, 
    required this.onRetry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12.r),
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
                  wrongNote.chapterTitle,
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
                  color:
                      wrongNote.isRetried
                          ? AppTheme.infoColor.withValues(alpha: 0.2)
                          : AppTheme.warningColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  wrongNote.isRetried ? '재시도 완료' : '미완료',
                  style: TextStyle(
                    color:
                        wrongNote.isRetried
                            ? AppTheme.infoColor
                            : AppTheme.warningColor,
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
              color: AppTheme.grey400,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            wrongNote.question,
            style: TextStyle(color: Colors.white, fontSize: 14.sp, height: 1.4),
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
                      '정답: ${wrongNote.correctAnswer}',
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
                      '내 답: ${wrongNote.userAnswer}',
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
              color: AppTheme.grey400,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            wrongNote.explanation,
            style: TextStyle(
              color: AppTheme.grey300,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          // 액션 버튼들
          Row(
            children: [
              Text(
                '${wrongNote.wrongDate.month}/${wrongNote.wrongDate.day}',
                style: TextStyle(color: AppTheme.grey500, fontSize: 12.sp),
              ),
              const Spacer(),
              if (!wrongNote.isRetried)
                ActionButton(
                  text: '다시 풀기',
                  icon: Icons.refresh,
                  color: AppTheme.successColor,
                  onPressed: onRetry,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
