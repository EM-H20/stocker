//# (서버 전송용) 퀴즈 답변 DTO

/// 퀴즈 답변을 서버에 제출할 때 사용하는 DTO
class QuizSubmissionDto {
  final int userId;
  final List<QuizAnswerDto> answers;

  QuizSubmissionDto({
    required this.userId,
    required this.answers,
  });

  // 서버 전송을 위해 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

/// 개별 퀴즈 답변 DTO
class QuizAnswerDto {
  final int quizId;
  final bool userAnswer;

  QuizAnswerDto({
    required this.quizId,
    required this.userAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'user_answer': userAnswer,
    };
  }
}
