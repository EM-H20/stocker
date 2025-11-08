import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/model/attendance_quiz.dart';

part 'attendance_state.freezed.dart';

/// 🔥 Riverpod 출석 상태 클래스 (Freezed)
@freezed
class AttendanceState with _$AttendanceState {
  const factory AttendanceState({
    /// 출석 현황 (날짜 → 출석 여부 매핑)
    @Default({}) Map<DateTime, bool> attendanceStatus,

    /// 오늘의 퀴즈 목록
    @Default([]) List<AttendanceQuiz> quizzes,

    /// 현재 포커스된 월
    required DateTime focusedMonth,

    /// 출석 현황 로딩 중
    @Default(false) bool isLoading,

    /// 퀴즈 로딩 중
    @Default(false) bool isQuizLoading,

    /// 퀴즈 제출 중
    @Default(false) bool isSubmitting,

    /// 에러 메시지
    String? errorMessage,
  }) = _AttendanceState;

  const AttendanceState._();

  /// 특정 날짜의 출석 여부 확인
  bool isAttendedOn(DateTime date) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return attendanceStatus[utcDate] ?? false;
  }

  /// 현재 월의 출석 일수
  int get attendanceDaysInMonth {
    return attendanceStatus.entries
        .where((entry) =>
            entry.key.year == focusedMonth.year &&
            entry.key.month == focusedMonth.month &&
            entry.value == true)
        .length;
  }
}
