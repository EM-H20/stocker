import 'package:dio/dio.dart';
import 'chapter_card_response.dart';
import 'theory_enter_request.dart';
import 'theory_enter_response.dart';
import 'theory_update_request.dart';
import 'theory_completed_request.dart';

/// Education 관련 API 통신 클래스
/// Dio를 사용하여 백엔드와 HTTP 통신을 담당
class EducationApi {
  final Dio _dio;
  static const String _baseUrl = '/api/education';

  EducationApi(this._dio);

  /// 챕터 목록 조회
  /// GET /api/education/chapters
  ///
  /// Returns: List ChapterCardResponse
  /// Throws: DioException on network error
  Future<List<ChapterCardResponse>> getChapters() async {
    try {
      final response = await _dio.get('$_baseUrl/chapters');

      // 성공 응답 확인
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map(
              (json) =>
                  ChapterCardResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '챕터 목록 조회 실패: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '$_baseUrl/chapters'),
        message: '챕터 목록 조회 중 예상치 못한 오류: $e',
      );
    }
  }

  /// 이론 진입
  /// POST /api/education/theory/enter
  ///
  /// [request]: 이론 진입 요청 데이터
  /// Returns: TheoryEnterResponse
  /// Throws: DioException on network error
  Future<TheoryEnterResponse> enterTheory(TheoryEnterRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/theory/enter',
        data: request.toJson(),
      );

      // 성공 응답 확인
      if (response.statusCode == 200) {
        return TheoryEnterResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '이론 진입 실패: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '$_baseUrl/theory/enter'),
        message: '이론 진입 중 예상치 못한 오류: $e',
      );
    }
  }

  /// 이론 진도 갱신
  /// PUT /api/education/theory/progress
  ///
  /// [request]: 이론 진도 갱신 요청 데이터
  /// Returns: void (성공 시 응답 없음)
  /// Throws: DioException on network error
  Future<void> updateTheoryProgress(TheoryUpdateRequest request) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/theory/progress',
        data: request.toJson(),
      );

      // 성공 응답 확인
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '이론 진도 갱신 실패: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '$_baseUrl/theory/progress'),
        message: '이론 진도 갱신 중 예상치 못한 오류: $e',
      );
    }
  }

  /// 이론 완료 처리
  /// POST /api/education/theory/complete
  ///
  /// [request]: 이론 완료 처리 요청 데이터
  /// Returns: void (성공 시 응답 없음)
  /// Throws: DioException on network error
  Future<void> completeTheory(TheoryCompletedRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/theory/complete',
        data: request.toJson(),
      );

      // 성공 응답 확인
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '이론 완료 처리 실패: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '$_baseUrl/theory/complete'),
        message: '이론 완료 처리 중 예상치 못한 오류: $e',
      );
    }
  }
}
