/// 퀴즈 결과 정보 모델
class QuizResult {
  final int chapterId;
  final String chapterTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int scorePercentage;
  final String grade;
  final bool isPassed;
  final int timeSpentSeconds;
  final DateTime completedAt;

  const QuizResult({
    required this.chapterId,
    required this.chapterTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.scorePercentage,
    required this.grade,
    required this.isPassed,
    required this.timeSpentSeconds,
    required this.completedAt,
  });

  /// JSON에서 QuizResult 객체 생성 (로컬 저장용)
  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      chapterId: json['chapterId'] as int,
      chapterTitle: json['chapterTitle'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      scorePercentage: json['scorePercentage'] as int,
      grade: json['grade'] as String,
      isPassed: json['isPassed'] as bool,
      timeSpentSeconds: json['timeSpentSeconds'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  /// 백엔드 응답에서 QuizResult 객체 생성
  /// 서버 응답: {"total": 2, "correct": 2, "wrong": 0}
  factory QuizResult.fromBackendJson(Map<String, dynamic> json, int chapterId) {
    final totalQuestions = json['total'] as int;
    final correctAnswers = json['correct'] as int;
    final wrongAnswers = json['wrong'] as int;
    final scorePercentage = ((correctAnswers / totalQuestions) * 100).round();
    final grade = calculateGrade(scorePercentage);
    final isPassed = calculatePassed(scorePercentage);

    return QuizResult(
      chapterId: chapterId,
      chapterTitle: '챕터 $chapterId',
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      scorePercentage: scorePercentage,
      grade: grade,
      isPassed: isPassed,
      timeSpentSeconds: 0, // 소요시간은 사용하지 않음
      completedAt: DateTime.now(),
    );
  }

  /// QuizResult 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'scorePercentage': scorePercentage,
      'grade': grade,
      'isPassed': isPassed,
      'timeSpentSeconds': timeSpentSeconds,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  /// 정답률 (0.0 ~ 1.0)
  double get accuracyRate => correctAnswers / totalQuestions;

  /// 소요 시간 포맷 (MM:SS)
  String get formattedTimeSpent {
    final minutes = timeSpentSeconds ~/ 60;
    final seconds = timeSpentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 점수에 따른 등급 계산
  static String calculateGrade(int scorePercentage) {
    if (scorePercentage >= 90) return 'A';
    if (scorePercentage >= 80) return 'B';
    if (scorePercentage >= 70) return 'C';
    if (scorePercentage >= 60) return 'D';
    return 'F';
  }

  /// 합격 여부 판정 (70% 이상)
  static bool calculatePassed(int scorePercentage) {
    return scorePercentage >= 70;
  }

  @override
  String toString() {
    return 'QuizResult(chapterId: $chapterId, score: $scorePercentage%, grade: $grade, passed: $isPassed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizResult &&
        other.chapterId == chapterId &&
        other.completedAt == completedAt &&
        other.scorePercentage == scorePercentage;
  }

  @override
  int get hashCode => Object.hash(chapterId, completedAt, scorePercentage);
}
