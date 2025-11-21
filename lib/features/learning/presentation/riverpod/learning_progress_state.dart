import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_progress_state.freezed.dart';

/// 🔥 Riverpod 학습 진도 상태 클래스 (Freezed)
@freezed
class LearningProgressState with _$LearningProgressState {
  const factory LearningProgressState({
    /// 마지막으로 학습한 챕터 ID
    @Default(1) int lastChapterId,

    /// 마지막으로 학습한 단계 ('theory', 'quiz', 'result')
    @Default('theory') String lastStep,

    /// 챕터별 완료 상태 {chapterId: isCompleted}
    @Default({}) Map<int, bool> completedChapters,

    /// 퀴즈별 완료 상태 {chapterId: isCompleted}
    @Default({}) Map<int, bool> completedQuizzes,

    /// 학습한 날짜들 (연속 학습일 계산용) 'yyyy-MM-dd' 형태
    @Default({}) Set<String> studiedDates,

    /// 사용 가능한 챕터 목록 (Repository에서 조회)
    @Default([]) List<Map<String, dynamic>> availableChapters,

    /// 초기화 완료 여부
    @Default(false) bool isInitialized,

    /// 로딩 중
    @Default(false) bool isLoading,

    /// 에러 메시지
    String? errorMessage,
  }) = _LearningProgressState;

  const LearningProgressState._();

  // === Computed Getters (Helper Methods) ===

  /// 에러 존재 여부
  bool get hasError => errorMessage != null;

  /// 완료된 챕터 수
  int get completedChaptersCount =>
      completedChapters.values.where((v) => v).length;

  /// 완료된 퀴즈 수
  int get completedQuizzesCount =>
      completedQuizzes.values.where((v) => v).length;

  /// 전체 진도율 (0.0 ~ 1.0)
  double getOverallProgress({int totalChapters = 10}) {
    if (totalChapters == 0) return 0.0;
    return completedChaptersCount / totalChapters;
  }

  /// 현재 챕터의 진도율
  double getCurrentChapterProgress() {
    switch (lastStep) {
      case 'theory':
        return 0.33;
      case 'quiz':
        return 0.66;
      case 'result':
        return 1.0;
      default:
        return 0.0;
    }
  }

  /// 연속 학습일 계산
  int getStudyStreak() {
    if (studiedDates.isEmpty) return 0;

    final today = DateTime.now();
    int streak = 0;
    DateTime checkDate = today;

    // 오늘부터 거꾸로 세면서 연속일 계산
    while (true) {
      final checkDateStr =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

      if (studiedDates.contains(checkDateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// 다음에 학습할 챕터 추천
  int getRecommendedNextChapter({int maxChapters = 10}) {
    // 현재 챕터가 완료되었으면 다음 챕터
    if (completedChapters[lastChapterId] == true) {
      return (lastChapterId + 1).clamp(1, maxChapters);
    }

    // 아니면 현재 챕터 계속
    return lastChapterId;
  }

  /// 특정 챕터 완료 여부 확인
  bool isChapterCompleted(int chapterId) =>
      completedChapters[chapterId] == true;

  /// 특정 퀴즈 완료 여부 확인
  bool isQuizCompleted(int chapterId) => completedQuizzes[chapterId] == true;

  /// 챕터 제목 가져오기
  String getChapterTitle(int chapterId) {
    try {
      final chapter = availableChapters.firstWhere(
        (chapter) => chapter['id'] == chapterId,
        orElse: () => <String, Object>{},
      );

      if (chapter.isNotEmpty) {
        return chapter['title'] as String;
      }

      return 'Chapter $chapterId';
    } catch (e) {
      return 'Chapter $chapterId';
    }
  }

  /// 챕터 설명 가져오기
  String getChapterDescription(int chapterId) {
    try {
      final chapter = availableChapters.firstWhere(
        (chapter) => chapter['id'] == chapterId,
        orElse: () => <String, Object>{},
      );

      if (chapter.isNotEmpty) {
        return chapter['description'] as String? ??
            '${getChapterTitle(chapterId)} 학습 내용';
      }

      return 'Chapter $chapterId 학습 내용';
    } catch (e) {
      return 'Chapter $chapterId 학습 내용';
    }
  }
}
