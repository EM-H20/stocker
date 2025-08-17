/// 퀴즈 문제 정보 모델
class QuizInfo {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const QuizInfo({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  /// JSON에서 QuizInfo 객체 생성
  factory QuizInfo.fromJson(Map<String, dynamic> json) {
    return QuizInfo(
      id: json['id'] as int,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  /// QuizInfo 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }

  /// 정답 텍스트 반환
  String get correctAnswerText => options[correctAnswerIndex];

  /// 선택한 답이 정답인지 확인
  bool isCorrectAnswer(int selectedIndex) =>
      selectedIndex == correctAnswerIndex;

  @override
  String toString() {
    return 'QuizInfo(id: $id, question: $question, correctAnswerIndex: $correctAnswerIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizInfo &&
        other.id == id &&
        other.question == question &&
        other.correctAnswerIndex == correctAnswerIndex;
  }

  @override
  int get hashCode => Object.hash(id, question, correctAnswerIndex);
}
