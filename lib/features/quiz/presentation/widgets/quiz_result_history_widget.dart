import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../domain/models/quiz_result.dart';

/// 퀴즈 결과 이전 기록 위젯
class QuizResultHistoryWidget extends StatelessWidget {
  final List<QuizResult> previousResults;

  const QuizResultHistoryWidget({super.key, required this.previousResults});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: isDarkMode ? null : Border.all(color: AppTheme.grey200),
        boxShadow:
            isDarkMode
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이전 결과',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppTheme.grey900,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16.h),

          ...previousResults
              .take(5)
              .map((result) => _buildHistoryItem(context, result)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, QuizResult result) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.grey800 : AppTheme.grey50,
        borderRadius: BorderRadius.circular(8.r),
        border: isDarkMode ? null : Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result.completedAt.month}/${result.completedAt.day} '
                '${result.completedAt.hour.toString().padLeft(2, '0')}:'
                '${result.completedAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${result.correctAnswers}/${result.totalQuestions} 정답',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppTheme.grey900,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${result.scorePercentage}점',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppTheme.grey900,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color:
                      result.isPassed
                          ? AppTheme.successColor.withValues(alpha: 0.2)
                          : AppTheme.errorColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  result.isPassed ? '합격' : '불합격',
                  style: TextStyle(
                    color:
                        result.isPassed
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
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
