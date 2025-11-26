import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/chapter_info.dart';
import '../../domain/models/theory_session.dart';
import '../../domain/models/theory_info.dart';

part 'education_state.freezed.dart';

/// 🔥 Riverpod 교육 상태 클래스 (Freezed)
@freezed
class EducationState with _$EducationState {
  const factory EducationState({
    /// 챕터 목록
    @Default([]) List<ChapterInfo> chapters,

    /// 현재 이론 세션
    TheorySession? currentTheorySession,

    /// 선택된 챕터 ID
    int? selectedChapterId,

    /// 검색어 (실시간 검색용)
    @Default('') String searchQuery,

    /// 챕터 로딩 중
    @Default(false) bool isLoadingChapters,

    /// 이론 로딩 중
    @Default(false) bool isLoadingTheory,

    /// 진도 업데이트 중
    @Default(false) bool isUpdatingProgress,

    /// 이론 완료 처리 중
    @Default(false) bool isCompletingTheory,

    /// 챕터 에러 메시지
    String? chaptersError,

    /// 이론 에러 메시지
    String? theoryError,
  }) = _EducationState;

  const EducationState._();

  // === Computed Getters (Helper Methods) ===

  /// 인증 에러 여부 확인 (401 Unauthorized)
  bool get isAuthenticationError =>
      chaptersError?.contains('로그인이 필요한 서비스입니다') ?? false;

  /// 현재 이론 객체
  TheoryInfo? get currentTheory => currentTheorySession?.currentTheory;

  /// 현재 이론 인덱스
  int get currentTheoryIndex => currentTheorySession?.currentTheoryIndex ?? 0;

  /// 전체 이론 개수
  int get totalTheoryCount => currentTheorySession?.totalCount ?? 0;

  /// 다음 이론이 있는지 확인
  bool get hasNextTheory => currentTheorySession?.hasNext ?? false;

  /// 이전 이론이 있는지 확인
  bool get hasPreviousTheory => currentTheorySession?.hasPrevious ?? false;

  /// 현재 진행률 (0.0 ~ 1.0)
  double get progressRatio => currentTheorySession?.progressRatio ?? 0.0;

  /// 선택된 챕터 정보 (없으면 null)
  ChapterInfo? getSelectedChapter() =>
      selectedChapterId != null ? getChapterById(selectedChapterId!) : null;

  /// 선택된 챕터가 있는지 확인
  bool get hasSelectedChapter => selectedChapterId != null;

  /// 특정 챕터 조회
  ChapterInfo? getChapterById(int chapterId) {
    try {
      return chapters.firstWhere((chapter) => chapter.id == chapterId);
    } catch (e) {
      return null;
    }
  }

  /// 전체 교육 과정 통합 진행률 (0.0 ~ 1.0)
  /// 진행률 = (이론 완료 챕터 수 + 퀴즈 완료 챕터 수) / (전체 챕터 수 × 2)
  double get globalProgressRatio {
    if (chapters.isEmpty) return 0.0;

    final totalTasks = chapters.length * 2; // 각 챕터당 이론 + 퀴즈 = 2개 작업
    final completedTasks = getCompletedTaskCount();

    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// 완료된 챕터 수 조회
  int getCompletedChapterCount() {
    return chapters.where((chapter) => chapter.isChapterCompleted).length;
  }

  /// 챕터별 완료율 (0.0 ~ 1.0)
  double get chapterCompletionRatio {
    if (chapters.isEmpty) return 0.0;
    return getCompletedChapterCount() / chapters.length;
  }

  /// 챕터 완료율을 백분율로 반환
  double get chapterCompletionPercentage => chapterCompletionRatio * 100;

  /// 전체 작업 개수 조회 (챕터 수 × 2)
  int getTotalTaskCount() {
    return chapters.length * 2; // 각 챕터당 이론 + 퀴즈
  }

  /// 완료된 작업 개수 조회 (완료된 이론 + 완료된 퀴즈)
  int getCompletedTaskCount() {
    int completedTheories =
        chapters.where((chapter) => chapter.isTheoryCompleted).length;
    int completedQuizzes =
        chapters.where((chapter) => chapter.isQuizCompleted).length;
    return completedTheories + completedQuizzes;
  }

  /// 전체 진행률을 백분율로 반환
  double get globalProgressPercentage => globalProgressRatio * 100;

  /// 현재 전체 진행 상황 요약
  String get globalProgressSummary {
    final completed = getCompletedTaskCount();
    final total = getTotalTaskCount();
    return '$completed / $total 작업 완료';
  }

  /// 상세 진행 상황 요약
  String get detailedProgressSummary {
    final completedTheories =
        chapters.where((chapter) => chapter.isTheoryCompleted).length;
    final completedQuizzes =
        chapters.where((chapter) => chapter.isQuizCompleted).length;
    final totalChapters = chapters.length;
    return '이론: $completedTheories/$totalChapters, 퀴즈: $completedQuizzes/$totalChapters';
  }

  /// 검색어로 필터링된 챕터 목록
  /// searchQuery가 비어있으면 전체 챕터 반환
  /// title, description, keyword 중 하나라도 검색어가 포함된 챕터 반환
  List<ChapterInfo> get filteredChapters {
    if (searchQuery.isEmpty) return chapters;

    final query = searchQuery.toLowerCase();
    return chapters.where((chapter) {
      final titleMatch = chapter.title.toLowerCase().contains(query);
      final descMatch =
          chapter.description?.toLowerCase().contains(query) ?? false;
      final keywordMatch =
          chapter.keyword?.toLowerCase().contains(query) ?? false;
      return titleMatch || descMatch || keywordMatch;
    }).toList();
  }

  /// 검색 결과가 있는지 확인
  bool get hasSearchResults => filteredChapters.isNotEmpty;

  /// 검색 중인지 확인
  bool get isSearching => searchQuery.isNotEmpty;
}
