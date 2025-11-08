import 'package:flutter/foundation.dart';
import '../domain/education_repository.dart';
import '../domain/education_mock_repository.dart';
import '../domain/models/chapter_info.dart';
import '../domain/models/theory_info.dart';
import '../domain/models/theory_session.dart';

/// Education 기능의 상태관리 Provider
/// ChangeNotifier를 상속하여 UI 상태 변화를 관리
class EducationProvider extends ChangeNotifier {
  final EducationRepository? _repository;
  final EducationMockRepository? _mockRepository;
  final bool _useMock;

  // 챕터 완료 시 호출될 콜백 함수들
  final List<Function(int chapterId)> _onChapterCompletedCallbacks = [];

  /// 실제 API Repository를 사용하는 생성자
  EducationProvider(EducationRepository repository)
      : _repository = repository,
        _mockRepository = null,
        _useMock = false;

  /// Mock Repository를 사용하는 생성자 (UI 개발/테스트용)
  EducationProvider.withMock(EducationMockRepository mockRepository)
      : _repository = null,
        _mockRepository = mockRepository,
        _useMock = true;

  /// 챕터 완료 콜백 등록
  void addOnChapterCompletedCallback(Function(int chapterId) callback) {
    _onChapterCompletedCallbacks.add(callback);
  }

  /// 챕터 완료 콜백 해제
  void removeOnChapterCompletedCallback(Function(int chapterId) callback) {
    _onChapterCompletedCallbacks.remove(callback);
  }

  // === 챕터 관련 상태 ===
  List<ChapterInfo> _chapters = [];
  bool _isLoadingChapters = false;
  String? _chaptersError;

  // === 이론 관련 상태 ===
  TheorySession? _currentTheorySession;
  bool _isLoadingTheory = false;
  String? _theoryError;

  // === 진도 관리 상태 ===
  bool _isUpdatingProgress = false;
  bool _isCompletingTheory = false;

  // === 선택된 챕터 상태 ===
  int? _selectedChapterId;

  // === Getters ===

  /// 챕터 목록
  List<ChapterInfo> get chapters => _chapters;

  /// 챕터 로딩 상태
  bool get isLoadingChapters => _isLoadingChapters;

  /// 챕터 에러 메시지
  String? get chaptersError => _chaptersError;

  /// 인증 에러 여부 확인 (401 Unauthorized)
  bool get isAuthenticationError =>
      _chaptersError?.contains('로그인이 필요한 서비스입니다') ?? false;

  /// 현재 이론 세션 데이터
  TheorySession? get currentTheorySession => _currentTheorySession;

  /// 현재 이론 객체
  TheoryInfo? get currentTheory => _currentTheorySession?.currentTheory;

  /// 현재 이론 인덱스
  int get currentTheoryIndex => _currentTheorySession?.currentTheoryIndex ?? 0;

  /// 전체 이론 개수
  int get totalTheoryCount => _currentTheorySession?.totalCount ?? 0;

  /// 이론 로딩 상태
  bool get isLoadingTheory => _isLoadingTheory;

  /// 이론 에러 메시지
  String? get theoryError => _theoryError;

  /// 진도 업데이트 중 여부
  bool get isUpdatingProgress => _isUpdatingProgress;

  /// 이론 완료 처리 중 여부
  bool get isCompletingTheory => _isCompletingTheory;

  /// 다음 이론이 있는지 확인
  bool get hasNextTheory => _currentTheorySession?.hasNext ?? false;

  /// 이전 이론이 있는지 확인
  bool get hasPreviousTheory => _currentTheorySession?.hasPrevious ?? false;

  /// 현재 진행률 (0.0 ~ 1.0)
  double get progressRatio => _currentTheorySession?.progressRatio ?? 0.0;

  /// 선택된 챕터 ID
  int? get selectedChapterId => _selectedChapterId;

  /// 선택된 챕터 정보 (없으면 null)
  ChapterInfo? get selectedChapter =>
      _selectedChapterId != null ? getChapterById(_selectedChapterId!) : null;

  /// 선택된 챕터가 있는지 확인
  bool get hasSelectedChapter => _selectedChapterId != null;

  /// 전체 교육 과정 통합 진행률 (0.0 ~ 1.0)
  /// 진행률 = (이론 완료 챕터 수 + 퀴즈 완료 챕터 수) / (전체 챕터 수 × 2)
  double get globalProgressRatio {
    if (_chapters.isEmpty) return 0.0;

    final totalTasks = _chapters.length * 2; // 각 챕터당 이론 + 퀴즈 = 2개 작업
    final completedTasks = getCompletedTaskCount();

    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// 완료된 챕터 수 조회
  int getCompletedChapterCount() {
    return _chapters.where((chapter) => chapter.isChapterCompleted).length;
  }

  /// 챕터별 완료율 (0.0 ~ 1.0)
  /// 전체 챕터 중 완료된 챕터 비율
  double get chapterCompletionRatio {
    if (_chapters.isEmpty) return 0.0;
    return getCompletedChapterCount() / _chapters.length;
  }

  /// 챕터 완료율을 백분율로 반환
  double get chapterCompletionPercentage => chapterCompletionRatio * 100;

  /// 전체 작업 개수 조회 (챕터 수 × 2)
  int getTotalTaskCount() {
    return _chapters.length * 2; // 각 챕터당 이론 + 퀴즈
  }

  /// 완료된 작업 개수 조회 (완료된 이론 + 완료된 퀴즈)
  int getCompletedTaskCount() {
    int completedTheories =
        _chapters.where((chapter) => chapter.isTheoryCompleted).length;
    int completedQuizzes =
        _chapters.where((chapter) => chapter.isQuizCompleted).length;
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
        _chapters.where((chapter) => chapter.isTheoryCompleted).length;
    final completedQuizzes =
        _chapters.where((chapter) => chapter.isQuizCompleted).length;
    final totalChapters = _chapters.length;
    return '이론: $completedTheories/$totalChapters, 퀴즈: $completedQuizzes/$totalChapters';
  }

  // === 챕터 관련 메서드 ===

  /// 챕터 목록 로드
  ///
  /// [forceRefresh]: 강제 새로고침 여부
  Future<void> loadChapters({bool forceRefresh = false}) async {
    if (_isLoadingChapters) {
      debugPrint('⚠️ [EDU_PROVIDER] 이미 챕터 로딩 중...');
      return;
    }

    debugPrint(
        '🔄 [EDU_PROVIDER] 챕터 목록 로드 시작 (useMock: $_useMock, forceRefresh: $forceRefresh)');
    _isLoadingChapters = true;
    _chaptersError = null;
    notifyListeners();

    try {
      if (_useMock) {
        debugPrint('🎭 [EDU_PROVIDER] Mock Repository 사용');
        _chapters = await _mockRepository!.getChaptersForUser();
        debugPrint(
            '🎭 [EDU_PROVIDER] Mock 데이터 로드됨: ${_chapters.map((c) => c.title).toList()}');
      } else {
        debugPrint('🌐 [EDU_PROVIDER] Real API Repository 사용');
        debugPrint('🌐 [EDU_PROVIDER] Repository instance: $_repository');
        debugPrint('🌐 [EDU_PROVIDER] ForceRefresh: $forceRefresh');
        _chapters = await _repository!.getChapters(forceRefresh: forceRefresh);
        debugPrint(
            '🌐 [EDU_PROVIDER] Real API 데이터 로드됨: ${_chapters.map((c) => c.title).toList()}');
      }

      debugPrint('✅ [EDU_PROVIDER] 챕터 로드 성공 - 총 ${_chapters.length}개 챕터');
      _chaptersError = null;
    } catch (e) {
      debugPrint('❌ [EDU_PROVIDER] 챕터 로드 실패: $e');

      // 🔐 401 Unauthorized 에러 처리 (로그인 필요)
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized') ||
          e.toString().contains('토큰이 제공되지 않았습니다')) {
        _chaptersError = '로그인이 필요한 서비스입니다. 로그인 후 다시 시도해주세요.';
        debugPrint('🔐 [EDU_PROVIDER] 401 Unauthorized - 로그인 필요');
      }
      // 🌐 네트워크 관련 에러
      else if (e.toString().contains('No host specified') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('timeout')) {
        _chaptersError = '네트워크 연결에 문제가 있습니다. 연결 상태를 확인하고 다시 시도해주세요.';
        debugPrint('🌐 [EDU_PROVIDER] 네트워크 연결 문제 감지');
        debugPrint('🔧 [EDU_PROVIDER] .env 파일과 dio 설정을 확인하세요');
      }
      // 🚨 기타 에러
      else {
        _chaptersError = '챕터 정보를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.';
        debugPrint('🚨 [EDU_PROVIDER] 예상치 못한 에러: $e');
      }

      // 에러 발생시 챕터 리스트 비우기
      _chapters.clear();
    } finally {
      _isLoadingChapters = false;
      debugPrint('🏁 [EDU_PROVIDER] 챕터 로드 프로세스 완료');
      notifyListeners();
    }
  }

  /// 특정 챕터 조회
  ///
  /// [chapterId]: 조회할 챕터 ID
  /// Returns: 해당 챕터 정보 (없으면 null)
  ChapterInfo? getChapterById(int chapterId) {
    try {
      return _chapters.firstWhere((chapter) => chapter.id == chapterId);
    } catch (e) {
      return null;
    }
  }

  /// 챕터 선택
  ///
  /// [chapterId]: 선택할 챕터 ID
  void selectChapter(int chapterId) {
    debugPrint('📌 [EDU_PROVIDER] 챕터 선택: $chapterId');
    final chapter = getChapterById(chapterId);
    if (chapter != null) {
      _selectedChapterId = chapterId;
      debugPrint('✅ [EDU_PROVIDER] 챕터 선택 완료: ${chapter.title}');
      notifyListeners();
    } else {
      debugPrint('❌ [EDU_PROVIDER] 존재하지 않는 챕터 ID: $chapterId');
    }
  }

  /// 챕터 선택 해제
  void clearSelectedChapter() {
    debugPrint('🔄 [EDU_PROVIDER] 챕터 선택 해제');
    _selectedChapterId = null;
    notifyListeners();
  }

  // === 이론 관련 메서드 ===

  /// 이론 진입
  ///
  /// [chapterId]: 진입할 챕터 ID
  Future<bool> enterTheory(int chapterId) async {
    if (_isLoadingTheory) return false;

    debugPrint(
        '🎓 [EDU_PROVIDER] 이론 진입 요청 - 챕터 ID: $chapterId (useMock: $_useMock)');
    _isLoadingTheory = true;
    _theoryError = null;
    notifyListeners();

    try {
      if (_useMock) {
        debugPrint('🎭 [EDU_PROVIDER] Mock Repository로 이론 진입 중...');
        _currentTheorySession = await _mockRepository!.enterTheory(chapterId);
        // Mock에서는 진도 저장 기능 없음
      } else {
        debugPrint('🌐 [EDU_PROVIDER] Real API Repository로 이론 진입 중...');
        _currentTheorySession = await _repository!.enterTheory(chapterId);

        // 저장된 진도가 있으면 해당 위치로 이동
        final savedProgress = await _repository.getTheoryProgress(chapterId);
        if (savedProgress != null && _currentTheorySession != null) {
          debugPrint('📚 [EDU_PROVIDER] 저장된 진도 발견 - 이론 ID: $savedProgress');
          _currentTheorySession = _currentTheorySession!.copyWith(
            currentTheoryIndex: _findTheoryIndexById(savedProgress),
          );
        }
      }

      debugPrint(
          '✅ [EDU_PROVIDER] 이론 진입 성공 - 총 ${_currentTheorySession?.totalCount ?? 0}개 이론');
      _theoryError = null;
      return true;
    } catch (e) {
      _theoryError = e.toString();
      debugPrint('❌ [EDU_PROVIDER] 이론 진입 실패 - 챕터 ID: $chapterId, 에러: $e');
      return false;
    } finally {
      _isLoadingTheory = false;
      notifyListeners();
    }
  }

  /// 다음 이론으로 이동
  Future<void> moveToNextTheory() async {
    if (!hasNextTheory || _currentTheorySession == null) return;

    _currentTheorySession = _currentTheorySession!.copyWith(
      currentTheoryIndex: _currentTheorySession!.currentTheoryIndex + 1,
    );
    notifyListeners();

    // 서버에 진도 업데이트
    await _updateProgressToServer();
  }

  /// 이전 이론으로 이동
  Future<void> moveToPreviousTheory() async {
    if (!hasPreviousTheory || _currentTheorySession == null) return;

    _currentTheorySession = _currentTheorySession!.copyWith(
      currentTheoryIndex: _currentTheorySession!.currentTheoryIndex - 1,
    );
    notifyListeners();

    // 서버에 진도 업데이트
    await _updateProgressToServer();
  }

  /// 특정 이론으로 이동
  ///
  /// [index]: 이동할 이론의 인덱스
  Future<void> moveToTheoryByIndex(int index) async {
    if (_currentTheorySession == null ||
        index < 0 ||
        index >= _currentTheorySession!.totalCount) {
      return;
    }

    _currentTheorySession = _currentTheorySession!.copyWith(
      currentTheoryIndex: index,
    );
    notifyListeners();

    // 서버에 진도 업데이트
    await _updateProgressToServer();
  }

  /// 이론 완료 처리
  Future<bool> completeTheory() async {
    if (_isCompletingTheory || _currentTheorySession == null) return false;

    _isCompletingTheory = true;
    notifyListeners();

    try {
      final chapterId = _currentTheorySession!.chapterId;

      if (_useMock) {
        await _mockRepository!.completeTheory(chapterId);
      } else {
        await _repository!.completeTheory(chapterId);
      }

      // 로컬 상태 업데이트: 이론 완료
      _updateLocalChapterCompletion(chapterId, isTheoryCompleted: true);

      // 챕터 완료 상태 확인 및 업데이트
      _checkAndUpdateChapterCompletion(chapterId);

      // 현재 이론 데이터 초기화
      _currentTheorySession = null;

      return true;
    } catch (e) {
      _theoryError = e.toString();
      debugPrint('이론 완료 처리 실패: $e');
      return false;
    } finally {
      _isCompletingTheory = false;
      notifyListeners();
    }
  }

  /// 이론 학습 종료 (완료하지 않고 나가기)
  void exitTheory() {
    _currentTheorySession = null;
    _theoryError = null;
    notifyListeners();
  }

  // === 캐시 관리 ===

  /// 전체 캐시 삭제
  Future<void> clearCache() async {
    debugPrint('🧹 [EDU_PROVIDER] 캐시 삭제 시작 (useMock: $_useMock)');
    if (!_useMock) {
      debugPrint('🧹 [EDU_PROVIDER] Real Repository 캐시 삭제 중...');
      await _repository!.clearCache();
    } else {
      debugPrint('🧹 [EDU_PROVIDER] Mock 모드에서는 캐시 삭제 기능 없음');
    }
    // 메모리 상태 초기화
    _chapters.clear();
    _currentTheorySession = null;
    _chaptersError = null;
    _theoryError = null;
    debugPrint('🧹 [EDU_PROVIDER] 메모리 상태 초기화 완료');
    notifyListeners();
  }

  // === Private Helper Methods ===

  /// 서버에 진도 업데이트
  Future<void> _updateProgressToServer() async {
    if (_currentTheorySession == null || _isUpdatingProgress) return;

    _isUpdatingProgress = true;

    try {
      final currentTheory = this.currentTheory;
      if (currentTheory != null) {
        if (_useMock) {
          // Mock에서는 진도 업데이트 기능 없음
          debugPrint(
            'Mock: 진도 업데이트 - 챕터: ${_currentTheorySession!.chapterId}, 이론: ${currentTheory.id}',
          );
        } else {
          await _repository!.updateTheoryProgress(
            _currentTheorySession!.chapterId,
            currentTheory.id,
          );
        }
      }
    } catch (e) {
      debugPrint('진도 업데이트 실패: $e');
      // 진도 업데이트 실패는 사용자에게 알리지 않음 (백그라운드 작업)
    } finally {
      _isUpdatingProgress = false;
    }
  }

  /// 특정 이론 ID로 인덱스 찾기
  int _findTheoryIndexById(int theoryId) {
    if (_currentTheorySession == null) return 0;

    final index = _currentTheorySession!.theories.indexWhere(
      (theory) => theory.id == theoryId,
    );

    return index >= 0 ? index : 0;
  }

  /// 현재 이론 인덱스 설정
  void setCurrentTheoryIndex(int index) {
    if (_currentTheorySession != null &&
        index >= 0 &&
        index < _currentTheorySession!.theories.length) {
      _currentTheorySession = _currentTheorySession!.copyWith(
        currentTheoryIndex: index,
      );
      notifyListeners();
    }
  }

  /// 로컬 챕터 완료 상태 업데이트
  void _updateLocalChapterCompletion(
    int chapterId, {
    bool? isTheoryCompleted,
    bool? isQuizCompleted,
    bool? isChapterCompleted,
  }) {
    final chapterIndex = _chapters.indexWhere((c) => c.id == chapterId);
    if (chapterIndex >= 0) {
      _chapters[chapterIndex] = _chapters[chapterIndex].copyWith(
        isTheoryCompleted: isTheoryCompleted,
        isQuizCompleted: isQuizCompleted,
        isChapterCompleted: isChapterCompleted,
      );
    }
  }

  /// 퀴즈 완료 상태 업데이트 (QuizProvider에서 호출됨)
  void updateQuizCompletion(int chapterId, {required bool isPassed}) {
    debugPrint(
        '🎯 [EDU_PROVIDER] 퀴즈 완료 상태 업데이트 - 챕터 $chapterId (합격: $isPassed)');

    // 로컬 상태 업데이트
    _updateLocalChapterCompletion(chapterId, isQuizCompleted: isPassed);

    // 챕터 완료 상태 확인 및 업데이트
    _checkAndUpdateChapterCompletion(chapterId);

    notifyListeners();
  }

  /// 챕터 완료 상태 확인 및 업데이트
  /// 이론과 퀴즈가 모두 완료된 경우 챕터를 완료 상태로 변경
  void _checkAndUpdateChapterCompletion(int chapterId) {
    final chapterIndex = _chapters.indexWhere((c) => c.id == chapterId);
    if (chapterIndex >= 0) {
      final chapter = _chapters[chapterIndex];

      // 이론과 퀴즈가 모두 완료된 경우에만 챕터 완료
      if (chapter.isTheoryCompleted && chapter.isQuizCompleted) {
        debugPrint(
            '🎉 [EDU_PROVIDER] 챕터 완료! ID: $chapterId, Title: ${chapter.title}');
        _updateLocalChapterCompletion(chapterId, isChapterCompleted: true);

        // 챕터 완료 콜백 호출 (LearningProgressProvider 등에 알림)
        for (final callback in _onChapterCompletedCallbacks) {
          try {
            callback(chapterId);
          } catch (e) {
            debugPrint('❌ [EDU_PROVIDER] 챕터 완료 콜백 실행 실패: $e');
          }
        }

        debugPrint('✅ [EDU_PROVIDER] 챕터 완료 상태 백엔드 업데이트 요청 완료');
      } else {
        debugPrint(
            '⏳ [EDU_PROVIDER] 챕터 미완료 - 이론: ${chapter.isTheoryCompleted}, 퀴즈: ${chapter.isQuizCompleted}');
      }
    }
  }

  @override
  void dispose() {
    // Provider 해제 시 정리 작업
    super.dispose();
  }
}
