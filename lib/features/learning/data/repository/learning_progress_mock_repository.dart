import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repository/learning_progress_repository.dart';

/// Mock 학습 진도 Repository - SharedPreferences + 하드코딩된 챕터 데이터 사용
class LearningProgressMockRepository implements LearningProgressRepository {
  
  /// 📚 Mock 챕터 데이터 (기존 fallback 데이터 유지)
  static const Map<int, String> _mockChapterTitles = {
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

  @override
  Future<Map<String, dynamic>?> getLastLearningPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chapterId = prefs.getInt('last_chapter_id');
      final step = prefs.getString('last_step');
      
      if (chapterId != null && step != null) {
        return {
          'chapterId': chapterId,
          'step': step,
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ [LearningProgressMockRepo] 마지막 위치 조회 실패: $e');
      return null;
    }
  }

  @override
  Future<void> saveLastLearningPosition({
    required int chapterId,
    required String step,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_chapter_id', chapterId);
      await prefs.setString('last_step', step);
      debugPrint('💾 [LearningProgressMockRepo] 마지막 위치 저장: Chapter $chapterId ($step)');
    } catch (e) {
      debugPrint('❌ [LearningProgressMockRepo] 마지막 위치 저장 실패: $e');
    }
  }

  @override
  Future<List<int>> getCompletedChapters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedList = prefs.getStringList('completed_chapters') ?? [];
      return completedList.map((str) => int.tryParse(str) ?? 0)
                         .where((id) => id > 0)
                         .toList();
    } catch (e) {
      debugPrint('❌ [LearningProgressMockRepo] 완료 챕터 조회 실패: $e');
      return [];
    }
  }

  @override
  Future<void> markChapterCompleted(int chapterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedList = prefs.getStringList('completed_chapters') ?? [];
      if (!completedList.contains(chapterId.toString())) {
        completedList.add(chapterId.toString());
        await prefs.setStringList('completed_chapters', completedList);
        debugPrint('✅ [LearningProgressMockRepo] 챕터 $chapterId 완료 표시');
      }
    } catch (e) {
      debugPrint('❌ [LearningProgressMockRepo] 챕터 완료 표시 실패: $e');
    }
  }

  @override
  Future<List<int>> getCompletedQuizzes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedList = prefs.getStringList('completed_quizzes') ?? [];
      return completedList.map((str) => int.tryParse(str) ?? 0)
                         .where((id) => id > 0)
                         .toList();
    } catch (e) {
      debugPrint('❌ [LearningProgressMockRepo] 완료 퀴즈 조회 실패: $e');
      return [];
    }
  }

  @override
  Future<void> markQuizCompleted(int chapterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedList = prefs.getStringList('completed_quizzes') ?? [];
      if (!completedList.contains(chapterId.toString())) {
        completedList.add(chapterId.toString());
        await prefs.setStringList('completed_quizzes', completedList);
        debugPrint('🎯 [LearningProgressMockRepo] 퀴즈 $chapterId 완료 표시');
      }
    } catch (e) {
      debugPrint('❌ [LearningProgressMockRepo] 퀴즈 완료 표시 실패: $e');
    }
  }

  @override
  Future<Set<String>> getStudiedDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final datesList = prefs.getStringList('studied_dates') ?? [];
      return datesList.toSet();
    } catch (e) {
      debugPrint('❌ [LearningProgressMockRepo] 학습 날짜 조회 실패: $e');
      return {};
    }
  }

  @override
  Future<void> addTodayStudyRecord() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final datesList = prefs.getStringList('studied_dates') ?? [];
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      if (!datesList.contains(todayStr)) {
        datesList.add(todayStr);
        await prefs.setStringList('studied_dates', datesList);
        debugPrint('📅 [LearningProgressMockRepo] 오늘 학습 기록 추가: $todayStr');
      }
    } catch (e) {
      debugPrint('❌ [LearningProgressMockRepo] 학습 날짜 추가 실패: $e');
    }
  }

  @override
  Future<void> resetProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_chapter_id');
      await prefs.remove('last_step');
      await prefs.remove('completed_chapters');
      await prefs.remove('completed_quizzes');
      await prefs.remove('studied_dates');
      debugPrint('🔄 [LearningProgressMockRepo] 진도 초기화 완료');
    } catch (e) {
      debugPrint('❌ [LearningProgressMockRepo] 진도 초기화 실패: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableChapters() async {
    // Mock 환경에서는 하드코딩된 챕터 데이터 반환
    debugPrint('📚 [LearningProgressMockRepo] Mock 챕터 데이터 반환');
    
    return _mockChapterTitles.entries.map((entry) => {
      'id': entry.key,
      'title': entry.value,
      'description': '${entry.value} 학습 내용',
    }).toList();
  }
}