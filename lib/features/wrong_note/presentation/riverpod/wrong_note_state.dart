import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/wrong_note_response.dart';

part 'wrong_note_state.freezed.dart';

/// 🔥 Riverpod 오답노트 상태 클래스 (Freezed)
@freezed
class WrongNoteState with _$WrongNoteState {
  const factory WrongNoteState({
    /// 오답노트 목록
    @Default([]) List<WrongNoteItem> wrongNotes,

    /// 재시도된 퀴즈 ID들
    @Default({}) Set<int> retriedQuizIds,

    /// 삭제 처리 중인 퀴즈 ID들 (중복 방지)
    @Default({}) Set<int> deletingQuizIds,

    /// 로딩 중
    @Default(false) bool isLoading,

    /// 에러 메시지
    String? errorMessage,
  }) = _WrongNoteState;

  const WrongNoteState._();

  // === Computed Getters (Helper Methods) ===

  /// 에러 존재 여부
  bool get hasError => errorMessage != null;

  /// 총 오답노트 개수
  int get totalCount => wrongNotes.length;

  /// 재시도된 문제 개수
  int get retriedCount =>
      wrongNotes.where((note) => retriedQuizIds.contains(note.quizId)).length;

  /// 미재시도 문제 개수
  int get pendingCount => totalCount - retriedCount;

  /// 챕터별 오답노트 필터링
  List<WrongNoteItem> getWrongNotesByChapter(int chapterId) {
    return wrongNotes.where((item) => item.chapterId == chapterId).toList();
  }

  /// 재시도 여부별 필터링
  List<WrongNoteItem> getWrongNotesByRetryStatus(bool isRetried) {
    return wrongNotes
        .where((item) => retriedQuizIds.contains(item.quizId) == isRetried)
        .toList();
  }

  /// 통계 정보
  Map<String, int> get statistics => {
        'total': totalCount,
        'retried': retriedCount,
        'pending': pendingCount,
      };

  /// 특정 퀴즈가 재시도되었는지 확인
  bool isQuizRetried(int quizId) => retriedQuizIds.contains(quizId);

  /// 특정 퀴즈가 삭제 중인지 확인
  bool isQuizDeleting(int quizId) => deletingQuizIds.contains(quizId);
}
