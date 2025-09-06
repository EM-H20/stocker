//더미 데이터 반환

import '../../domain/model/attendance_day.dart';
import '../../domain/model/attendance_quiz.dart';
import '../../domain/repository/attendance_repository.dart';
import '../dto/quiz_submission_dto.dart';

/// 테스트용 더미 데이터를 반환하는 Repository 구현체
class AttendanceMockRepository implements AttendanceRepository {
  @override
  Future<List<AttendanceDay>> getAttendanceStatus(DateTime month) async {
    // 0.3초 지연 후 더미 데이터 반환
    await Future.delayed(const Duration(milliseconds: 300));

    // 현재 월의 1일, 5일, 10일에 출석한 것으로 가정
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
    // 0.3초 지연 후 더미 퀴즈 3문제 반환
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      AttendanceQuiz(id: 1, question: '코스피는 대한민국을 대표하는 주가 지수이다.', answer: true),
      AttendanceQuiz(
          id: 2, question: '배당금은 주식을 보유만 해도 항상 지급된다.', answer: false),
      AttendanceQuiz(
          id: 3, question: '상한가, 하한가 제도는 모든 국가에 존재한다.', answer: false),
    ];
  }

  @override
  Future<void> submitAttendance(QuizSubmissionDto submission) async {
    // 0.5초 지연 후 성공한 것처럼 처리
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }
}
