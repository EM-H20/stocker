import 'package:flutter/material.dart';
import '../../domain/repository/learning_progress_repository.dart';

/// 🎯 학습 진도를 관리하는 Provider (Repository 패턴 적용)
///
/// - 마지막 학습 위치 저장/불러오기
/// - 챕터별 완료 상태 관리
/// - 학습 통계 제공
/// - 연속 학습일 계산
class LearningProgressProvider extends ChangeNotifier {
  // ============= Repository =============
  final LearningProgressRepository _repository;

  // ============= 상태 변수들 =============

  /// 마지막으로 학습한 챕터 ID
  int _lastChapterId = 1;
  int get lastChapterId => _lastChapterId;

  /// 마지막으로 학습한 단계
  String _lastStep = 'theory'; // 'theory', 'quiz', 'result'
  String get lastStep => _lastStep;

  /// 챕터별 완료 상태 {chapterId: isCompleted}
  Map<int, bool> _completedChapters = {};
  Map<int, bool> get completedChapters => {..._completedChapters};

  /// 퀴즈별 완료 상태 {chapterId: isCompleted}
  Map<int, bool> _completedQuizzes = {};
  Map<int, bool> get completedQuizzes => {..._completedQuizzes};

  /// 학습한 날짜들 (연속 학습일 계산용)
  Set<String> _studiedDates = {}; // 'yyyy-MM-dd' 형태
  Set<String> get studiedDates => {..._studiedDates};

  /// 사용 가능한 챕터 목록 (Repository에서 조회)
  List<Map<String, dynamic>> _availableChapters = [];
  List<Map<String, dynamic>> get availableChapters => [..._availableChapters];

  /// 초기화 완료 여부
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ============= 생성자 =============

  LearningProgressProvider(this._repository) {
    _initialize();
  }

  // ============= 초기화 =============

  Future<void> _initialize() async {
    await _loadProgress();
    _isInitialized = true;
    notifyListeners();
  }

  /// Repository에서 진도 데이터 불러오기
  Future<void> _loadProgress() async {
    try {
      // 마지막 학습 위치 로드
      final lastPosition = await _repository.getLastLearningPosition();
      if (lastPosition != null) {
        _lastChapterId = lastPosition['chapterId'] ?? 1;
        _lastStep = lastPosition['step'] ?? 'theory';
      }

      // 완료된 챕터들 로드
      final completedChaptersList = await _repository.getCompletedChapters();
      _completedChapters = {};
      for (final chapterId in completedChaptersList) {
        _completedChapters[chapterId] = true;
      }

      // 완료된 퀴즈들 로드
      final completedQuizzesList = await _repository.getCompletedQuizzes();
      _completedQuizzes = {};
      for (final chapterId in completedQuizzesList) {
        _completedQuizzes[chapterId] = true;
      }

      // 학습한 날짜들 로드
      _studiedDates = await _repository.getStudiedDates();

      // 사용 가능한 챕터 목록 로드
      _availableChapters = await _repository.getAvailableChapters();

      debugPrint('📚 [LearningProgress] Repository에서 진도 데이터 로드 완료');
      debugPrint('   - 마지막 위치: Chapter $_lastChapterId ($_lastStep)');
      debugPrint('   - 완료 챕터: ${_completedChapters.keys.toList()}');
      debugPrint('   - 완료 퀴즈: ${_completedQuizzes.keys.toList()}');
      debugPrint('   - 학습일: ${_studiedDates.length}일');
      debugPrint('   - 사용 가능한 챕터: ${_availableChapters.length}개');
    } catch (e) {
      debugPrint('❌ [LearningProgress] Repository 진도 로드 실패: $e');
    }
  }

  // ============= 진도 업데이트 메서드들 =============

  /// 📍 현재 학습 위치 업데이트
  Future<void> updateCurrentPosition({
    required int chapterId,
    required String step,
  }) async {
    _lastChapterId = chapterId;
    _lastStep = step;

    // Repository를 통해 위치 저장
    await _repository.saveLastLearningPosition(
      chapterId: chapterId,
      step: step,
    );

    // 오늘 학습 기록 추가
    await _repository.addTodayStudyRecord();
    _studiedDates = await _repository.getStudiedDates();

    notifyListeners();

    debugPrint('📍 [LearningProgress] 위치 업데이트: Chapter $chapterId ($step)');
  }

  /// ✅ 챕터 완료 표시
  Future<void> completeChapter(int chapterId) async {
    // 이미 완료된 챕터라면 중복 처리하지 않음
    if (_completedChapters[chapterId] == true) {
      debugPrint('⚠️ [LearningProgress] 챕터 $chapterId 이미 완료됨 - 중복 처리 방지');
      return;
    }
    
    _completedChapters[chapterId] = true;
    
    try {
      // Repository를 통해 완료 상태 저장
      await _repository.markChapterCompleted(chapterId);
      debugPrint('✅ [LearningProgress] 챕터 $chapterId 완료!');
    } catch (e) {
      debugPrint('❌ [LearningProgress] 챕터 $chapterId 완료 저장 실패: $e');
      // 에러가 발생해도 로컬 상태는 유지 (사용자 경험을 위해)
    }
    
    notifyListeners();
  }

  /// 🎯 퀴즈 완료 표시
  Future<void> completeQuiz(int chapterId) async {
    _completedQuizzes[chapterId] = true;
    
    // Repository를 통해 완료 상태 저장
    await _repository.markQuizCompleted(chapterId);
    
    notifyListeners();

    debugPrint('🎯 [LearningProgress] 퀴즈 $chapterId 완료!');
  }

  /// 🔄 진도 초기화 (테스트용)
  Future<void> resetProgress() async {
    _lastChapterId = 1;
    _lastStep = 'theory';
    _completedChapters.clear();
    _completedQuizzes.clear();
    _studiedDates.clear();

    // Repository를 통해 초기화
    await _repository.resetProgress();
    
    notifyListeners();

    debugPrint('🔄 [LearningProgress] 진도 초기화 완료');
  }

  // ============= 계산된 속성들 =============

  /// 📊 전체 진도율 (0.0 ~ 1.0)
  double getOverallProgress({int totalChapters = 10}) {
    if (totalChapters == 0) return 0.0;
    return _completedChapters.length / totalChapters;
  }

  /// 📈 현재 챕터의 진도율
  double getCurrentChapterProgress() {
    switch (_lastStep) {
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

  /// 🔥 연속 학습일 계산
  int getStudyStreak() {
    if (_studiedDates.isEmpty) return 0;

    final today = DateTime.now();
    int streak = 0;
    DateTime checkDate = today;

    // 오늘부터 거꾸로 세면서 연속일 계산
    while (true) {
      final checkDateStr =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

      if (_studiedDates.contains(checkDateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// 🏆 완료된 챕터 수
  int get completedChaptersCount =>
      _completedChapters.values.where((v) => v).length;

  /// 🎯 완료된 퀴즈 수
  int get completedQuizzesCount =>
      _completedQuizzes.values.where((v) => v).length;

  /// 📚 다음에 학습할 챕터 추천
  int getRecommendedNextChapter({int maxChapters = 10}) {
    // 현재 챕터가 완료되었으면 다음 챕터
    if (_completedChapters[_lastChapterId] == true) {
      return (_lastChapterId + 1).clamp(1, maxChapters);
    }

    // 아니면 현재 챕터 계속
    return _lastChapterId;
  }

  /// 🎓 현재 챕터 제목 가져오기
  ///
  /// Repository에서 가져온 실제 챕터 데이터 사용
  /// [chapterId]: 챕터 ID
  /// Returns: 챕터 제목 (실제 데이터가 없으면 기본 제목 반환)
  String getChapterTitle(int chapterId) {
    try {
      // Repository에서 가져온 실제 챕터 데이터 검색
      final chapter = _availableChapters.firstWhere(
        (chapter) => chapter['id'] == chapterId,
        orElse: () => <String, Object>{},
      );

      if (chapter.isNotEmpty) {
        debugPrint('✅ [LEARNING_PROGRESS] Repository에서 실제 챕터 제목 반환: ${chapter['title']}');
        return chapter['title'] as String;
      }
      
      debugPrint('⚠️ [LEARNING_PROGRESS] 챕터 $chapterId를 찾을 수 없어 기본 제목 사용');
      return 'Chapter $chapterId';
    } catch (e) {
      debugPrint('❌ [LEARNING_PROGRESS] 챕터 제목 조회 중 오류: $e');
      return 'Chapter $chapterId';
    }
  }

  /// 🎓 현재 챕터 설명 가져오기
  String getChapterDescription(int chapterId) {
    try {
      final chapter = _availableChapters.firstWhere(
        (chapter) => chapter['id'] == chapterId,
        orElse: () => <String, Object>{},
      );

      if (chapter.isNotEmpty) {
        return chapter['description'] as String? ?? '${getChapterTitle(chapterId)} 학습 내용';
      }
      
      return 'Chapter $chapterId 학습 내용';
    } catch (e) {
      debugPrint('❌ [LEARNING_PROGRESS] 챕터 설명 조회 중 오류: $e');
      return 'Chapter $chapterId 학습 내용';
    }
  }
}
