import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎯 학습 진도를 관리하는 Provider
/// 
/// - 마지막 학습 위치 저장/불러오기
/// - 챕터별 완료 상태 관리
/// - 학습 통계 제공
/// - 연속 학습일 계산
class LearningProgressProvider extends ChangeNotifier {
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

  /// 초기화 완료 여부
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ============= 생성자 =============
  
  LearningProgressProvider() {
    _initialize();
  }

  // ============= 초기화 =============

  Future<void> _initialize() async {
    await _loadProgress();
    _isInitialized = true;
    notifyListeners();
  }

  /// SharedPreferences에서 진도 데이터 불러오기
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 마지막 학습 위치
      _lastChapterId = prefs.getInt('last_chapter_id') ?? 1;
      _lastStep = prefs.getString('last_step') ?? 'theory';
      
      // 완료된 챕터들
      final completedChaptersList = prefs.getStringList('completed_chapters') ?? [];
      _completedChapters = {};
      for (final chapterStr in completedChaptersList) {
        final chapterId = int.tryParse(chapterStr);
        if (chapterId != null) {
          _completedChapters[chapterId] = true;
        }
      }
      
      // 완료된 퀴즈들
      final completedQuizzesList = prefs.getStringList('completed_quizzes') ?? [];
      _completedQuizzes = {};
      for (final chapterStr in completedQuizzesList) {
        final chapterId = int.tryParse(chapterStr);
        if (chapterId != null) {
          _completedQuizzes[chapterId] = true;
        }
      }
      
      // 학습한 날짜들
      _studiedDates = (prefs.getStringList('studied_dates') ?? []).toSet();
      
      debugPrint('📚 [LearningProgress] 진도 데이터 로드 완료');
      debugPrint('   - 마지막 위치: Chapter $_lastChapterId ($_lastStep)');
      debugPrint('   - 완료 챕터: ${_completedChapters.keys.toList()}');
      debugPrint('   - 완료 퀴즈: ${_completedQuizzes.keys.toList()}');
      debugPrint('   - 학습일: ${_studiedDates.length}일');
      
    } catch (e) {
      debugPrint('❌ [LearningProgress] 진도 로드 실패: $e');
    }
  }

  /// SharedPreferences에 진도 데이터 저장하기
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 마지막 학습 위치
      await prefs.setInt('last_chapter_id', _lastChapterId);
      await prefs.setString('last_step', _lastStep);
      
      // 완료된 챕터들
      final completedChaptersList = _completedChapters.keys
          .where((key) => _completedChapters[key] == true)
          .map((key) => key.toString())
          .toList();
      await prefs.setStringList('completed_chapters', completedChaptersList);
      
      // 완료된 퀴즈들
      final completedQuizzesList = _completedQuizzes.keys
          .where((key) => _completedQuizzes[key] == true)
          .map((key) => key.toString())
          .toList();
      await prefs.setStringList('completed_quizzes', completedQuizzesList);
      
      // 학습한 날짜들
      await prefs.setStringList('studied_dates', _studiedDates.toList());
      
      debugPrint('💾 [LearningProgress] 진도 데이터 저장 완료');
      
    } catch (e) {
      debugPrint('❌ [LearningProgress] 진도 저장 실패: $e');
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
    
    // 오늘 날짜 추가
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    _studiedDates.add(dateStr);
    
    await _saveProgress();
    notifyListeners();
    
    debugPrint('📍 [LearningProgress] 위치 업데이트: Chapter $chapterId ($step)');
  }

  /// ✅ 챕터 완료 표시
  Future<void> completeChapter(int chapterId) async {
    _completedChapters[chapterId] = true;
    await _saveProgress();
    notifyListeners();
    
    debugPrint('✅ [LearningProgress] 챕터 $chapterId 완료!');
  }

  /// 🎯 퀴즈 완료 표시
  Future<void> completeQuiz(int chapterId) async {
    _completedQuizzes[chapterId] = true;
    await _saveProgress();
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
    
    await _saveProgress();
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
      final checkDateStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      
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
  int get completedChaptersCount => _completedChapters.values.where((v) => v).length;

  /// 🎯 완료된 퀴즈 수  
  int get completedQuizzesCount => _completedQuizzes.values.where((v) => v).length;

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
  /// 실제 EducationProvider에서 데이터를 가져오기 전까지는 fallback 데이터 사용
  /// [chapterId]: 챕터 ID
  /// Returns: 챕터 제목 (실제 데이터가 없으면 fallback 제목 반환)
  String getChapterTitle(int chapterId) {
    // ⚠️ 현재는 fallback 데이터 사용 
    // 실제로는 ContinueLearningWidget에서 EducationProvider를 통해 가져와야 함
    const fallbackChapterTitles = {
      1: '주식의 기본 개념',
      2: '투자의 기본 원리', 
      3: '리스크와 수익률',
      4: '포트폴리오 구성',
      5: '기술적 분석 입문',
      6: '기본적 분석 기초',
      7: '투자 심리학',
      8: '시장 분석 방법',
      9: '고급 투자 전략',
      10: '장기 투자 계획',
    };
    
    debugPrint('⚠️ [LEARNING_PROGRESS] Fallback 챕터 제목 사용 - 실제 데이터 연동 필요');
    return fallbackChapterTitles[chapterId] ?? 'Chapter $chapterId';
  }
}