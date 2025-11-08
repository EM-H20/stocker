import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repository/learning_progress_repository.dart';
import 'learning_progress_state.dart';

part 'learning_progress_notifier.g.dart';

/// 🔥 Riverpod 기반 학습 진도 상태 관리 Notifier
@riverpod
class LearningProgressNotifier extends _$LearningProgressNotifier {
  LearningProgressRepository? _repository;

  @override
  LearningProgressState build() {
    // 초기화는 setRepository 호출 후 진행
    return const LearningProgressState();
  }

  /// Repository 설정 (main.dart에서 호출)
  void setRepository(LearningProgressRepository repository) {
    _repository = repository;
    _initialize();
  }

  /// 초기화
  Future<void> _initialize() async {
    if (_repository == null) return;

    await _loadProgress();
    state = state.copyWith(isInitialized: true);
  }

  /// Repository에서 진도 데이터 불러오기
  Future<void> _loadProgress() async {
    if (_repository == null) return;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // 마지막 학습 위치 로드
      final lastPosition = await _repository!.getLastLearningPosition();
      final lastChapterId = lastPosition?['chapterId'] ?? 1;
      final lastStep = lastPosition?['step'] ?? 'theory';

      // 완료된 챕터들 로드
      final completedChaptersList = await _repository!.getCompletedChapters();
      final completedChaptersMap = <int, bool>{};
      for (final chapterId in completedChaptersList) {
        completedChaptersMap[chapterId] = true;
      }

      // 완료된 퀴즈들 로드
      final completedQuizzesList = await _repository!.getCompletedQuizzes();
      final completedQuizzesMap = <int, bool>{};
      for (final chapterId in completedQuizzesList) {
        completedQuizzesMap[chapterId] = true;
      }

      // 학습한 날짜들 로드
      final studiedDates = await _repository!.getStudiedDates();

      // 사용 가능한 챕터 목록 로드
      final availableChapters = await _repository!.getAvailableChapters();

      state = state.copyWith(
        lastChapterId: lastChapterId,
        lastStep: lastStep,
        completedChapters: completedChaptersMap,
        completedQuizzes: completedQuizzesMap,
        studiedDates: studiedDates,
        availableChapters: availableChapters,
        isLoading: false,
      );

      debugPrint('📚 [LEARNING_PROGRESS_NOTIFIER] Repository에서 진도 데이터 로드 완료');
      debugPrint('   - 마지막 위치: Chapter $lastChapterId ($lastStep)');
      debugPrint('   - 완료 챕터: ${completedChaptersMap.keys.toList()}');
      debugPrint('   - 완료 퀴즈: ${completedQuizzesMap.keys.toList()}');
      debugPrint('   - 학습일: ${studiedDates.length}일');
      debugPrint('   - 사용 가능한 챕터: ${availableChapters.length}개');
    } catch (e) {
      debugPrint('❌ [LEARNING_PROGRESS_NOTIFIER] Repository 진도 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Repository 진도 로드 실패: $e',
      );
    }
  }

  // === 진도 업데이트 메서드들 ===

  /// 현재 학습 위치 업데이트
  Future<void> updateCurrentPosition({
    required int chapterId,
    required String step,
  }) async {
    if (_repository == null) return;

    try {
      // Repository를 통해 위치 저장
      await _repository!.saveLastLearningPosition(
        chapterId: chapterId,
        step: step,
      );

      // 오늘 학습 기록 추가
      await _repository!.addTodayStudyRecord();
      final updatedStudiedDates = await _repository!.getStudiedDates();

      state = state.copyWith(
        lastChapterId: chapterId,
        lastStep: step,
        studiedDates: updatedStudiedDates,
      );

      debugPrint(
          '📍 [LEARNING_PROGRESS_NOTIFIER] 위치 업데이트: Chapter $chapterId ($step)');
    } catch (e) {
      debugPrint('❌ [LEARNING_PROGRESS_NOTIFIER] 위치 업데이트 실패: $e');
      state = state.copyWith(errorMessage: '위치 업데이트 실패: $e');
    }
  }

  /// 챕터 완료 표시
  Future<void> completeChapter(int chapterId) async {
    if (_repository == null) return;

    // 이미 완료된 챕터라면 중복 처리하지 않음
    if (state.isChapterCompleted(chapterId)) {
      debugPrint(
          '⚠️ [LEARNING_PROGRESS_NOTIFIER] 챕터 $chapterId 이미 완료됨 - 중복 처리 방지');
      return;
    }

    try {
      // 로컬 상태 먼저 업데이트 (낙관적 업데이트)
      final updatedCompletedChapters =
          Map<int, bool>.from(state.completedChapters);
      updatedCompletedChapters[chapterId] = true;

      state = state.copyWith(completedChapters: updatedCompletedChapters);

      // Repository를 통해 완료 상태 저장
      await _repository!.markChapterCompleted(chapterId);
      debugPrint('✅ [LEARNING_PROGRESS_NOTIFIER] 챕터 $chapterId 완료!');
    } catch (e) {
      debugPrint('❌ [LEARNING_PROGRESS_NOTIFIER] 챕터 $chapterId 완료 저장 실패: $e');
      // 에러가 발생해도 로컬 상태는 유지 (사용자 경험을 위해)
    }
  }

  /// 퀴즈 완료 표시
  Future<void> completeQuiz(int chapterId) async {
    if (_repository == null) return;

    try {
      // 로컬 상태 먼저 업데이트
      final updatedCompletedQuizzes =
          Map<int, bool>.from(state.completedQuizzes);
      updatedCompletedQuizzes[chapterId] = true;

      state = state.copyWith(completedQuizzes: updatedCompletedQuizzes);

      // Repository를 통해 완료 상태 저장
      await _repository!.markQuizCompleted(chapterId);
      debugPrint('🎯 [LEARNING_PROGRESS_NOTIFIER] 퀴즈 $chapterId 완료!');
    } catch (e) {
      debugPrint('❌ [LEARNING_PROGRESS_NOTIFIER] 퀴즈 $chapterId 완료 저장 실패: $e');
    }
  }

  /// 진도 초기화 (테스트용)
  Future<void> resetProgress() async {
    if (_repository == null) return;

    try {
      // Repository를 통해 초기화
      await _repository!.resetProgress();

      state = const LearningProgressState(
        lastChapterId: 1,
        lastStep: 'theory',
        completedChapters: {},
        completedQuizzes: {},
        studiedDates: {},
        isInitialized: true,
      );

      debugPrint('🔄 [LEARNING_PROGRESS_NOTIFIER] 진도 초기화 완료');
    } catch (e) {
      debugPrint('❌ [LEARNING_PROGRESS_NOTIFIER] 진도 초기화 실패: $e');
      state = state.copyWith(errorMessage: '진도 초기화 실패: $e');
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 진도 데이터 리로드
  Future<void> reload() async {
    await _loadProgress();
  }
}
