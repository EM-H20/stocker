import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

/// 퀴즈 결과 에러 상태 위젯
class QuizResultErrorWidget extends StatelessWidget {
  final String message;

  const QuizResultErrorWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
          fontSize: 16.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
