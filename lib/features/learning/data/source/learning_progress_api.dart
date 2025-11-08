import 'package:dio/dio.dart';

/// 학습 진도 관련 API 호출 클래스
class LearningProgressApi {
  final Dio _dio;

  LearningProgressApi(this._dio);

  /// 사용자의 학습 진도 조회
  Future<Map<String, dynamic>> getUserProgress() async {
    final response = await _dio.get('/api/user/progress');
    return response.data as Map<String, dynamic>;
  }

  /// 사용자의 학습 진도 저장/업데이트
  Future<void> saveUserProgress({
    required int lastChapterId,
    required String lastStep,
    required List<int> completedChapters,
    required List<int> completedQuizzes,
  }) async {
    await _dio.post('/api/user/progress', data: {
      'lastChapterId': lastChapterId,
      'lastStep': lastStep,
      'completedChapters': completedChapters,
      'completedQuizzes': completedQuizzes,
      'lastStudyDate': DateTime.now().toIso8601String(),
    });
  }

  /// 챕터 완료 표시
  Future<void> markChapterCompleted(int chapterId) async {
    await _dio.post('/api/user/progress/chapter/$chapterId/complete');
  }

  /// 퀴즈 완료 표시
  Future<void> markQuizCompleted(int chapterId) async {
    await _dio.post('/api/user/progress/quiz/$chapterId/complete');
  }

  /// 전체 진도 초기화
  Future<void> resetProgress() async {
    await _dio.delete('/api/user/progress');
  }
}
