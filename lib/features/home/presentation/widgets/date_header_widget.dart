import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

/// 메인 대시보드 상단 날짜 헤더 위젯
class DateHeaderWidget extends StatelessWidget {
  const DateHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[now.weekday - 1];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 날짜 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weekday,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppTheme.grey900.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '${now.day}일',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.grey400
                      : AppTheme.grey600,
                ),
              ),
            ],
          ),
          
          // 로그인 버튼
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              '로그인',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}