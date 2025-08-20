import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../domain/models/quiz_result.dart';

/// 퀴즈 결과 상세 통계 위젯
class QuizResultStatsWidget extends StatelessWidget {
  final QuizResult result;

  const QuizResultStatsWidget({super.key, required this.result});

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
            '상세 통계',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppTheme.grey900,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16.h),

          _buildStatRow(context, '전체 문제', '${result.totalQuestions}문제'),
          _buildStatRow(
            context,
            '정답',
            '${result.correctAnswers}문제',
            AppTheme.successColor,
          ),
          _buildStatRow(
            context,
            '오답',
            '${result.wrongAnswers}문제',
            AppTheme.errorColor,
          ),
          _buildStatRow(
            context,
            '정답률',
            '${(result.accuracyRate * 100).toInt()}%',
          ),
          _buildStatRow(context, '소요 시간', result.formattedTimeSpent),
          _buildStatRow(
            context,
            '완료 시간',
            '${result.completedAt.month}/${result.completedAt.day} '
                '${result.completedAt.hour.toString().padLeft(2, '0')}:'
                '${result.completedAt.minute.toString().padLeft(2, '0')}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value, [
    Color? valueColor,
  ]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
              fontSize: 14.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color:
                  valueColor ?? (isDarkMode ? Colors.white : AppTheme.grey900),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
