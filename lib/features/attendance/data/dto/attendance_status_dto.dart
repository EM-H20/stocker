// # (서버 수신용) 월별 출석 현황 DTO

import '../../domain/model/attendance_day.dart';

/// 서버로부터 월별 출석 현황을 수신하는 DTO
class AttendanceStatusDto {
  final List<AttendanceDay> attendance;

  AttendanceStatusDto({required this.attendance});

  // API 응답 JSON을 파싱하여 DTO 객체로 변환
  factory AttendanceStatusDto.fromJson(Map<String, dynamic> json) {
    // API.md 명세: 'history' 키가 리스트 형태인지 확인
    final List<dynamic> attendanceList = json['history'] as List<dynamic>? ?? [];
    
    return AttendanceStatusDto(
      attendance: attendanceList.map((item) {
        // 각 항목이 Map 형태인지 확인
        final mapItem = item as Map<String, dynamic>? ?? {};
        return AttendanceDay(
          // 날짜 문자열을 DateTime 객체로 변환
          date: DateTime.parse(mapItem['date'] as String? ?? ''),
          isPresent: mapItem['is_present'] as bool? ?? false,
        );
      }).toList(),
    );
  }
}