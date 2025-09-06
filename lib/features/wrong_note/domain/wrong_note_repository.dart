import '../data/wrong_note_api.dart';
import '../data/models/wrong_note_response.dart';

/// 오답노트 Repository
/// 실제 API를 사용하여 오답노트 데이터를 관리합니다. (JWT 토큰 자동 처리)
class WrongNoteRepository {
  final WrongNoteApi _api;

  WrongNoteRepository(this._api);

  /// 사용자의 오답노트 목록 조회 (JWT에서 userId 자동 추출)
  /// [chapterId]: 선택사항 - null이면 전체 챕터 조회
  Future<WrongNoteResponse> getWrongNotes({int? chapterId}) async {
    try {
      return await _api.getWrongNotes(chapterId: chapterId);
    } catch (e) {
      throw Exception('오답노트 조회 실패: $e');
    }
  }

  /// 퀴즈 결과를 제출하여 오답노트 업데이트 (새 API 방식)
  /// [chapterId]: 챕터 ID
  /// [wrongItems]: 오답 항목 리스트
  Future<void> submitQuizResults(int chapterId, List<Map<String, dynamic>> wrongItems) async {
    try {
      await _api.submitQuizResults(chapterId, wrongItems);
    } catch (e) {
      throw Exception('퀴즈 결과 제출 실패: $e');
    }
  }

  /// 특정 오답 문제 재시도 표시 (JWT에서 userId 자동 추출)
  Future<void> markAsRetried(int quizId) async {
    try {
      await _api.markAsRetried(quizId);
    } catch (e) {
      throw Exception('재시도 표시 실패: $e');
    }
  }

  /// 오답노트에서 문제 삭제 (정답 처리 시, JWT에서 userId 자동 추출)
  Future<void> removeWrongNote(int quizId) async {
    try {
      await _api.removeWrongNote(quizId);
    } catch (e) {
      throw Exception('오답노트 삭제 실패: $e');
    }
  }
}
