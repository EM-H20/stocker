// features/aptitude/data/source/aptitude_api.dart
import 'package:dio/dio.dart';
import '../dto/aptitude_question_dto.dart';
import '../dto/aptitude_result_dto.dart';
import '../dto/aptitude_answer_request.dart';
import '../dto/aptitude_type_summary_dto.dart';
import '../../../../app/core/services/token_storage.dart';

/// 성향 분석 관련 API를 호출하는 클래스
class AptitudeApi {
  final Dio _dio;
  AptitudeApi(this._dio);

  /// 인증 헤더를 추가하는 헬퍼 메서드
  /// InvestmentProfileApi와 동일한 패턴 사용
  Future<Options> _getAuthOptions() async {
    final access = await TokenStorage.accessToken;
    final refresh = await TokenStorage.refreshToken;

    return Options(headers: {
      if (access != null && access.isNotEmpty) 'Authorization': 'Bearer $access',
      if (refresh != null && refresh.isNotEmpty) 'x-refresh-token': refresh,
    });
  }

  // 0. 검사지 제공
  Future<List<AptitudeQuestionDto>> getQuestionnaire() async {
    final options = await _getAuthOptions();
    final response = await _dio.get(
      '/api/investment_profile/test',
      options: options,
    ); // ✅ 백엔드 라우트와 일치 + 인증 헤더 추가

    // 백엔드 실제 응답: { version, questions: [...] }
    final responseData = response.data as Map<String, dynamic>;
    final List<dynamic> questionsData =
        responseData['questions'] as List<dynamic>? ?? [];

    return questionsData
        .map((json) => AptitudeQuestionDto.fromJson(json))
        .toList();
  }

  // 1. 결과 저장 (최초)
  Future<AptitudeResultDto> saveResult(AptitudeAnswerRequest request) async {
    final options = await _getAuthOptions();
    final response = await _dio.post(
      '/api/investment_profile/result', // ✅ 백엔드 라우트와 일치 + 인증 헤더 추가
      data: request.toJson(),
      options: options,
    );
    return AptitudeResultDto.fromJson(response.data);
  }

  // 2. 결과 조회
  Future<AptitudeResultDto> getResult() async {
    final options = await _getAuthOptions();
    final response = await _dio.get(
      '/api/investment_profile/result',
      options: options,
    ); // ✅ 백엔드 라우트와 일치 + 인증 헤더 추가
    return AptitudeResultDto.fromJson(response.data);
  }

  // 3. 재검사 갱신
  Future<AptitudeResultDto> retestAndUpdate(
      AptitudeAnswerRequest request) async {
    final options = await _getAuthOptions();
    final response = await _dio.put(
      '/api/investment_profile/result', // ✅ 백엔드 라우트와 일치 + 인증 헤더 추가
      data: request.toJson(),
      options: options,
    );
    return AptitudeResultDto.fromJson(response.data);
  }

  // ✅ [추가] 4. 모든 거장(성향) 목록 조회
  Future<List<AptitudeTypeSummaryDto>> listAllMasters() async {
    final options = await _getAuthOptions();
    final response = await _dio.get(
      '/api/investment_profile/masters',
      options: options,
    ); // ✅ 백엔드 라우트와 일치 + 인증 헤더 추가
    final List<dynamic> data = response.data as List<dynamic>? ?? [];
    return data.map((json) => AptitudeTypeSummaryDto.fromJson(json)).toList();
  }

  // ✅ [추가] 특정 타입의 상세 결과 조회 API (가정)
  Future<AptitudeResultDto> getResultByType(String typeCode) async {
    final options = await _getAuthOptions();
    // 백엔드에 이런 API가 있다고 가정합니다. (예: /api/aptitude-test/results/details/AGGRESSIVE)
    final response = await _dio.get(
      '/api/aptitude-test/results/details/$typeCode',
      options: options,
    ); // 인증 헤더 추가
    return AptitudeResultDto.fromJson(response.data);
  }
}
