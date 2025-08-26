import 'package:dio/dio.dart';
import 'models/wrong_note_request.dart';
import 'models/wrong_note_response.dart';

/// 오답노트 API 클라이언트
class WrongNoteApi {
  final Dio _dio;

  WrongNoteApi(this._dio);

  /// 사용자의 오답노트 목록 조회
  Future<WrongNoteResponse> getWrongNotes(String userId) async {
    try {
      final response = await _dio.get(
        '/api/wrong-notes',
        queryParameters: {'user_id': userId},
      );

      return WrongNoteResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('오답노트 조회 실패: $e');
    }
  }

  /// 퀴즈 결과를 서버에 제출하여 오답노트 업데이트
  Future<void> submitQuizResults(WrongNoteRequest request) async {
    try {
      await _dio.post('/api/wrong-notes/submit', data: request.toJson());
    } catch (e) {
      throw Exception('퀴즈 결과 제출 실패: $e');
    }
  }

  /// 특정 오답 문제 재시도 표시
  Future<void> markAsRetried(String userId, int quizId) async {
    try {
      await _dio.patch(
        '/api/wrong-notes/$quizId/retry',
        data: {'user_id': userId},
      );
    } catch (e) {
      throw Exception('재시도 표시 실패: $e');
    }
  }

  /// 오답노트에서 문제 삭제 (정답 처리 시)
  Future<void> removeWrongNote(String userId, int quizId) async {
    try {
      await _dio.delete('/api/wrong-notes/$quizId', data: {'user_id': userId});
    } catch (e) {
      throw Exception('오답노트 삭제 실패: $e');
    }
  }
}
