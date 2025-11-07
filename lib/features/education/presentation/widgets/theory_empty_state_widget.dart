import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/utils/theme_utils.dart';

/// 이론 데이터가 없을 때 표시되는 빈 상태 위젯
class TheoryEmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const TheoryEmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.book_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeUtils.isDarkMode(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.sp,
            color: isDarkMode ? AppTheme.grey600 : AppTheme.grey400,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
