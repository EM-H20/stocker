/// 학습 진도 관련 데이터를 관리하는 Repository 인터페이스
abstract class LearningProgressRepository {
  /// 마지막 학습 위치 조회
  Future<Map<String, dynamic>?> getLastLearningPosition();

  /// 마지막 학습 위치 저장
  Future<void> saveLastLearningPosition({
    required int chapterId,
    required String step,
  });

  /// 완료된 챕터 목록 조회
  Future<List<int>> getCompletedChapters();

  /// 챕터 완료 표시
  Future<void> markChapterCompleted(int chapterId);

  /// 완료된 퀴즈 목록 조회
  Future<List<int>> getCompletedQuizzes();

  /// 퀴즈 완료 표시
  Future<void> markQuizCompleted(int chapterId);

  /// 학습한 날짜 목록 조회
  Future<Set<String>> getStudiedDates();

  /// 오늘 학습 기록 추가
  Future<void> addTodayStudyRecord();

  /// 전체 진도 초기화
  Future<void> resetProgress();

  /// 사용 가능한 챕터 목록 조회 (제목 포함)
  Future<List<Map<String, dynamic>>> getAvailableChapters();
}
