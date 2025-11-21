import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/config/app_theme.dart';
import '../riverpod/attendance_notifier.dart';

/// 출석 달력을 표시하는 위젯
class AttendanceCalendar extends ConsumerWidget {
  const AttendanceCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceNotifierProvider);
    final attendanceStatus = attendanceState.attendanceStatus;

    return TableCalendar(
      locale: 'ko_KR', // 한글 로케일 설정
      focusedDay: DateTime.now(),
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      headerStyle: HeaderStyle(
        formatButtonVisible: false, // '2 weeks' 버튼 숨기기
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Theme.of(context).iconTheme.color,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      calendarStyle: CalendarStyle(
        // 오늘 날짜 스타일
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
        // 선택된 날짜 스타일
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        // 기본 텍스트 스타일들을 테마에 맞게 조정
        defaultTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        weekendTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        outsideTextStyle: TextStyle(
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withValues(alpha: 0.5),
        ),
        // 요일 헤더 스타일
        weekNumberTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        // 마커(출석 표시점) 스타일
        markerDecoration: BoxDecoration(
          color: AppTheme.successColor,
          shape: BoxShape.circle,
        ),
      ),
      // 월이 변경될 때마다 Riverpod를 통해 API 호출
      onPageChanged: (focusedDay) {
        ref
            .read(attendanceNotifierProvider.notifier)
            .fetchAttendanceStatus(focusedDay);
      },
      // 출석한 날에 이벤트 마커(점) 표시
      eventLoader: (day) {
        // 날짜의 시간/분/초를 무시하고 비교하기 위해 정규화
        final normalizedDay = DateTime.utc(day.year, day.month, day.day);
        if (attendanceStatus[normalizedDay] == true) {
          return ['present']; // 출석한 경우 이벤트 리스트 반환
        }
        return []; // 출석 안 한 경우 빈 리스트 반환
      },
    );
  }
}
