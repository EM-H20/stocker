import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/wrong_note_request.dart';
import '../../data/models/wrong_note_response.dart';
import '../../../../app/core/providers/riverpod/repository_providers.dart';
import 'wrong_note_state.dart';

part 'wrong_note_notifier.g.dart';

/// 🔥 Riverpod 기반 오답노트 상태 관리 Notifier
@riverpod
class WrongNoteNotifier extends _$WrongNoteNotifier {
  @override
  WrongNoteState build() {
    // 초기 상태 생성
    return const WrongNoteState();
  }

  /// WrongNoteRepository 접근
  dynamic get _repository => ref.read(wrongNoteRepositoryProvider);

  // === 오답노트 로드 ===

  /// 오답노트 목록 로드
  /// [chapterId]: 선택사항 - null이면 전체 챕터 조회
  Future<void> loadWrongNotes({int? chapterId}) async {
    debugPrint('📚 [WRONG_NOTE_NOTIFIER] 오답노트 로드 시작 (chapterId: $chapterId)');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final WrongNoteResponse response =
          await _repository.getWrongNotes(chapterId: chapterId);

      // Mock Repository의 경우 재시도 상태도 가져오기
      Set<int> retriedIds = {};
      try {
        if (_repository.runtimeType.toString().contains('Mock')) {
          retriedIds = _repository.retriedQuizIds as Set<int>;
        }
      } catch (e) {
        debugPrint('ℹ️ [WRONG_NOTE_NOTIFIER] 재시도 상태 로드 불가 (Real API일 가능성)');
      }

      state = state.copyWith(
        wrongNotes: response.wrongNotes,
        retriedQuizIds: retriedIds,
        isLoading: false,
        errorMessage: null,
      );

      debugPrint(
          '✅ [WRONG_NOTE_NOTIFIER] 오답노트 로드 완료 - ${response.wrongNotes.length}개 문제');

      // 각 문제 정보 출력 (디버깅용)
      for (int i = 0; i < response.wrongNotes.length; i++) {
        final note = response.wrongNotes[i];
        debugPrint(
            '   [$i] ID: ${note.id}, Quiz: ${note.quizId}, Chapter: ${note.chapterId}');

        String questionPreview = '미지정';
        if (note.question != null) {
          final question = note.question!;
          questionPreview = question.length > 20
              ? '${question.substring(0, 20)}...'
              : question;
        }
        debugPrint('       문제: $questionPreview');
        debugPrint(
            '       선택: ${note.selectedOption}, 정답: ${note.correctAnswerIndex}');
      }

      // 복습 상태 요약
      final retriedCount = state.retriedCount;
      debugPrint(
          '📊 [WRONG_NOTE_NOTIFIER] 복습 상태 요약: $retriedCount/${state.totalCount}개 복습 완료');
    } catch (e) {
      debugPrint('❌ [WRONG_NOTE_NOTIFIER] 오답노트 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '오답노트 로드 실패: $e',
      );
    }
  }

  // === 퀴즈 결과 제출 ===

  /// 퀴즈 결과 제출 (일반 퀴즈 전용)
  /// [chapterId]: 챕터 ID
  /// [wrongItems]: 오답 항목 리스트
  Future<void> submitQuizResults(
      int chapterId, List<Map<String, dynamic>> wrongItems) async {
    try {
      debugPrint(
          '📝 [WRONG_NOTE_NOTIFIER] 일반 퀴즈 결과 제출 시작 - Chapter: $chapterId, 오답 수: ${wrongItems.length}');

      // Mock Repository인 경우 WrongNoteRequest 형식으로 변환
      if (_repository.runtimeType.toString().contains('Mock')) {
        final request = WrongNoteRequest(
          userId: 'mock_user',
          chapterId: chapterId,
          results: wrongItems
              .map((item) => QuizResult(
                    quizId: item['quiz_id'],
                    isCorrect: false,
                  ))
              .toList(),
        );
        await _repository.submitQuizResults(request);
      } else {
        await _repository.submitQuizResults(chapterId, wrongItems);
      }

      // 제출 후 오답노트 다시 로드
      await loadWrongNotes();
      debugPrint('✅ [WRONG_NOTE_NOTIFIER] 일반 퀴즈 결과 제출 완료');
    } catch (e) {
      debugPrint('❌ [WRONG_NOTE_NOTIFIER] 일반 퀴즈 결과 제출 실패: $e');
      state = state.copyWith(errorMessage: '퀴즈 결과 제출 실패: $e');
    }
  }

  /// 단일 퀴즈 결과 제출 (단일 퀴즈 전용)
  /// [chapterId]: 챕터 ID
  /// [quizId]: 퀴즈 ID
  /// [selectedOption]: 선택한 답안 (1~4)
  Future<void> submitSingleQuizResult(
      int chapterId, int quizId, int selectedOption) async {
    try {
      debugPrint(
          '📝 [WRONG_NOTE_NOTIFIER] 단일 퀴즈 결과 제출 시작 - Chapter: $chapterId, Quiz: $quizId, Option: $selectedOption');

      if (_repository.runtimeType.toString().contains('Mock')) {
        debugPrint('🎭 [WRONG_NOTE_NOTIFIER] Mock Repository로 단일 퀴즈 제출');
        await _repository.submitSingleQuizResult(
            'mock_user', chapterId, quizId, selectedOption);
      } else {
        debugPrint('🌐 [WRONG_NOTE_NOTIFIER] Real API Repository로 단일 퀴즈 제출');
        await _repository.submitSingleQuizResult(
            chapterId, quizId, selectedOption);
      }

      // 제출 후 오답노트 다시 로드
      await loadWrongNotes();
      debugPrint(
          '✅ [WRONG_NOTE_NOTIFIER] 단일 퀴즈 결과 제출 완료 - Quiz $quizId 오답노트에 추가됨');
    } catch (e) {
      debugPrint('❌ [WRONG_NOTE_NOTIFIER] 단일 퀴즈 결과 제출 실패: $e');
      state = state.copyWith(errorMessage: '단일 퀴즈 결과 제출 실패: $e');
    }
  }

  // === 재시도 관리 ===

  /// 문제 재시도 표시
  Future<void> markAsRetried(int quizId) async {
    try {
      if (_repository.runtimeType.toString().contains('Mock')) {
        await _repository.markAsRetried('mock_user', quizId);
      } else {
        await _repository.markAsRetried(quizId);
      }

      // 로컬 상태 업데이트
      final updatedRetried = Set<int>.from(state.retriedQuizIds)..add(quizId);
      state = state.copyWith(retriedQuizIds: updatedRetried);

      debugPrint('✅ [WRONG_NOTE_NOTIFIER] Quiz $quizId 재시도 마크 완료');
    } catch (e) {
      debugPrint('❌ [WRONG_NOTE_NOTIFIER] 재시도 마크 실패: $e');
      state = state.copyWith(errorMessage: '재시도 표시 실패: $e');
    }
  }

  /// 📖 읽기 전용 모드: DB 수정 없이 프론트엔드 상태만 업데이트
  void markAsRetriedLocally(int quizId) {
    debugPrint('📖 [WRONG_NOTE_NOTIFIER] ReadOnly 모드 - 로컬 재시도 마크만 업데이트');
    debugPrint('🛡️ [WRONG_NOTE_NOTIFIER] Quiz ID: $quizId - DB 수정 없음, 삭제 없음!');
    debugPrint('💡 [WRONG_NOTE_NOTIFIER] 복습용으로 계속 유지되며, 서버 동기화 없음');

    // 해당 퀴즈가 실제로 존재하는지 확인
    final targetQuiz =
        state.wrongNotes.where((item) => item.quizId == quizId).toList();
    if (targetQuiz.isEmpty) {
      debugPrint(
          '⚠️ [WRONG_NOTE_NOTIFIER] Quiz $quizId가 오답노트에 없음 - 마크 건너뜀');
      return;
    }

    // 재시도 마크 추가
    final wasAlreadyMarked = state.retriedQuizIds.contains(quizId);
    final updatedRetried = Set<int>.from(state.retriedQuizIds)..add(quizId);

    state = state.copyWith(retriedQuizIds: updatedRetried);

    debugPrint('📊 [WRONG_NOTE_NOTIFIER] 상태 업데이트:');
    debugPrint('   - Quiz $quizId: ${wasAlreadyMarked ? '이미 마크됨' : '새로 마크됨'}');
    debugPrint('   - 전체 재시도 마크: ${state.retriedQuizIds.length}개');
    debugPrint('   - 전체 오답노트: ${state.wrongNotes.length}개');
    debugPrint(
        '✅ [WRONG_NOTE_NOTIFIER] ReadOnly 로컬 마크 완료 - 오답노트에서 제거하지 않음');
  }

  // === 오답노트 삭제 ===

  /// 오답노트에서 문제 삭제 (정답 처리 시)
  Future<void> removeWrongNote(int quizId) async {
    debugPrint('🗑️ [WRONG_NOTE_NOTIFIER] 오답노트 삭제 시작 - Quiz ID: $quizId');

    // 중복 삭제 방지
    if (state.isQuizDeleting(quizId)) {
      debugPrint(
          '⚠️ [WRONG_NOTE_NOTIFIER] 이미 삭제 처리 중인 Quiz $quizId - 중복 호출 방지');
      return;
    }

    // 삭제 처리 중 플래그 설정
    final updatedDeleting = Set<int>.from(state.deletingQuizIds)..add(quizId);
    state = state.copyWith(deletingQuizIds: updatedDeleting);
    debugPrint('🔒 [WRONG_NOTE_NOTIFIER] Quiz $quizId 삭제 처리 중 플래그 설정');

    try {
      // 현재 오답노트 상태 요약
      debugPrint(
          '📊 [WRONG_NOTE_NOTIFIER] 현재 오답노트 상태: ${state.wrongNotes.length}개 문제');
      for (final note in state.wrongNotes) {
        debugPrint(
            '   - Quiz ${note.quizId} (Chapter: ${note.chapterId}, Selected: ${note.selectedOption})');
      }

      // 로컬에서 해당 quiz_id 찾기
      final existingNote =
          state.wrongNotes.where((item) => item.quizId == quizId).toList();
      if (existingNote.isEmpty) {
        debugPrint(
            '⚠️ [WRONG_NOTE_NOTIFIER] 로컬에서 Quiz $quizId를 찾을 수 없음');
        debugPrint('💡 [WRONG_NOTE_NOTIFIER] 가능한 원인:');
        debugPrint('   1. 이미 삭제된 문제');
        debugPrint('   2. 오답노트에 없던 문제 (원래 정답이었던 문제)');
        debugPrint('   3. 서버와 로컬 상태 불일치');

        // 플래그 해제
        final clearedDeleting = Set<int>.from(state.deletingQuizIds)
          ..remove(quizId);
        state = state.copyWith(deletingQuizIds: clearedDeleting);
        debugPrint('🔓 [WRONG_NOTE_NOTIFIER] Quiz $quizId 플래그 해제 (로컬에 없음)');
        return;
      }

      debugPrint('📍 [WRONG_NOTE_NOTIFIER] 삭제 대상 발견: ${existingNote.length}개');
      for (final note in existingNote) {
        debugPrint(
            '   - ID: ${note.id}, Quiz: ${note.quizId}, Chapter: ${note.chapterId}');
        debugPrint(
            '   - 선택: ${note.selectedOption}, 정답: ${note.correctAnswerIndex}');
      }

      // API 호출
      if (_repository.runtimeType.toString().contains('Mock')) {
        debugPrint('🎭 [WRONG_NOTE_NOTIFIER] Mock Repository로 삭제 API 호출');
        await _repository.removeWrongNote('mock_user', quizId);
      } else {
        debugPrint('🌐 [WRONG_NOTE_NOTIFIER] Real API Repository로 삭제 API 호출');
        await _repository.removeWrongNote(quizId);
      }

      // API 호출 성공 시 로컬 상태에서 제거
      final removedCount = state.wrongNotes.length;
      final updatedNotes = state.wrongNotes
          .where((item) => item.quizId != quizId)
          .toList();
      final actualRemoved = removedCount - updatedNotes.length;

      state = state.copyWith(wrongNotes: updatedNotes);

      debugPrint('✅ [WRONG_NOTE_NOTIFIER] 서버 & 로컬 삭제 성공!');
      debugPrint('   - Quiz ID: $quizId');
      debugPrint('   - 제거된 항목 수: $actualRemoved개');
      debugPrint('   - 삭제 전 총 개수: $removedCount개 → 삭제 후: ${updatedNotes.length}개');
    } catch (e) {
      final errorStr = e.toString();

      // 404 에러 처리
      if (errorStr.contains('404') || errorStr.contains('찾을 수 없습니다')) {
        debugPrint(
            '🤷‍♀️ [WRONG_NOTE_NOTIFIER] 서버 404 에러 - Quiz $quizId를 찾을 수 없음');
        debugPrint('💡 [WRONG_NOTE_NOTIFIER] 서버에서 이미 삭제되었을 가능성이 높음');
        debugPrint('🧹 [WRONG_NOTE_NOTIFIER] 로컬 상태만 정리하여 서버와 동기화');

        // 로컬에서 제거
        final removedCount = state.wrongNotes.length;
        final updatedNotes = state.wrongNotes
            .where((item) => item.quizId != quizId)
            .toList();
        final actualRemoved = removedCount - updatedNotes.length;

        state = state.copyWith(wrongNotes: updatedNotes);

        debugPrint('✅ [WRONG_NOTE_NOTIFIER] 로컬 정리 완료 - $actualRemoved개 항목 제거됨');

        // 플래그 해제
        final clearedDeleting = Set<int>.from(state.deletingQuizIds)
          ..remove(quizId);
        state = state.copyWith(deletingQuizIds: clearedDeleting);
        debugPrint('🔓 [WRONG_NOTE_NOTIFIER] Quiz $quizId 플래그 해제 (404 처리)');
        return;
      }

      // 다른 에러는 실제 에러로 처리
      debugPrint('❌ [WRONG_NOTE_NOTIFIER] 오답노트 삭제 실패 - Quiz $quizId');
      debugPrint('💥 [WRONG_NOTE_NOTIFIER] 에러 상세: $e');
      state = state.copyWith(errorMessage: '오답노트 삭제 실패: $e');
      rethrow;
    } finally {
      // 플래그 해제
      final clearedDeleting = Set<int>.from(state.deletingQuizIds)
        ..remove(quizId);
      state = state.copyWith(deletingQuizIds: clearedDeleting);
      debugPrint('🔓 [WRONG_NOTE_NOTIFIER] Quiz $quizId 삭제 처리 완료 - 플래그 해제');
    }
  }

  // === 유틸리티 ===

  /// ReadOnly 상태 초기화
  void clearReadOnlyState() {
    debugPrint('🧹 [WRONG_NOTE_NOTIFIER] ReadOnly 상태 초기화 시작');
    debugPrint('   - 초기화 전 재시도 마크: ${state.retriedQuizIds.length}개');
    debugPrint('✅ [WRONG_NOTE_NOTIFIER] ReadOnly 상태 초기화 완료');
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
