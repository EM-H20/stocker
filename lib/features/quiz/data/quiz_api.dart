import 'package:dio/dio.dart';
import '../domain/models/quiz_session.dart';
import '../domain/models/quiz_result.dart';
import '../../../app/core/services/token_storage.dart';

/// 퀴즈 API 클라이언트 (API.md 스펙 준수)
/// 백엔드와의 HTTP 통신을 담당
class QuizApi {
  final Dio _dio;

  QuizApi(this._dio);

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

  /// 퀴즈 진입 API.md 스펙: POST /api/quiz/enter
  ///
  /// [chapterId]: 시작할 챕터 ID
  /// Returns: QuizSession (퀴즈 목록 및 현재 상태)
  /// Throws: DioException on HTTP error
  Future<QuizSession> enterQuiz(int chapterId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '/api/quiz/enter',
        data: {'chapter_id': chapterId}, // API.md 스펙: chapter_id
        options: options,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return QuizSession.fromJson(data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '퀴즈 진입 실패: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: '/api/quiz/enter'),
        message: '퀴즈 진입 중 오류 발생: $e',
      );
    }
  }

  /// 퀴즈 진도 업데이트 API.md 스펙: PATCH /api/quiz/progress
  ///
  /// [chapterId]: 챕터 ID
  /// [currentQuizId]: 현재 퀴즈 ID
  /// Throws: DioException on HTTP error
  Future<void> updateQuizProgress(
    int chapterId,
    int currentQuizId,
  ) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.patch(
        '/api/quiz/progress',
        data: {
          'chapter_id': chapterId, // API.md 스펙: chapter_id
          'current_quiz_id': currentQuizId, // API.md 스펙: current_quiz_id
        },
        options: options,
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '퀴즈 진도 업데이트 실패: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: '/api/quiz/progress'),
        message: '퀴즈 진도 업데이트 중 오류 발생: $e',
      );
    }
  }

  /// 퀴즈 완료 처리 API.md 스펙: POST /api/quiz/complete
  ///
  /// [chapterId]: 챕터 ID
  /// [answers]: 답안 목록 [{"quiz_id": 1, "selected_option": 2}, ...]
  /// Returns: QuizResult (점수 결과)
  /// Throws: DioException on HTTP error
  Future<QuizResult> completeQuiz(
    int chapterId,
    List<Map<String, int>> answers,
  ) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '/api/quiz/complete',
        data: {
          'chapter_id': chapterId, // Quiz complete는 chapter_id를 사용
          'answers': answers,
        },
        options: options,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return QuizResult.fromBackendJson(
            data as Map<String, dynamic>, chapterId);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '퀴즈 완료 처리 실패: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: '/api/quiz/complete'),
        message: '퀴즈 완료 처리 중 오류 발생: $e',
      );
    }
  }
}
