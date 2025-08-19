//실제 API 호출

import '../../domain/model/attendance_day.dart';
import '../../domain/model/attendance_quiz.dart';
import '../../domain/repository/attendance_repository.dart';
import '../dto/quiz_submission_dto.dart';
import '../source/attendance_api.dart';

/// 실제 API를 호출하여 출석 데이터를 가져오는 Repository 구현체
class AttendanceApiRepository implements AttendanceRepository {
  final AttendanceApi _api;
  AttendanceApiRepository(this._api);

  @override
  Future<List<AttendanceDay>> getAttendanceStatus(DateTime month) async {
    final dto = await _api.getAttendanceStatus(month);
    // DTO를 도메인 모델 리스트로 변환하여 반환
    return dto.attendance;
  }

  @override
  Future<List<AttendanceQuiz>> getTodaysQuiz() async {
    final dto = await _api.getTodaysQuiz();
    // DTO를 도메인 모델 리스트로 변환하여 반환
    return dto.quizzes;
  }

  @override
  Future<void> submitAttendance(QuizSubmissionDto submission) async {
    return _api.submitAttendance(submission);
  }
}
