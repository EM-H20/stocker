// features/attendance/domain/model/attendance_day.dart
/// 하루의 출석 정보를 나타내는 모델
class AttendanceDay {
  final DateTime date; // 날짜
  final bool isPresent; // 출석 여부

  AttendanceDay({
    required this.date,
    required this.isPresent,
  });
}
