import 'quiz_info.dart';

/// 퀴즈 세션 정보 모델
class QuizSession {
  final int chapterId;
  final String chapterTitle;
  final List<QuizInfo> quizzes;
  final int currentQuizIndex;
  final List<int?> userAnswers;
  final int? timeLimit; // 제한 시간 (초)
  final DateTime startedAt;

  const QuizSession({
    required this.chapterId,
    required this.chapterTitle,
    required this.quizzes,
    required this.currentQuizIndex,
    required this.userAnswers,
    this.timeLimit,
    required this.startedAt,
  });

  /// JSON에서 QuizSession 객체 생성
  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      chapterId: json['chapterId'] as int,
      chapterTitle: json['chapterTitle'] as String,
      quizzes: (json['quizzes'] as List)
          .map((quiz) => QuizInfo.fromJson(quiz as Map<String, dynamic>))
          .toList(),
      currentQuizIndex: json['currentQuizIndex'] as int,
      userAnswers: (json['userAnswers'] as List).cast<int?>(),
      timeLimit: json['timeLimit'] as int?,
      startedAt: DateTime.parse(json['startedAt'] as String),
    );
  }

  /// QuizSession 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'quizzes': quizzes.map((quiz) => quiz.toJson()).toList(),
      'currentQuizIndex': currentQuizIndex,
      'userAnswers': userAnswers,
      'timeLimit': timeLimit,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  /// 현재 퀴즈 정보 반환
  QuizInfo get currentQuiz => quizzes[currentQuizIndex];

  /// 전체 퀴즈 개수
  int get totalCount => quizzes.length;

  /// 다음 퀴즈가 있는지
  bool get hasNext => currentQuizIndex < quizzes.length - 1;

  /// 이전 퀴즈가 있는지
  bool get hasPrevious => currentQuizIndex > 0;

  /// 현재 진행률 (0.0 ~ 1.0)
  double get progressRatio => (currentQuizIndex + 1) / totalCount;

  /// 답변한 퀴즈 개수
  int get answeredCount => userAnswers.where((answer) => answer != null).length;

  /// 모든 퀴즈에 답했는지
  bool get isAllAnswered => answeredCount == totalCount;

  /// 현재 퀴즈에 답했는지
  bool get isCurrentAnswered => userAnswers[currentQuizIndex] != null;

  /// 세션 복사 (불변성 유지)
  QuizSession copyWith({
    int? chapterId,
    String? chapterTitle,
    List<QuizInfo>? quizzes,
    int? currentQuizIndex,
    List<int?>? userAnswers,
    int? timeLimit,
    DateTime? startedAt,
  }) {
    return QuizSession(
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      quizzes: quizzes ?? this.quizzes,
      currentQuizIndex: currentQuizIndex ?? this.currentQuizIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      timeLimit: timeLimit ?? this.timeLimit,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  @override
  String toString() {
    return 'QuizSession(chapterId: $chapterId, currentQuizIndex: $currentQuizIndex, totalCount: $totalCount)';
  }
}


