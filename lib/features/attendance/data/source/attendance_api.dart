// attendance_api.dart 수정

import 'package:dio/dio.dart';
import '../dto/attendance_status_dto.dart';
import '../dto/quiz_dto.dart';
import '../../../../app/core/services/token_storage.dart';

/// 출석 관련 API를 호출하는 클래스
class AttendanceApi {
  final Dio _dio;
  AttendanceApi(this._dio);

  /// 인증 헤더를 추가하는 헬퍼 메서드
  Future<Options> _getAuthOptions() async {
    final access = await TokenStorage.accessToken;
    final refresh = await TokenStorage.refreshToken;

    return Options(headers: {
      if (access != null && access.isNotEmpty)
        'Authorization': 'Bearer $access',
      if (refresh != null && refresh.isNotEmpty) 'x-refresh-token': refresh,
    });
  }

  /// 당월 출석 이력 조회 API
  Future<AttendanceStatusDto> getAttendanceHistory() async {
    final options = await _getAuthOptions();
    final response = await _dio.get(
      '/api/attendance/history',
      options: options,
    );
    return AttendanceStatusDto.fromJson(response.data);
  }

  /// 출석 퀴즈 시작 (랜덤 3문제)
  Future<QuizDto> startAttendanceQuiz() async {
    final options = await _getAuthOptions();
    final response = await _dio.get(
      '/api/attendance/quiz/start',
      options: options,
    );
    return QuizDto.fromJson(response.data);
  }

  /// 출석 제출 API (API 문서에 맞춘 형식)
  Future<void> submitAttendance(Map<String, dynamic> submissionData) async {
    final options = await _getAuthOptions();
    await _dio.post(
      '/api/attendance/quiz/submit',
      data: submissionData, // { "isPresent": true } 형식
      options: options,
    );
  }
}