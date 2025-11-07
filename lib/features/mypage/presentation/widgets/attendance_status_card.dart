import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/config/app_routes.dart';
import '../../../attendance/presentation/provider/attendance_provider.dart';
import '../../../../app/core/utils/theme_utils.dart';

/// 출석현황 카드 위젯
class AttendanceStatusCard extends StatelessWidget {
  const AttendanceStatusCard({super.key});

  // 현재 주의 시작 날짜 계산 (월요일 기준)
  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // 주차 정보를 생성 (예: "1월 2째주")
  String _getWeekInfo(DateTime startOfWeek) {
    final month = startOfWeek.month;
    final weekOfMonth = ((startOfWeek.day - 1) / 7).floor() + 1;
    return '$month월 $weekOfMonth째주';
  }

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
                onTap: () => context.go(AppRoutes.attendance),
                child: Text(
                  '전체 보기',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeUtils.isDarkMode(context)
                            ? AppTheme.primaryColor.withValues(alpha: 0.8)
                            : AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Consumer<AttendanceProvider>(
            builder: (context, attendanceProvider, child) {
              final now = DateTime.now();
              final startOfWeek = _getStartOfWeek(now);
              final weekInfo = _getWeekInfo(startOfWeek);
              final attendanceStatus = attendanceProvider.attendanceStatus;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekInfo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                  ),
                  SizedBox(height: 16.h),
                  // 출석 현황 원형 표시
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (index) {
                      final currentDay = startOfWeek.add(Duration(days: index));
                      final dayKey = DateTime.utc(
                          currentDay.year, currentDay.month, currentDay.day);
                      final isAttended = attendanceStatus[dayKey] ?? false;
                      final isToday = _isSameDay(currentDay, now);
                      final isPastDay = currentDay
                          .isBefore(DateTime(now.year, now.month, now.day));

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
                                      : isPastDay
                                          ? Colors.red.withValues(alpha: 0.7)
                                          : Theme.of(context).disabledColor,
                            ),
                            child: Center(
                              child: Text(
                                '${currentDay.day}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: (isToday || isAttended || isPastDay)
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // 같은 날인지 확인하는 유틸리티 함수
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
