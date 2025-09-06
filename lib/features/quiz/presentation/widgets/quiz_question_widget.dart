import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

/// 퀴즈 문제 표시 위젯
class QuizQuestionWidget extends StatelessWidget {
  final String question;

  const QuizQuestionWidget({super.key, required this.question});

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
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        question,
        style: TextStyle(
          color: isDarkMode ? Colors.white : AppTheme.grey900,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
    );
  }
}
