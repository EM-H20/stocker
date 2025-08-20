import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

/// 퀴즈 진행률 표시 위젯
class QuizProgressWidget extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final double progressRatio;

  const QuizProgressWidget({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.progressRatio,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      color: isDarkMode 
          ? AppTheme.darkSurface 
          : AppTheme.grey100,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '문제 ${currentIndex + 1} / $totalCount',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppTheme.grey900,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progressRatio * 100).toInt()}% 완료',
                style: TextStyle(
                  color: AppTheme.successColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: progressRatio,
            backgroundColor: isDarkMode 
                ? AppTheme.grey800 
                : AppTheme.grey300,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }
}
