//# 출석 관련 API 호출 (Dio 사용)

import 'package:dio/dio.dart';
import '../dto/attendance_status_dto.dart';
import '../dto/quiz_dto.dart';
import '../dto/quiz_submission_dto.dart';
import 'package:intl/intl.dart';

/// 출석 관련 API를 호출하는 클래스
class AttendanceApi {
  final Dio _dio;
  AttendanceApi(this._dio);

  /// 월별 출석 현황 조회 API
  Future<AttendanceStatusDto> getAttendanceStatus(DateTime month) async {
    // 날짜를 'yyyy-MM' 형식의 문자열로 변환
    final String monthString = DateFormat('yyyy-MM').format(month);
    
    final response = await _dio.get(
      '/api/attendance/calendar',
      queryParameters: {'month': monthString},
    );
    return AttendanceStatusDto.fromJson(response.data);
  }

  /// 오늘의 출석 퀴즈 조회 API
  Future<QuizDto> getTodaysQuiz() async {
    final response = await _dio.get('/api/attendance/quiz');
    return QuizDto.fromJson(response.data);
  }

  /// 출석 퀴즈 제출 API
  Future<void> submitAttendance(QuizSubmissionDto submission) async {
    await _dio.post(
      '/api/attendance/submit',
      data: submission.toJson(),
    );
  }
}