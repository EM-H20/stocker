import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/action_button.dart';

/// 퀴즈 에러 상태 위젯
class QuizErrorWidget extends StatelessWidget {
  final String title;
  final String errorMessage;
  final VoidCallback? onRetry;

  const QuizErrorWidget({
    super.key,
    required this.title,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 64.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppTheme.grey900,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            errorMessage,
            style: TextStyle(
              color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 24.h),
            ActionButton(
              text: '다시 시도',
              icon: Icons.refresh,
              color: AppTheme.successColor,
              onPressed: onRetry!,
            ),
          ],
        ],
      ),
    );
  }
}
