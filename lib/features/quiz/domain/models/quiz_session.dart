import 'quiz_info.dart';

/// 퀴즈 세션 정보 모델 (API.md 스펙 준수)
class QuizSession {
  final int chapterId;
  final List<QuizInfo> quizList;
  final int currentQuizId;
  final List<int?> userAnswers; // 로컬 저장용
  final DateTime startedAt; // 로컬 저장용
  final bool isSingleQuizMode; // 단일 퀴즈 모드 여부

  const QuizSession({
    required this.chapterId,
    required this.quizList,
    required this.currentQuizId,
    required this.userAnswers,
    required this.startedAt,
    this.isSingleQuizMode = false,
  });

  /// JSON에서 QuizSession 객체 생성 (API.md 스펙)
  factory QuizSession.fromJson(Map<String, dynamic> json) {
    final quizListData = json['quiz_list'] as List;
    return QuizSession(
      chapterId: json['chapter_id'] as int,
      quizList: quizListData
          .map((quiz) => QuizInfo.fromBackendJson(quiz as Map<String, dynamic>))
          .toList(),
      currentQuizId: json['current_quiz_id'] as int,
      userAnswers: (json['userAnswers'] as List<dynamic>?)?.cast<int?>() ??
          List<int?>.filled(quizListData.length, null),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : DateTime.now(),
      isSingleQuizMode: json['isSingleQuizMode'] as bool? ?? false,
    );
  }

  /// 로컬 저장된 JSON에서 QuizSession 객체 생성
  factory QuizSession.fromLocalJson(Map<String, dynamic> json) {
    return QuizSession(
      chapterId: json['chapter_id'] as int,
      quizList: (json['quiz_list'] as List)
          .map((quiz) => QuizInfo.fromJson(quiz as Map<String, dynamic>))
          .toList(),
      currentQuizId: json['current_quiz_id'] as int,
      userAnswers: (json['userAnswers'] as List<dynamic>?)?.cast<int?>() ??
          List<int?>.filled((json['quiz_list'] as List).length, null),
      startedAt: DateTime.parse(json['startedAt'] as String),
      isSingleQuizMode: json['isSingleQuizMode'] as bool? ?? false,
    );
  }

  /// QuizSession 객체를 JSON으로 변환 (로컬 저장용)
  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'quiz_list': quizList.map((quiz) => quiz.toJson()).toList(),
      'current_quiz_id': currentQuizId,
      'userAnswers': userAnswers,
      'startedAt': startedAt.toIso8601String(),
      'isSingleQuizMode': isSingleQuizMode,
    };
  }

  /// 현재 퀴즈 정보 반환
  QuizInfo? get currentQuiz {
    try {
      return quizList.firstWhere((quiz) => quiz.id == currentQuizId);
    } catch (e) {
      return quizList.isNotEmpty ? quizList.first : null;
    }
  }

  /// 현재 퀴즈 인덱스
  int get currentQuizIndex {
    final index = quizList.indexWhere((quiz) => quiz.id == currentQuizId);
    return index >= 0 ? index : 0;
  }

  /// 전체 퀴즈 개수
  int get totalCount => quizList.length;

  /// 다음 퀴즈가 있는지
  bool get hasNext => currentQuizIndex < quizList.length - 1;

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
    List<QuizInfo>? quizList,
    int? currentQuizId,
    List<int?>? userAnswers,
    DateTime? startedAt,
    bool? isSingleQuizMode,
  }) {
    return QuizSession(
      chapterId: chapterId ?? this.chapterId,
      quizList: quizList ?? this.quizList,
      currentQuizId: currentQuizId ?? this.currentQuizId,
      userAnswers: userAnswers ?? this.userAnswers,
      startedAt: startedAt ?? this.startedAt,
      isSingleQuizMode: isSingleQuizMode ?? this.isSingleQuizMode,
    );
  }

  @override
  String toString() {
    return 'QuizSession(chapterId: $chapterId, currentQuizId: $currentQuizId, totalCount: $totalCount)';
  }
}
