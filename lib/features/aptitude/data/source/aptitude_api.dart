// features/aptitude/data/source/aptitude_api.dart
import 'package:dio/dio.dart';
import '../dto/aptitude_question_dto.dart';
import '../dto/aptitude_result_dto.dart';
import '../dto/aptitude_answer_request.dart';
import '../dto/aptitude_type_summary_dto.dart';

/// 성향 분석 관련 API를 호출하는 클래스
class AptitudeApi {
  final Dio _dio;
  AptitudeApi(this._dio);

  // 0. 검사지 제공
  Future<List<AptitudeQuestionDto>> getQuestionnaire() async {
    final response = await _dio.get('/api/aptitude-test/test');
    // API 응답이 리스트 형태라고 가정
    final List<dynamic> data = response.data as List<dynamic>? ?? [];
    return data.map((json) => AptitudeQuestionDto.fromJson(json)).toList();
  }

  // 1. 결과 저장 (최초)
  Future<AptitudeResultDto> saveResult(AptitudeAnswerRequest request) async {
    final response = await _dio.post(
      '/api/aptitude-test/result',
      data: request.toJson(),
    );
    return AptitudeResultDto.fromJson(response.data);
  }

  // 2. 결과 조회
  Future<AptitudeResultDto> getResult() async {
    final response = await _dio.get('/api/aptitude-test/result');
    return AptitudeResultDto.fromJson(response.data);
  }

  // 3. 재검사 갱신
  Future<AptitudeResultDto> retestAndUpdate(AptitudeAnswerRequest request) async {
    final response = await _dio.put(
      '/api/aptitude-test/result',
      data: request.toJson(),
    );
    return AptitudeResultDto.fromJson(response.data);
  }

  // ✅ [추가] 4. 모든 거장(성향) 목록 조회
  Future<List<AptitudeTypeSummaryDto>> listAllMasters() async {
    final response = await _dio.get('/api/aptitude-test/masters');
    final List<dynamic> data = response.data as List<dynamic>? ?? [];
    return data.map((json) => AptitudeTypeSummaryDto.fromJson(json)).toList();
  }

  // ✅ [추가] 특정 타입의 상세 결과 조회 API (가정)
  Future<AptitudeResultDto> getResultByType(String typeCode) async {
    // 백엔드에 이런 API가 있다고 가정합니다. (예: /api/aptitude-test/results/details/AGGRESSIVE)
    final response = await _dio.get('/api/aptitude-test/results/details/$typeCode');
    return AptitudeResultDto.fromJson(response.data);
  }
}
