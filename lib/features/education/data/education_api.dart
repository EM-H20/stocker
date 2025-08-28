import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint('🚀 [EDU_API] 챕터 목록 조회 시작');
    debugPrint('📍 [EDU_API] URL: ${_dio.options.baseUrl}$_baseUrl/chapters');
    
    try {
      final response = await _dio.get('$_baseUrl/chapters');
      debugPrint('✅ [EDU_API] 챕터 목록 조회 성공 - Status: ${response.statusCode}');

      // 성공 응답 확인
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        debugPrint('📊 [EDU_API] 챕터 데이터 파싱 중 - 총 ${data.length}개 챕터');
        final chapters = data
            .map(
              (json) =>
                  ChapterCardResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        debugPrint('🎯 [EDU_API] 챕터 목록 조회 완료');
        return chapters;
      } else {
        debugPrint('❌ [EDU_API] 챕터 목록 조회 실패 - Status: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '챕터 목록 조회 실패: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('🚨 [EDU_API] DioException 발생: ${e.message}');
      debugPrint('🚨 [EDU_API] Error Type: ${e.type}');
      if (e.response != null) {
        debugPrint('🚨 [EDU_API] Response Status: ${e.response!.statusCode}');
        debugPrint('🚨 [EDU_API] Response Data: ${e.response!.data}');
      }
      rethrow;
    } catch (e) {
      debugPrint('💥 [EDU_API] 예상치 못한 오류: $e');
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
    debugPrint('🚀 [EDU_API] 이론 진입 시작 - ChapterId: ${request.chapterId}');
    debugPrint('📍 [EDU_API] URL: ${_dio.options.baseUrl}$_baseUrl/theory/enter');
    debugPrint('📦 [EDU_API] Request Data: ${request.toJson()}');
    
    try {
      final response = await _dio.post(
        '$_baseUrl/theory/enter',
        data: request.toJson(),
      );
      debugPrint('✅ [EDU_API] 이론 진입 성공 - Status: ${response.statusCode}');

      // 성공 응답 확인
      if (response.statusCode == 200) {
        debugPrint('🎯 [EDU_API] 이론 진입 완료');
        return TheoryEnterResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        debugPrint('❌ [EDU_API] 이론 진입 실패 - Status: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '이론 진입 실패: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('🚨 [EDU_API] 이론 진입 DioException: ${e.message}');
      debugPrint('🚨 [EDU_API] Error Type: ${e.type}');
      rethrow;
    } catch (e) {
      debugPrint('💥 [EDU_API] 이론 진입 예상치 못한 오류: $e');
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
