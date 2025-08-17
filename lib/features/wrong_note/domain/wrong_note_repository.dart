import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/wrong_note_api.dart';
import '../data/models/wrong_note_request.dart';
import '../data/models/wrong_note_response.dart';

/// 오답노트 Repository
/// 실제 API와 로컬 저장소를 사용하여 오답노트 데이터를 관리합니다.
class WrongNoteRepository {
  final WrongNoteApi _api;
  final FlutterSecureStorage _storage;

  WrongNoteRepository(this._api, this._storage);

  /// 사용자의 오답노트 목록 조회
  Future<WrongNoteResponse> getWrongNotes() async {
    try {
      // 저장된 사용자 ID 가져오기
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        throw Exception('사용자 정보가 없습니다.');
      }

      return await _api.getWrongNotes(userId);
    } catch (e) {
      throw Exception('오답노트 조회 실패: $e');
    }
  }

  /// 퀴즈 결과를 제출하여 오답노트 업데이트
  Future<void> submitQuizResults(WrongNoteRequest request) async {
    try {
      await _api.submitQuizResults(request);
    } catch (e) {
      throw Exception('퀴즈 결과 제출 실패: $e');
    }
  }

  /// 특정 오답 문제 재시도 표시
  Future<void> markAsRetried(int quizId) async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        throw Exception('사용자 정보가 없습니다.');
      }

      await _api.markAsRetried(userId, quizId);
    } catch (e) {
      throw Exception('재시도 표시 실패: $e');
    }
  }

  /// 오답노트에서 문제 삭제 (정답 처리 시)
  Future<void> removeWrongNote(int quizId) async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        throw Exception('사용자 정보가 없습니다.');
      }

      await _api.removeWrongNote(userId, quizId);
    } catch (e) {
      throw Exception('오답노트 삭제 실패: $e');
    }
  }
}
