// attendance_repository.dart 수정

import '../model/attendance_day.dart';
import '../model/attendance_quiz.dart';

/// 출석 관련 데이터 처리를 위한 Repository 추상 클래스
abstract class AttendanceRepository {
  /// 특정 월의 출석 현황을 가져옵니다.
  Future<List<AttendanceDay>> getAttendanceStatus(DateTime month);

  /// 오늘의 출석 퀴즈 목록을 가져옵니다.
  Future<List<AttendanceQuiz>> getTodaysQuiz();

  /// 출석을 제출합니다. (API 문서에 맞춘 형식)
  Future<void> submitAttendance(Map<String, dynamic> submissionData);
}