import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../provider/attendance_provider.dart';

/// 출석 달력을 표시하는 위젯
class AttendanceCalendar extends StatelessWidget {
  const AttendanceCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final attendanceStatus = provider.attendanceStatus;

    return TableCalendar(
      locale: 'ko_KR', // 한글 로케일 설정
      focusedDay: DateTime.now(),
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false, // '2 weeks' 버튼 숨기기
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      calendarStyle: CalendarStyle(
        // 오늘 날짜 스타일
        todayDecoration: BoxDecoration(
          color: Colors.blue.shade200,
          shape: BoxShape.circle,
        ),
        // 선택된 날짜 스타일
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      // 월이 변경될 때마다 Provider를 통해 API 호출
      onPageChanged: (focusedDay) {
        provider.fetchAttendanceStatus(focusedDay);
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