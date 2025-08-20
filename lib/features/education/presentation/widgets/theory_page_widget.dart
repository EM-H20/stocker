import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../domain/models/theory_info.dart';

/// 이론 페이지 위젯 - 개별 이론 내용을 표시
class TheoryPageWidget extends StatelessWidget {
  final TheoryInfo theory;
  final int pageIndex;

  const TheoryPageWidget({
    super.key,
    required this.theory,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppTheme.darkSurface 
            : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: isDarkMode 
            ? null 
            : Border.all(color: AppTheme.grey200),
        boxShadow: isDarkMode 
            ? null 
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 페이지 번호
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '페이지 ${pageIndex + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // 이론 제목
            if (theory.word.isNotEmpty) ...[
              Text(
                theory.word,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppTheme.grey900,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // 이론 내용
            Text(
              theory.content,
              style: TextStyle(
                color: isDarkMode ? AppTheme.grey300 : AppTheme.grey700,
                fontSize: 16.sp,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
