import 'package:dio/dio.dart';
import '../domain/models/quiz_session.dart';
import '../domain/models/quiz_result.dart';

/// 퀴즈 API 클라이언트
/// 서버와의 HTTP 통신을 담당
class QuizApi {
  final Dio _dio;

  QuizApi(this._dio);

  /// 퀴즈 시작
  ///
  /// [chapterId]: 시작할 챕터 ID
  /// Returns: QuizSession
  /// Throws: DioException on HTTP error
  Future<QuizSession> startQuiz(int chapterId) async {
    try {
      final response = await _dio.post(
        '/api/quiz/start',
        data: {'chapterId': chapterId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return QuizSession.fromJson(data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '퀴즈 시작 실패: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: '/api/quiz/start'),
        message: '퀴즈 시작 중 오류 발생: $e',
      );
    }
  }

  /// 답안 제출
  ///
  /// [chapterId]: 챕터 ID
  /// [quizIndex]: 퀴즈 인덱스
  /// [selectedAnswer]: 선택한 답안 인덱스
  /// Throws: DioException on HTTP error
  Future<void> submitAnswer(
    int chapterId,
    int quizIndex,
    int selectedAnswer,
  ) async {
    try {
      final response = await _dio.post(
        '/api/quiz/submit-answer',
        data: {
          'chapterId': chapterId,
          'quizIndex': quizIndex,
          'selectedAnswer': selectedAnswer,
        },
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '답안 제출 실패: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: '/api/quiz/submit-answer'),
        message: '답안 제출 중 오류 발생: $e',
      );
    }
  }

  /// 퀴즈 완료
  ///
  /// [chapterId]: 챕터 ID
  /// [timeSpentSeconds]: 소요 시간 (초)
  /// Returns: QuizResult
  /// Throws: DioException on HTTP error
  Future<QuizResult> completeQuiz(int chapterId, int timeSpentSeconds) async {
    try {
      final response = await _dio.post(
        '/api/quiz/complete',
        data: {'chapterId': chapterId, 'timeSpentSeconds': timeSpentSeconds},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return QuizResult.fromJson(data as Map<String, dynamic>);
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

  /// 퀴즈 결과 조회
  ///
  /// [chapterId]: 조회할 챕터 ID
  /// Returns: List QuizResult
  /// Throws: DioException on HTTP error
  Future<List<QuizResult>> getQuizResults(int chapterId) async {
    try {
      final response = await _dio.get(
        '/api/quiz/results',
        queryParameters: {'chapterId': chapterId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .map((item) => QuizResult.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '퀴즈 결과 조회 실패: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: '/api/quiz/results'),
        message: '퀴즈 결과 조회 중 오류 발생: $e',
      );
    }
  }

  /// 현재 진행 중인 퀴즈 세션 조회
  ///
  /// Returns: QuizSession? (null이면 진행 중인 퀴즈 없음)
  /// Throws: DioException on HTTP error
  Future<QuizSession?> getCurrentQuizSession() async {
    try {
      final response = await _dio.get('/api/quiz/current-session');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null) return null;

        return QuizSession.fromJson(data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        // 진행 중인 세션 없음
        return null;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '현재 퀴즈 세션 조회 실패: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: '/api/quiz/current-session'),
        message: '현재 퀴즈 세션 조회 중 오류 발생: $e',
      );
    }
  }
}
