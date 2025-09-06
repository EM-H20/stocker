import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../domain/models/quiz_result.dart';

/// 퀴즈 결과 메인 카드 위젯
class QuizResultCardWidget extends StatelessWidget {
  final QuizResult result;
  final Animation<double> scoreAnimation;

  const QuizResultCardWidget({
    super.key,
    required this.result,
    required this.scoreAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: result.isPassed
              ? [
                  AppTheme.successColor.withValues(alpha: 0.2),
                  AppTheme.successColor.withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.errorColor.withValues(alpha: 0.2),
                  AppTheme.errorColor.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: result.isPassed ? AppTheme.successColor : AppTheme.errorColor,
          width: 2,
        ),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: (result.isPassed
                          ? AppTheme.successColor
                          : AppTheme.errorColor)
                      .withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // 합격/불합격 아이콘
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  result.isPassed ? AppTheme.successColor : AppTheme.errorColor,
            ),
            child: Icon(
              result.isPassed ? Icons.check : Icons.close,
              color: Colors.white,
              size: 40.sp,
            ),
          ),

          SizedBox(height: 16.h),

          // 합격/불합격 텍스트
          Text(
            result.isPassed ? '합격!' : '불합격',
            style: TextStyle(
              color:
                  result.isPassed ? AppTheme.successColor : AppTheme.errorColor,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),

          // 점수 애니메이션
          AnimatedBuilder(
            animation: scoreAnimation,
            builder: (context, child) {
              final animatedScore =
                  (result.scorePercentage * scoreAnimation.value).toInt();
              return Text(
                '$animatedScore점',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppTheme.grey900,
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),

          SizedBox(height: 4.h),

          // 등급
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _getGradeColor(result.grade).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: _getGradeColor(result.grade), width: 1),
            ),
            child: Text(
              '등급: ${result.grade}',
              style: TextStyle(
                color: _getGradeColor(result.grade),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return AppTheme.successColor;
      case 'B':
        return AppTheme.infoColor;
      case 'C':
        return AppTheme.warningColor;
      case 'D':
        return const Color(0xFFFF5722);
      case 'F':
        return AppTheme.errorColor;
      default:
        return AppTheme.grey500;
    }
  }
}
