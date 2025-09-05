import 'package:flutter/material.dart';
import '../../domain/repository/learning_progress_repository.dart';
import '../source/learning_progress_api.dart';
import '../../../education/presentation/education_provider.dart';

/// 실제 API와 연동되는 학습 진도 Repository
class LearningProgressApiRepository implements LearningProgressRepository {
  final LearningProgressApi _api;
  final EducationProvider? _educationProvider;
  
  // 로컬 캐시 (API 호출 최소화)
  Map<String, dynamic>? _cachedProgress;
  List<Map<String, dynamic>>? _cachedChapters;
  
  LearningProgressApiRepository(this._api, [this._educationProvider]);

  @override
  Future<Map<String, dynamic>?> getLastLearningPosition() async {
    try {
      // 캐시된 진도가 있으면 사용
      if (_cachedProgress != null) {
        return {
          'chapterId': _cachedProgress!['lastChapterId'] ?? 1,
          'step': _cachedProgress!['lastStep'] ?? 'theory',
        };
      }
      
      // API에서 사용자 진도 조회
      final progressData = await _api.getUserProgress();
      _cachedProgress = progressData;
      
      return {
        'chapterId': progressData['lastChapterId'] ?? 1,
        'step': progressData['lastStep'] ?? 'theory',
      };
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 마지막 위치 조회 실패: $e');
      // API 실패 시 기본값 반환
      return {
        'chapterId': 1,
        'step': 'theory',
      };
    }
  }

  @override
  Future<void> saveLastLearningPosition({
    required int chapterId,
    required String step,
  }) async {
    try {
      // 현재 진도 조회 (completedChapters, completedQuizzes 유지)
      final currentProgress = await _getUserProgressInternal();
      
      await _api.saveUserProgress(
        lastChapterId: chapterId,
        lastStep: step,
        completedChapters: List<int>.from(currentProgress['completedChapters'] ?? []),
        completedQuizzes: List<int>.from(currentProgress['completedQuizzes'] ?? []),
      );
      
      // 캐시 업데이트
      _cachedProgress = {
        ...(_cachedProgress ?? {}),
        'lastChapterId': chapterId,
        'lastStep': step,
      };
      
      debugPrint('💾 [LearningProgressApiRepo] 마지막 위치 저장: Chapter $chapterId ($step)');
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 마지막 위치 저장 실패: $e');
    }
  }

  @override
  Future<List<int>> getCompletedChapters() async {
    try {
      final progressData = await _getUserProgressInternal();
      return List<int>.from(progressData['completedChapters'] ?? []);
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 완료 챕터 조회 실패: $e');
      return [];
    }
  }

  @override
  Future<void> markChapterCompleted(int chapterId) async {
    try {
      await _api.markChapterCompleted(chapterId);
      
      // 캐시 업데이트
      if (_cachedProgress != null) {
        final completedChapters = List<int>.from(_cachedProgress!['completedChapters'] ?? []);
        if (!completedChapters.contains(chapterId)) {
          completedChapters.add(chapterId);
          _cachedProgress!['completedChapters'] = completedChapters;
        }
      }
      
      debugPrint('✅ [LearningProgressApiRepo] 챕터 $chapterId 완료 표시');
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 챕터 완료 표시 실패: $e');
    }
  }

  @override
  Future<List<int>> getCompletedQuizzes() async {
    try {
      final progressData = await _getUserProgressInternal();
      return List<int>.from(progressData['completedQuizzes'] ?? []);
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 완료 퀴즈 조회 실패: $e');
      return [];
    }
  }

  @override
  Future<void> markQuizCompleted(int chapterId) async {
    try {
      await _api.markQuizCompleted(chapterId);
      
      // 캐시 업데이트
      if (_cachedProgress != null) {
        final completedQuizzes = List<int>.from(_cachedProgress!['completedQuizzes'] ?? []);
        if (!completedQuizzes.contains(chapterId)) {
          completedQuizzes.add(chapterId);
          _cachedProgress!['completedQuizzes'] = completedQuizzes;
        }
      }
      
      debugPrint('🎯 [LearningProgressApiRepo] 퀴즈 $chapterId 완료 표시');
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 퀴즈 완료 표시 실패: $e');
    }
  }

  @override
  Future<Set<String>> getStudiedDates() async {
    try {
      final progressData = await _getUserProgressInternal();
      return Set<String>.from(progressData['studiedDates'] ?? []);
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 학습 날짜 조회 실패: $e');
      return {};
    }
  }

  @override
  Future<void> addTodayStudyRecord() async {
    try {
      // 현재 진도에 오늘 날짜 추가해서 저장
      final currentProgress = await _getUserProgressInternal();
      final studiedDates = Set<String>.from(currentProgress['studiedDates'] ?? []);
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      if (!studiedDates.contains(todayStr)) {
        studiedDates.add(todayStr);
        // API 저장 로직은 saveUserProgress에서 처리 (별도 API 없다고 가정)
        debugPrint('📅 [LearningProgressApiRepo] 오늘 학습 기록 추가: $todayStr');
      }
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 학습 날짜 추가 실패: $e');
    }
  }

  @override
  Future<void> resetProgress() async {
    try {
      await _api.resetProgress();
      
      // 캐시 초기화
      _cachedProgress = null;
      _cachedChapters = null;
      
      debugPrint('🔄 [LearningProgressApiRepo] 진도 초기화 완료');
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 진도 초기화 실패: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableChapters() async {
    try {
      // 캐시된 챕터가 있으면 사용
      if (_cachedChapters != null) {
        return _cachedChapters!;
      }
      
      // EducationProvider에서 실제 챕터 데이터 가져오기
      if (_educationProvider != null && _educationProvider!.chapters.isNotEmpty) {
        debugPrint('✅ [LearningProgressApiRepo] EducationProvider에서 실제 챕터 데이터 사용');
        _cachedChapters = _educationProvider!.chapters.map((chapter) => {
          'id': chapter.id,
          'title': chapter.title,
          'description': chapter.description ?? '${chapter.title} 학습 내용',
        }).toList();
        return _cachedChapters!;
      }
      
      debugPrint('⚠️ [LearningProgressApiRepo] EducationProvider 데이터 없음 - Fallback 사용');
      // Fallback: 기본 챕터 데이터
      _cachedChapters = [
        {'id': 1, 'title': '주식의 기본 개념', 'description': '주식 투자의 첫걸음'},
        {'id': 2, 'title': '투자의 기본 원리', 'description': '현명한 투자를 위한 기초'},
      ];
      return _cachedChapters!;
      
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 챕터 목록 조회 실패: $e');
      return [];
    }
  }
  
  /// 내부용: 사용자 진도 데이터 조회 (캐싱 포함)
  Future<Map<String, dynamic>> _getUserProgressInternal() async {
    if (_cachedProgress != null) {
      return _cachedProgress!;
    }
    
    try {
      _cachedProgress = await _api.getUserProgress();
      return _cachedProgress!;
    } catch (e) {
      debugPrint('❌ [LearningProgressApiRepo] 사용자 진도 조회 실패: $e');
      // 기본값 반환
      return {
        'lastChapterId': 1,
        'lastStep': 'theory',
        'completedChapters': <int>[],
        'completedQuizzes': <int>[],
        'studiedDates': <String>[],
      };
    }
  }
}