import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

/// 출석현황 카드 위젯
class AttendanceStatusCard extends StatelessWidget {
  final VoidCallback? onViewAllPressed;

  const AttendanceStatusCard({
    super.key,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '이번주 출석현황',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onViewAllPressed,
                child: Text(
                  '전체 보기',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '8월 3째주',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 16.h),
          // 출석 현황 원형 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final dayNumbers = [10, 11, 12, 13, 14, 15, 16];
              final isAttended = index < 5; // 처음 5일은 출석한 것으로 표시
              final isToday = index == 6; // 마지막 날을 오늘로 설정
              
              return Column(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday 
                          ? Theme.of(context).primaryColor
                          : isAttended 
                              ? AppTheme.successColor 
                              : Theme.of(context).disabledColor,
                    ),
                    child: Center(
                      child: Text(
                        '${dayNumbers[index]}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: isToday || isAttended 
                              ? Colors.white 
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
