/// 오답노트 요청 모델
class WrongNoteRequest {
  final String userId;
  final int chapterId;
  final List<QuizResult> results;

  const WrongNoteRequest({
    required this.userId,
    required this.chapterId,
    required this.results,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'chapter_id': chapterId,
      'results': results.map((result) => result.toJson()).toList(),
    };
  }

  /// JSON에서 객체 생성
  factory WrongNoteRequest.fromJson(Map<String, dynamic> json) {
    return WrongNoteRequest(
      userId: json['user_id'] as String,
      chapterId: json['chapter_id'] as int,
      results: (json['results'] as List)
          .map((result) => QuizResult.fromJson(result))
          .toList(),
    );
  }
}

/// 퀴즈 결과 모델
class QuizResult {
  final int quizId;
  final bool isCorrect;

  const QuizResult({
    required this.quizId,
    required this.isCorrect,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'is_correct': isCorrect,
    };
  }

  /// JSON에서 객체 생성
  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      quizId: json['quiz_id'] as int,
      isCorrect: json['is_correct'] as bool,
    );
  }
}
