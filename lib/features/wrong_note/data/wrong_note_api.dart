import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'models/wrong_note_response.dart';

/// 오답노트 API 클라이언트
class WrongNoteApi {
  final Dio _dio;

  WrongNoteApi(this._dio);

  /// 사용자의 오답노트 목록 조회 (JWT에서 userId 자동 추출)
  /// [chapterId]: 선택사항 - null이면 전체 챕터 조회
  Future<WrongNoteResponse> getWrongNotes({int? chapterId}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (chapterId != null) {
        queryParams['chapter_id'] = chapterId;
      }

      final response = await _dio.get(
        '/api/wrong_note/mypage',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return WrongNoteResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('오답노트 조회 실패: $e');
    }
  }

  /// 퀴즈 결과를 서버에 제출하여 오답노트 업데이트
  /// [chapterId]: 챕터 ID
  /// [wrongItems]: 오답 항목 리스트 [{"quiz_id": 1, "selected_option": 2}]
  Future<void> submitQuizResults(
      int chapterId, List<Map<String, dynamic>> wrongItems) async {
    try {
      await _dio.post('/api/wrong_note/submit', data: {
        'chapterId': chapterId,
        'wrongItems': wrongItems,
      });
    } catch (e) {
      throw Exception('퀴즈 결과 제출 실패: $e');
    }
  }

  /// 특정 오답 문제 재시도 표시 (JWT에서 userId 자동 추출)
  Future<void> markAsRetried(int quizId) async {
    try {
      await _dio.patch('/api/wrong_note/$quizId/retry');
    } catch (e) {
      throw Exception('재시도 표시 실패: $e');
    }
  }

  /// 단일 퀴즈 결과를 오답노트에 제출 (단일 퀴즈용)
  /// [chapterId]: 챕터 ID
  /// [quizId]: 퀴즈 ID
  /// [selectedOption]: 선택한 답안 (1~4)
  Future<void> submitSingleQuizResult(
      int chapterId, int quizId, int selectedOption) async {
    try {
      debugPrint('🌐 [WrongNoteAPI] 단일 퀴즈 결과 제출 API 호출');
      debugPrint('🌐 [WrongNoteAPI] POST /api/wrong_note/single');
      debugPrint(
          '📋 [WrongNoteAPI] 데이터: chapterId=$chapterId, quizId=$quizId, selectedOption=$selectedOption');

      await _dio.post('/api/wrong_note/single', data: {
        'chapterId': chapterId,
        'quizId': quizId,
        'selectedOption': selectedOption,
      });

      debugPrint('✅ [WrongNoteAPI] 단일 퀴즈 결과 제출 API 성공');
    } catch (e) {
      debugPrint('❌ [WrongNoteAPI] 단일 퀴즈 결과 제출 API 실패 - Error: $e');
      throw Exception('단일 퀴즈 결과 제출 실패: $e');
    }
  }

  /// 오답노트에서 문제 삭제 (정답 처리 시, JWT에서 userId 자동 추출)
  Future<void> removeWrongNote(int quizId) async {
    try {
      debugPrint('🌐 [WrongNoteAPI] 오답노트 삭제 API 호출 - Quiz ID: $quizId');
      debugPrint('🌐 [WrongNoteAPI] DELETE /api/wrong_note/$quizId');

      final response = await _dio.delete('/api/wrong_note/$quizId');

      debugPrint(
          '✅ [WrongNoteAPI] 오답노트 삭제 API 성공 - Status: ${response.statusCode}');
      if (response.data != null) {
        debugPrint('📋 [WrongNoteAPI] Response Data: ${response.data}');
      }
    } catch (e) {
      debugPrint(
          '❌ [WrongNoteAPI] 오답노트 삭제 API 실패 - Quiz ID: $quizId, Error: $e');
      throw Exception('오답노트 삭제 실패: $e');
    }
  }
}
