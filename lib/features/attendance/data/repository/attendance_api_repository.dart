// attendance_api_repository.dart 수정

import '../../domain/model/attendance_day.dart';
import '../../domain/model/attendance_quiz.dart';
import '../../domain/repository/attendance_repository.dart';
import '../source/attendance_api.dart';

/// 실제 API를 호출하여 출석 데이터를 가져오는 Repository 구현체
class AttendanceApiRepository implements AttendanceRepository {
  final AttendanceApi _api;
  AttendanceApiRepository(this._api);

  @override
  Future<List<AttendanceDay>> getAttendanceStatus(DateTime month) async {
    final dto = await _api.getAttendanceHistory();
    return dto.attendance;
  }

  @override
  Future<List<AttendanceQuiz>> getTodaysQuiz() async {
    final dto = await _api.startAttendanceQuiz();
    return dto.quizzes;
  }

  @override
  Future<void> submitAttendance(Map<String, dynamic> submissionData) async {
    // API 문서에 맞춰 { "isPresent": true } 형식으로 전송
    return _api.submitAttendance(submissionData);
  }
}
