import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/chapter_info.dart';
import '../../../../app/core/providers/riverpod/repository_providers.dart';
import '../../../../app/core/utils/error_message_extractor.dart';
import 'education_state.dart';

part 'education_notifier.g.dart';

/// 🔥 Riverpod 기반 교육 상태 관리 Notifier
@riverpod
class EducationNotifier extends _$EducationNotifier {
  // 챕터 완료 시 호출될 콜백 함수들
  final List<Function(int chapterId)> _onChapterCompletedCallbacks = [];

  @override
  EducationState build() {
    // 초기 상태 생성
    return const EducationState();
  }

  /// EducationRepository 접근
  dynamic get _repository => ref.read(educationRepositoryProvider);

  /// 챕터 완료 콜백 등록
  void addOnChapterCompletedCallback(Function(int chapterId) callback) {
    _onChapterCompletedCallbacks.add(callback);
  }

  /// 챕터 완료 콜백 해제
  void removeOnChapterCompletedCallback(Function(int chapterId) callback) {
    _onChapterCompletedCallbacks.remove(callback);
  }

  // === 챕터 관련 메서드 ===

  /// 챕터 목록 로드
  Future<void> loadChapters({bool forceRefresh = false}) async {
    if (state.isLoadingChapters) {
      debugPrint('⚠️ [EDU_NOTIFIER] 이미 챕터 로딩 중...');
      return;
    }

    debugPrint('🔄 [EDU_NOTIFIER] 챕터 목록 로드 시작 (forceRefresh: $forceRefresh)');
    state = state.copyWith(
      isLoadingChapters: true,
      chaptersError: null,
    );

    try {
      final chapters =
          await _repository.getChapters(forceRefresh: forceRefresh);
      debugPrint('✅ [EDU_NOTIFIER] 챕터 로드 성공 - 총 ${chapters.length}개 챕터');

      state = state.copyWith(
        chapters: chapters,
        isLoadingChapters: false,
        chaptersError: null,
      );
    } catch (e) {
      debugPrint('❌ [EDU_NOTIFIER] 챕터 로드 실패: $e');

      final errorMessage = ErrorMessageExtractor.extractDataLoadError(e, '챕터');
      debugPrint('📩 [EDU_NOTIFIER] 에러 메시지: $errorMessage');

      state = state.copyWith(
        chapters: [],
        isLoadingChapters: false,
        chaptersError: errorMessage,
      );
    }
  }

  /// 챕터 선택
  void selectChapter(int chapterId) {
    debugPrint('📌 [EDU_NOTIFIER] 챕터 선택: $chapterId');
    final chapter = state.getChapterById(chapterId);
    if (chapter != null) {
      state = state.copyWith(selectedChapterId: chapterId);
      debugPrint('✅ [EDU_NOTIFIER] 챕터 선택 완료: ${chapter.title}');
    } else {
      debugPrint('❌ [EDU_NOTIFIER] 존재하지 않는 챕터 ID: $chapterId');
    }
  }

  /// 챕터 선택 해제
  void clearSelectedChapter() {
    debugPrint('🔄 [EDU_NOTIFIER] 챕터 선택 해제');
    state = state.copyWith(selectedChapterId: null);
  }

  // === 이론 관련 메서드 ===

  /// 이론 진입
  Future<bool> enterTheory(int chapterId) async {
    if (state.isLoadingTheory) return false;

    debugPrint('🎓 [EDU_NOTIFIER] 이론 진입 요청 - 챕터 ID: $chapterId');
    state = state.copyWith(
      isLoadingTheory: true,
      theoryError: null,
    );

    try {
      final theorySession = await _repository.enterTheory(chapterId);

      // 저장된 진도가 있으면 해당 위치로 이동
      final savedProgress = await _repository.getTheoryProgress(chapterId);
      if (savedProgress != null) {
        debugPrint('📚 [EDU_NOTIFIER] 저장된 진도 발견 - 이론 ID: $savedProgress');
        final theoryIndex = _findTheoryIndexById(theorySession, savedProgress);
        state = state.copyWith(
          currentTheorySession: theorySession.copyWith(
            currentTheoryIndex: theoryIndex,
          ),
          isLoadingTheory: false,
          theoryError: null,
        );
      } else {
        state = state.copyWith(
          currentTheorySession: theorySession,
          isLoadingTheory: false,
          theoryError: null,
        );
      }

      debugPrint(
          '✅ [EDU_NOTIFIER] 이론 진입 성공 - 총 ${theorySession.totalCount}개 이론');
      return true;
    } catch (e) {
      debugPrint('❌ [EDU_NOTIFIER] 이론 진입 실패 - 챕터 ID: $chapterId, 에러: $e');

      final errorMessage = ErrorMessageExtractor.extractDataLoadError(e, '이론');

      state = state.copyWith(
        isLoadingTheory: false,
        theoryError: errorMessage,
      );
      return false;
    }
  }

  /// 다음 이론으로 이동
  Future<void> moveToNextTheory() async {
    if (!state.hasNextTheory || state.currentTheorySession == null) return;

    state = state.copyWith(
      currentTheorySession: state.currentTheorySession!.copyWith(
        currentTheoryIndex: state.currentTheorySession!.currentTheoryIndex + 1,
      ),
    );

    // 서버에 진도 업데이트
    await _updateProgressToServer();
  }

  /// 이전 이론으로 이동
  Future<void> moveToPreviousTheory() async {
    if (!state.hasPreviousTheory || state.currentTheorySession == null) return;

    state = state.copyWith(
      currentTheorySession: state.currentTheorySession!.copyWith(
        currentTheoryIndex: state.currentTheorySession!.currentTheoryIndex - 1,
      ),
    );

    // 서버에 진도 업데이트
    await _updateProgressToServer();
  }

  /// 특정 이론으로 이동
  Future<void> moveToTheoryByIndex(int index) async {
    if (state.currentTheorySession == null ||
        index < 0 ||
        index >= state.currentTheorySession!.totalCount) {
      return;
    }

    state = state.copyWith(
      currentTheorySession: state.currentTheorySession!.copyWith(
        currentTheoryIndex: index,
      ),
    );

    // 서버에 진도 업데이트
    await _updateProgressToServer();
  }

  /// 이론 완료 처리
  Future<bool> completeTheory() async {
    if (state.isCompletingTheory || state.currentTheorySession == null) {
      return false;
    }

    state = state.copyWith(isCompletingTheory: true);

    try {
      final chapterId = state.currentTheorySession!.chapterId;
      await _repository.completeTheory(chapterId);

      // 로컬 상태 업데이트: 이론 완료
      _updateLocalChapterCompletion(chapterId, isTheoryCompleted: true);

      // 챕터 완료 상태 확인 및 업데이트
      _checkAndUpdateChapterCompletion(chapterId);

      // 현재 이론 데이터 초기화
      state = state.copyWith(
        currentTheorySession: null,
        isCompletingTheory: false,
      );

      return true;
    } catch (e) {
      debugPrint('❌ [EDU_NOTIFIER] 이론 완료 처리 실패: $e');

      final errorMessage =
          ErrorMessageExtractor.extractSubmissionError(e, '이론 완료');

      state = state.copyWith(
        isCompletingTheory: false,
        theoryError: errorMessage,
      );
      return false;
    }
  }

  /// 이론 학습 종료 (완료하지 않고 나가기)
  void exitTheory() {
    state = state.copyWith(
      currentTheorySession: null,
      theoryError: null,
    );
  }

  /// 현재 이론 인덱스 설정
  void setCurrentTheoryIndex(int index) {
    if (state.currentTheorySession != null &&
        index >= 0 &&
        index < state.currentTheorySession!.theories.length) {
      state = state.copyWith(
        currentTheorySession: state.currentTheorySession!.copyWith(
          currentTheoryIndex: index,
        ),
      );
    }
  }

  /// 퀴즈 완료 상태 업데이트 (QuizProvider에서 호출됨)
  void updateQuizCompletion(int chapterId, {required bool isPassed}) {
    debugPrint(
        '🎯 [EDU_NOTIFIER] 퀴즈 완료 상태 업데이트 - 챕터 $chapterId (합격: $isPassed)');

    // 로컬 상태 업데이트
    _updateLocalChapterCompletion(chapterId, isQuizCompleted: isPassed);

    // 챕터 완료 상태 확인 및 업데이트
    _checkAndUpdateChapterCompletion(chapterId);
  }

  // === 캐시 관리 ===

  /// 전체 캐시 삭제
  Future<void> clearCache() async {
    debugPrint('🧹 [EDU_NOTIFIER] 캐시 삭제 시작');
    await _repository.clearCache();

    // 메모리 상태 초기화
    state = const EducationState();
    debugPrint('🧹 [EDU_NOTIFIER] 메모리 상태 초기화 완료');
  }

  // === Private Helper Methods ===

  /// 서버에 진도 업데이트
  Future<void> _updateProgressToServer() async {
    if (state.currentTheorySession == null || state.isUpdatingProgress) {
      return;
    }

    state = state.copyWith(isUpdatingProgress: true);

    try {
      final currentTheory = state.currentTheory;
      if (currentTheory != null) {
        await _repository.updateTheoryProgress(
          state.currentTheorySession!.chapterId,
          currentTheory.id,
        );
      }
    } catch (e) {
      debugPrint('❌ [EDU_NOTIFIER] 진도 업데이트 실패: $e');
      // 진도 업데이트 실패는 사용자에게 알리지 않음 (백그라운드 작업)
    } finally {
      state = state.copyWith(isUpdatingProgress: false);
    }
  }

  /// 특정 이론 ID로 인덱스 찾기
  int _findTheoryIndexById(dynamic theorySession, int theoryId) {
    if (theorySession == null) return 0;

    final index = theorySession.theories.indexWhere(
      (theory) => theory.id == theoryId,
    );

    return index >= 0 ? index : 0;
  }

  /// 로컬 챕터 완료 상태 업데이트
  void _updateLocalChapterCompletion(
    int chapterId, {
    bool? isTheoryCompleted,
    bool? isQuizCompleted,
    bool? isChapterCompleted,
  }) {
    final chapterIndex = state.chapters.indexWhere((c) => c.id == chapterId);
    if (chapterIndex >= 0) {
      final updatedChapters = List<ChapterInfo>.from(state.chapters);
      updatedChapters[chapterIndex] = updatedChapters[chapterIndex].copyWith(
        isTheoryCompleted: isTheoryCompleted,
        isQuizCompleted: isQuizCompleted,
        isChapterCompleted: isChapterCompleted,
      );
      state = state.copyWith(chapters: updatedChapters);
    }
  }

  /// 챕터 완료 상태 확인 및 업데이트
  void _checkAndUpdateChapterCompletion(int chapterId) {
    final chapter = state.getChapterById(chapterId);
    if (chapter != null) {
      // 이론과 퀴즈가 모두 완료된 경우에만 챕터 완료
      if (chapter.isTheoryCompleted && chapter.isQuizCompleted) {
        debugPrint(
            '🎉 [EDU_NOTIFIER] 챕터 완료! ID: $chapterId, Title: ${chapter.title}');
        _updateLocalChapterCompletion(chapterId, isChapterCompleted: true);

        // 챕터 완료 콜백 호출
        for (final callback in _onChapterCompletedCallbacks) {
          try {
            callback(chapterId);
          } catch (e) {
            debugPrint('❌ [EDU_NOTIFIER] 챕터 완료 콜백 실행 실패: $e');
          }
        }

        debugPrint('✅ [EDU_NOTIFIER] 챕터 완료 상태 백엔드 업데이트 요청 완료');
      } else {
        debugPrint(
            '⏳ [EDU_NOTIFIER] 챕터 미완료 - 이론: ${chapter.isTheoryCompleted}, 퀴즈: ${chapter.isQuizCompleted}');
      }
    }
  }
}
