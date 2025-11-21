import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/quiz_result.dart';
import '../../../../app/core/providers/riverpod/repository_providers.dart';
import '../../../../app/core/utils/error_message_extractor.dart';
import 'quiz_state.dart';

part 'quiz_notifier.g.dart';

/// 🔥 Riverpod 기반 퀴즈 상태 관리 Notifier
@riverpod
class QuizNotifier extends _$QuizNotifier {
  // 타이머
  Timer? _timer;

  // 콜백 함수들
  final List<Function(int chapterId, QuizResult result)>
      _onQuizCompletedCallbacks = [];
  final List<Function(int chapterId, int quizId, bool isCorrect)>
      _onSingleQuizCompletedCallbacks = [];
  final List<Function(int wrongNoteId)> _onWrongNoteRemovedCallbacks = [];

  @override
  QuizState build() {
    // Dispose 시 타이머 정리
    ref.onDispose(() {
      _stopTimer();
    });

    // 초기 상태 생성
    return const QuizState();
  }

  /// QuizRepository 접근
  dynamic get _repository => ref.read(quizRepositoryProvider);

  // === 콜백 관리 ===

  /// 퀴즈 완료 콜백 등록
  void addOnQuizCompletedCallback(
      Function(int chapterId, QuizResult result) callback) {
    _onQuizCompletedCallbacks.add(callback);
  }

  /// 퀴즈 완료 콜백 해제
  void removeOnQuizCompletedCallback(
      Function(int chapterId, QuizResult result) callback) {
    _onQuizCompletedCallbacks.remove(callback);
  }

  /// 단일 퀴즈 완료 콜백 등록
  void addOnSingleQuizCompletedCallback(
      Function(int chapterId, int quizId, bool isCorrect) callback) {
    _onSingleQuizCompletedCallbacks.add(callback);
  }

  /// 단일 퀴즈 완료 콜백 해제
  void removeOnSingleQuizCompletedCallback(
      Function(int chapterId, int quizId, bool isCorrect) callback) {
    _onSingleQuizCompletedCallbacks.remove(callback);
  }

  /// 오답노트 제거 콜백 등록
  void addOnWrongNoteRemovedCallback(Function(int wrongNoteId) callback) {
    _onWrongNoteRemovedCallbacks.add(callback);
  }

  /// 오답노트 제거 콜백 해제
  void removeOnWrongNoteRemovedCallback(Function(int wrongNoteId) callback) {
    _onWrongNoteRemovedCallbacks.remove(callback);
  }

  // === 퀴즈 시작 ===

  /// 퀴즈 시작 (일반 모드)
  Future<bool> startQuiz(int chapterId, {Duration? timeLimit}) async {
    if (state.isLoadingQuiz) return false;

    debugPrint('🎯 [QUIZ_NOTIFIER] 퀴즈 시작 - 챕터 ID: $chapterId');
    state = state.copyWith(
      isLoadingQuiz: true,
      quizError: null,
      isReadOnlyMode: false,
    );

    try {
      final quizSession = await _repository.enterQuiz(chapterId);

      state = state.copyWith(
        currentQuizSession: quizSession,
        isLoadingQuiz: false,
        quizError: null,
        isReadOnlyMode: false,
        isTimerRunning: false,
        remainingSeconds: 0,
      );

      // 타이머 시작
      if (timeLimit != null) {
        _startTimer(timeLimit);
      }

      debugPrint(
          '✅ [QUIZ_NOTIFIER] 퀴즈 시작 성공 - 총 ${quizSession.totalCount}개 문제');
      return true;
    } catch (e) {
      debugPrint('❌ [QUIZ_NOTIFIER] 퀴즈 시작 실패: $e');

      final errorMessage = ErrorMessageExtractor.extractDataLoadError(e, '퀴즈');

      state = state.copyWith(
        isLoadingQuiz: false,
        quizError: errorMessage,
      );
      return false;
    }
  }

  /// 단일 퀴즈 시작 (오답노트 복습용)
  Future<bool> startSingleQuiz(int quizId) async {
    if (state.isLoadingQuiz) return false;

    debugPrint('🎯 [QUIZ_NOTIFIER] 단일 퀴즈 시작 - 퀴즈 ID: $quizId');
    state = state.copyWith(
      isLoadingQuiz: true,
      quizError: null,
      isReadOnlyMode: false,
    );

    try {
      final quizSession = await _repository.enterSingleQuiz(quizId);

      state = state.copyWith(
        currentQuizSession: quizSession,
        isLoadingQuiz: false,
        quizError: null,
        isReadOnlyMode: false,
        isTimerRunning: false,
        remainingSeconds: 0,
      );

      debugPrint('✅ [QUIZ_NOTIFIER] 단일 퀴즈 시작 성공');
      return true;
    } catch (e) {
      debugPrint('❌ [QUIZ_NOTIFIER] 단일 퀴즈 시작 실패: $e');

      final errorMessage = ErrorMessageExtractor.extractDataLoadError(e, '퀴즈');

      state = state.copyWith(
        isLoadingQuiz: false,
        quizError: errorMessage,
      );
      return false;
    }
  }

  /// 오답노트 복습 시작 (읽기 전용 모드)
  Future<bool> startWrongNoteReview(int chapterId) async {
    if (state.isLoadingQuiz) return false;

    debugPrint('📚 [QUIZ_NOTIFIER] 오답노트 복습 시작 - 챕터 ID: $chapterId');
    state = state.copyWith(
      isLoadingQuiz: true,
      quizError: null,
      isReadOnlyMode: true,
    );

    try {
      final quizSession = await _repository.getWrongNotes(chapterId);

      if (quizSession.quizzes.isEmpty) {
        debugPrint('ℹ️ [QUIZ_NOTIFIER] 오답노트가 비어있습니다');
        state = state.copyWith(
          isLoadingQuiz: false,
          quizError: '오답노트가 비어있습니다',
        );
        return false;
      }

      state = state.copyWith(
        currentQuizSession: quizSession,
        isLoadingQuiz: false,
        quizError: null,
        isReadOnlyMode: true,
        isTimerRunning: false,
        remainingSeconds: 0,
      );

      debugPrint(
          '✅ [QUIZ_NOTIFIER] 오답노트 복습 시작 성공 - 총 ${quizSession.totalCount}개 오답');
      return true;
    } catch (e) {
      debugPrint('❌ [QUIZ_NOTIFIER] 오답노트 복습 시작 실패: $e');

      final errorMessage = ErrorMessageExtractor.extractDataLoadError(e, '오답노트');

      state = state.copyWith(
        isLoadingQuiz: false,
        quizError: errorMessage,
      );
      return false;
    }
  }

  // === 답안 제출 ===

  /// 답안 제출
  Future<bool> submitAnswer(int selectedOption) async {
    if (state.isSubmittingAnswer ||
        state.currentQuizSession == null ||
        state.isReadOnlyMode) {
      return false;
    }

    state = state.copyWith(isSubmittingAnswer: true);

    try {
      final currentQuiz = state.currentQuiz;
      if (currentQuiz == null) {
        state = state.copyWith(isSubmittingAnswer: false);
        return false;
      }

      final result = await _repository.submitAnswer(
        currentQuiz.id,
        selectedOption,
      );

      // 답변 업데이트 - userAnswers에 저장
      final updatedAnswers = List<int?>.from(state.currentQuizSession!.userAnswers);
      updatedAnswers[state.currentQuizSession!.currentQuizIndex] = selectedOption;

      final updatedSession = state.currentQuizSession!.copyWith(
        userAnswers: updatedAnswers,
      );

      state = state.copyWith(
        currentQuizSession: updatedSession,
        isSubmittingAnswer: false,
      );

      // 단일 퀴즈 완료 콜백 호출
      final chapterId = state.currentQuizSession!.chapterId;
      for (final callback in _onSingleQuizCompletedCallbacks) {
        try {
          callback(chapterId, currentQuiz.id, result.isCorrect);
        } catch (e) {
          debugPrint('❌ [QUIZ_NOTIFIER] 단일 퀴즈 완료 콜백 실행 실패: $e');
        }
      }

      debugPrint(
          '✅ [QUIZ_NOTIFIER] 답안 제출 완료 - ${result.isCorrect ? "정답" : "오답"}');
      return true;
    } catch (e) {
      debugPrint('❌ [QUIZ_NOTIFIER] 답안 제출 실패: $e');

      final errorMessage = ErrorMessageExtractor.extractSubmissionError(e, '답안 제출');

      state = state.copyWith(
        isSubmittingAnswer: false,
        quizError: errorMessage,
      );
      return false;
    }
  }

  // === 퀴즈 네비게이션 ===

  /// 다음 퀴즈로 이동
  void moveToNextQuiz() {
    if (!state.hasNextQuiz || state.currentQuizSession == null) return;

    final nextIndex = state.currentQuizSession!.currentQuizIndex + 1;
    if (nextIndex < state.currentQuizSession!.quizList.length) {
      final nextQuizId = state.currentQuizSession!.quizList[nextIndex].id;

      state = state.copyWith(
        currentQuizSession: state.currentQuizSession!.copyWith(
          currentQuizId: nextQuizId,
        ),
      );

      debugPrint('➡️ [QUIZ_NOTIFIER] 다음 퀴즈로 이동 - 인덱스: $nextIndex');
    }
  }

  /// 이전 퀴즈로 이동
  void moveToPreviousQuiz() {
    if (!state.hasPreviousQuiz || state.currentQuizSession == null) return;

    final prevIndex = state.currentQuizSession!.currentQuizIndex - 1;
    if (prevIndex >= 0) {
      final prevQuizId = state.currentQuizSession!.quizList[prevIndex].id;

      state = state.copyWith(
        currentQuizSession: state.currentQuizSession!.copyWith(
          currentQuizId: prevQuizId,
        ),
      );

      debugPrint('⬅️ [QUIZ_NOTIFIER] 이전 퀴즈로 이동 - 인덱스: $prevIndex');
    }
  }

  /// 특정 퀴즈로 이동
  void moveToQuiz(int index) {
    if (state.currentQuizSession == null ||
        index < 0 ||
        index >= state.currentQuizSession!.totalCount) {
      return;
    }

    final quizId = state.currentQuizSession!.quizList[index].id;

    state = state.copyWith(
      currentQuizSession: state.currentQuizSession!.copyWith(
        currentQuizId: quizId,
      ),
    );

    debugPrint('🎯 [QUIZ_NOTIFIER] 퀴즈 이동 - 인덱스: $index');
  }

  // === 퀴즈 완료 ===

  /// 퀴즈 완료 처리
  Future<QuizResult?> completeQuiz() async {
    if (state.currentQuizSession == null || state.isReadOnlyMode) {
      return null;
    }

    state = state.copyWith(isSubmittingAnswer: true);

    try {
      final chapterId = state.currentQuizSession!.chapterId;
      final result = await _repository.completeQuiz(chapterId);

      debugPrint(
          '✅ [QUIZ_NOTIFIER] 퀴즈 완료 - 점수: ${result.score}/${result.totalScore}, 합격: ${result.isPassed}');

      // 타이머 정지
      _stopTimer();

      // 퀴즈 결과 목록에 추가
      final updatedResults = <QuizResult>[...state.quizResults, result];

      state = state.copyWith(
        currentQuizSession: null,
        quizResults: updatedResults,
        isSubmittingAnswer: false,
        isTimerRunning: false,
        remainingSeconds: 0,
      );

      // 퀴즈 완료 콜백 호출
      for (final callback in _onQuizCompletedCallbacks) {
        try {
          callback(chapterId, result);
        } catch (e) {
          debugPrint('❌ [QUIZ_NOTIFIER] 퀴즈 완료 콜백 실행 실패: $e');
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ [QUIZ_NOTIFIER] 퀴즈 완료 실패: $e');

      final errorMessage = ErrorMessageExtractor.extractSubmissionError(e, '퀴즈 완료');

      state = state.copyWith(
        isSubmittingAnswer: false,
        quizError: errorMessage,
      );
      return null;
    }
  }

  /// 퀴즈 종료 (완료하지 않고 나가기)
  void exitQuiz() {
    debugPrint('🔚 [QUIZ_NOTIFIER] 퀴즈 종료');
    _stopTimer();
    state = state.copyWith(
      currentQuizSession: null,
      quizError: null,
      isReadOnlyMode: false,
      isTimerRunning: false,
      remainingSeconds: 0,
    );
  }

  // === 퀴즈 결과 ===

  /// 퀴즈 결과 목록 로드
  Future<void> loadQuizResults({bool forceRefresh = false}) async {
    if (state.isLoadingResults) return;

    debugPrint(
        '📊 [QUIZ_NOTIFIER] 퀴즈 결과 로드 시작 (forceRefresh: $forceRefresh)');
    state = state.copyWith(
      isLoadingResults: true,
      resultsError: null,
    );

    try {
      final results = await _repository.getQuizResults(forceRefresh: forceRefresh);

      // 최신순 정렬
      final resultsList = List<QuizResult>.from(results);
      resultsList.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      state = state.copyWith(
        quizResults: resultsList,
        isLoadingResults: false,
        resultsError: null,
      );

      debugPrint('✅ [QUIZ_NOTIFIER] 퀴즈 결과 로드 성공 - 총 ${results.length}개');
    } catch (e) {
      debugPrint('❌ [QUIZ_NOTIFIER] 퀴즈 결과 로드 실패: $e');

      final errorMessage = ErrorMessageExtractor.extractDataLoadError(e, '퀴즈 결과');

      state = state.copyWith(
        isLoadingResults: false,
        resultsError: errorMessage,
      );
    }
  }

  /// 특정 챕터의 최신 퀴즈 결과 조회
  QuizResult? getLatestQuizResult(int chapterId) {
    try {
      final results = state.quizResults
          .where((result) => result.chapterId == chapterId)
          .toList();

      if (results.isEmpty) return null;

      // 최신 결과 반환
      results.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return results.first;
    } catch (e) {
      debugPrint('❌ [QUIZ_NOTIFIER] 최신 퀴즈 결과 조회 실패: $e');
      return null;
    }
  }

  // === 오답노트 관리 ===

  /// 오답노트에서 제거 (정답 처리 후)
  Future<bool> removeFromWrongNotes(int wrongNoteId) async {
    try {
      await _repository.removeWrongNote(wrongNoteId);

      debugPrint('✅ [QUIZ_NOTIFIER] 오답노트 제거 성공 - ID: $wrongNoteId');

      // 오답노트 제거 콜백 호출
      for (final callback in _onWrongNoteRemovedCallbacks) {
        try {
          callback(wrongNoteId);
        } catch (e) {
          debugPrint('❌ [QUIZ_NOTIFIER] 오답노트 제거 콜백 실행 실패: $e');
        }
      }

      return true;
    } catch (e) {
      debugPrint('❌ [QUIZ_NOTIFIER] 오답노트 제거 실패: $e');
      return false;
    }
  }

  // === 타이머 관리 ===

  /// 타이머 시작
  void _startTimer(Duration timeLimit) {
    _stopTimer();

    state = state.copyWith(
      isTimerRunning: true,
      remainingSeconds: timeLimit.inSeconds,
    );

    debugPrint('⏰ [QUIZ_NOTIFIER] 타이머 시작 - ${timeLimit.inMinutes}분');

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      } else {
        _stopTimer();
        debugPrint('⏰ [QUIZ_NOTIFIER] 타이머 종료 - 시간 초과');
      }
    });
  }

  /// 타이머 정지
  void _stopTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
      state = state.copyWith(
        isTimerRunning: false,
      );
      debugPrint('⏰ [QUIZ_NOTIFIER] 타이머 정지');
    }
  }

  /// 타이머 일시정지/재개
  void toggleTimer() {
    if (state.isTimerRunning) {
      _timer?.cancel();
      state = state.copyWith(isTimerRunning: false);
      debugPrint('⏸️ [QUIZ_NOTIFIER] 타이머 일시정지');
    } else if (state.remainingSeconds > 0) {
      _startTimer(Duration(seconds: state.remainingSeconds));
      debugPrint('▶️ [QUIZ_NOTIFIER] 타이머 재개');
    }
  }

  // === 캐시 관리 ===

  /// 전체 캐시 삭제
  Future<void> clearCache() async {
    debugPrint('🧹 [QUIZ_NOTIFIER] 캐시 삭제 시작');
    _stopTimer();
    await _repository.clearCache();

    state = const QuizState();
    debugPrint('🧹 [QUIZ_NOTIFIER] 메모리 상태 초기화 완료');
  }
}
