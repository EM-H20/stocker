

// features/aptitude/data/dto/aptitude_answer_request.dart
/// 사용자의 답변을 서버에 제출할 때 사용하는 DTO
class AptitudeAnswerRequest {
  final List<Answer> answers;

  AptitudeAnswerRequest({required this.answers});

  Map<String, dynamic> toJson() {
    return {
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class Answer {
  final int questionId;
  final int value;

  Answer({required this.questionId, required this.value});

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'value': value,
    };
  }
}
