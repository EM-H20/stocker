// attendance_mock_repository.dart 수정

import '../../domain/model/attendance_day.dart';
import '../../domain/model/attendance_quiz.dart';
import '../../domain/repository/attendance_repository.dart';

/// 테스트용 더미 데이터를 반환하는 Repository 구현체
class AttendanceMockRepository implements AttendanceRepository {
  @override
  Future<List<AttendanceDay>> getAttendanceStatus(DateTime month) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      AttendanceDay(
          date: DateTime(month.year, month.month, 1), isPresent: true),
      AttendanceDay(
          date: DateTime(month.year, month.month, 5), isPresent: true),
      AttendanceDay(
          date: DateTime(month.year, month.month, 10), isPresent: true),
    ];
  }

  @override
  Future<List<AttendanceQuiz>> getTodaysQuiz() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      AttendanceQuiz(
          id: 1, question: '주식 투자에서 분산투자는 위험을 줄이는 효과적인 방법이다.', answer: true),
      AttendanceQuiz(
          id: 2, question: 'ETF는 개별 주식보다 항상 더 안전한 투자 방법이다.', answer: false),
      AttendanceQuiz(
          id: 3,
          question: '투자할 때는 모든 자금을 한 번에 투입하기보다는 시간을 나누어 투자하는 것이 좋다.',
          answer: true),
    ];
  }

  @override
  Future<void> submitAttendance(Map<String, dynamic> submissionData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock에서는 성공한 것으로 처리
    return;
  }
}
