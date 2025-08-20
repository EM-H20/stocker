import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

/// 퀴즈 선택지 위젯
class QuizOptionWidget extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool hasAnswered;
  final int? userAnswer;
  final int correctAnswerIndex;
  final VoidCallback? onTap;

  const QuizOptionWidget({
    super.key,
    required this.option,
    required this.index,
    required this.isSelected,
    required this.hasAnswered,
    required this.userAnswer,
    required this.correctAnswerIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 색상 결정 로직
    Color backgroundColor;
    Color borderColor;
    Color circleColor;
    Widget? circleIcon;

    if (hasAnswered) {
      if (userAnswer == index) {
        // 사용자가 선택한 답
        if (userAnswer == correctAnswerIndex) {
          // 정답
          backgroundColor = AppTheme.successColor.withValues(alpha: 0.2);
          borderColor = AppTheme.successColor;
          circleColor = AppTheme.successColor;
          circleIcon = Icon(Icons.check, color: Colors.white, size: 16.sp);
        } else {
          // 오답
          backgroundColor = AppTheme.errorColor.withValues(alpha: 0.2);
          borderColor = AppTheme.errorColor;
          circleColor = AppTheme.errorColor;
          circleIcon = Icon(Icons.close, color: Colors.white, size: 16.sp);
        }
      } else if (index == correctAnswerIndex) {
        // 정답 표시
        backgroundColor = AppTheme.successColor.withValues(alpha: 0.2);
        borderColor = AppTheme.successColor;
        circleColor = AppTheme.successColor;
        circleIcon = Icon(Icons.check, color: Colors.white, size: 16.sp);
      } else {
        // 선택되지 않은 일반 옵션
        backgroundColor = isDarkMode ? AppTheme.darkSurface : Colors.white;
        borderColor = isDarkMode ? AppTheme.grey600 : AppTheme.grey400;
        circleColor = Colors.transparent;
        circleIcon = null;
      }
    } else {
      // 답변 전 상태
      if (isSelected) {
        backgroundColor = AppTheme.successColor.withValues(alpha: 0.2);
        borderColor = AppTheme.successColor;
        circleColor = AppTheme.successColor;
        circleIcon = Icon(Icons.check, color: Colors.white, size: 16.sp);
      } else {
        backgroundColor = isDarkMode ? AppTheme.darkSurface : Colors.white;
        borderColor = isDarkMode ? AppTheme.grey600 : AppTheme.grey400;
        circleColor = Colors.transparent;
        circleIcon = null;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: hasAnswered ? null : onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor, width: 2),
            boxShadow:
                isDarkMode || hasAnswered
                    ? null
                    : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Row(
            children: [
              // 선택 표시 원
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: circleIcon,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppTheme.grey900,
                    fontSize: 16.sp,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
