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

  // === Getters ===

  /// 챕터 목록
  List<ChapterInfo> get chapters => _chapters;

  /// 챕터 로딩 상태
  bool get isLoadingChapters => _isLoadingChapters;

  /// 챕터 에러 메시지
  String? get chaptersError => _chaptersError;

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

  /// 전체 교육 과정 통합 진행률 (0.0 ~ 1.0)
  /// 진행률 = (이론 완료 챕터 수 + 퀴즈 완료 챕터 수) / (전체 챕터 수 × 2)
  double get globalProgressRatio {
    if (_chapters.isEmpty) return 0.0;
    
    final totalTasks = _chapters.length * 2; // 각 챕터당 이론 + 퀴즈 = 2개 작업
    final completedTasks = getCompletedTaskCount();
    
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// 전체 작업 개수 조회 (챕터 수 × 2)
  int getTotalTaskCount() {
    return _chapters.length * 2; // 각 챕터당 이론 + 퀴즈
  }

  /// 완료된 작업 개수 조회 (완료된 이론 + 완료된 퀴즈)
  int getCompletedTaskCount() {
    int completedTheories = _chapters.where((chapter) => chapter.isTheoryCompleted).length;
    int completedQuizzes = _chapters.where((chapter) => chapter.isQuizCompleted).length;
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
    final completedTheories = _chapters.where((chapter) => chapter.isTheoryCompleted).length;
    final completedQuizzes = _chapters.where((chapter) => chapter.isQuizCompleted).length;
    final totalChapters = _chapters.length;
    return '이론: $completedTheories/$totalChapters, 퀴즈: $completedQuizzes/$totalChapters';
  }

  // === 챕터 관련 메서드 ===

  /// 챕터 목록 로드
  ///
  /// [forceRefresh]: 강제 새로고침 여부
  Future<void> loadChapters({bool forceRefresh = false}) async {
    if (_isLoadingChapters) return;

    _isLoadingChapters = true;
    _chaptersError = null;
    notifyListeners();

    try {
      if (_useMock) {
        _chapters = await _mockRepository!.getChaptersForUser();
      } else {
        _chapters = await _repository!.getChapters(forceRefresh: forceRefresh);
      }
      _chaptersError = null;
    } catch (e) {
      _chaptersError = e.toString();
      debugPrint('챕터 로드 실패: $e');
    } finally {
      _isLoadingChapters = false;
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

  // === 이론 관련 메서드 ===

  /// 이론 진입
  ///
  /// [chapterId]: 진입할 챕터 ID
  Future<bool> enterTheory(int chapterId) async {
    if (_isLoadingTheory) return false;

    _isLoadingTheory = true;
    _theoryError = null;
    notifyListeners();

    try {
      if (_useMock) {
        _currentTheorySession = await _mockRepository!.enterTheory(chapterId);
        // Mock에서는 진도 저장 기능 없음
      } else {
        _currentTheorySession = await _repository!.enterTheory(chapterId);

        // 저장된 진도가 있으면 해당 위치로 이동
        final savedProgress = await _repository.getTheoryProgress(chapterId);
        if (savedProgress != null && _currentTheorySession != null) {
          _currentTheorySession = _currentTheorySession!.copyWith(
            currentTheoryIndex: _findTheoryIndexById(savedProgress),
          );
        }
      }

      _theoryError = null;
      return true;
    } catch (e) {
      _theoryError = e.toString();
      debugPrint('이론 진입 실패: $e');
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
      if (_useMock) {
        await _mockRepository!.completeTheory(_currentTheorySession!.chapterId);
      } else {
        await _repository!.completeTheory(_currentTheorySession!.chapterId);
      }

      // 로컬 상태 업데이트
      _updateLocalChapterCompletion(_currentTheorySession!.chapterId, true);

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
    if (!_useMock) {
      await _repository!.clearCache();
    }
    // Mock에서는 캐시 삭제 기능 없음
    _chapters.clear();
    _currentTheorySession = null;
    _chaptersError = null;
    _theoryError = null;
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
  void _updateLocalChapterCompletion(int chapterId, bool isCompleted) {
    final chapterIndex = _chapters.indexWhere((c) => c.id == chapterId);
    if (chapterIndex >= 0) {
      _chapters[chapterIndex] = _chapters[chapterIndex].copyWith(
        isTheoryCompleted: isCompleted,
      );
    }
  }

  @override
  void dispose() {
    // Provider 해제 시 정리 작업
    super.dispose();
  }
}
