// features/aptitude/data/dto/aptitude_answer_request.dart
/// 사용자의 답변을 서버에 제출할 때 사용하는 DTO (백엔드 실제 형식에 맞춤)
class AptitudeAnswerRequest {
  final String? version; // 백엔드에서 사용하는 version 필드
  final List<Answer> answers;

  AptitudeAnswerRequest({
    this.version = 'v1.1', // 기본값
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      if (version != null) 'version': version,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class Answer {
  final int questionId;
  final int value;

  Answer({required this.questionId, required this.value});

  Map<String, dynamic> toJson() {
    // 백엔드 기대 형식: {questionId, answer} 또는 {globalNo, answer}
    // questionId를 사용하고 value -> answer로 매핑
    return {
      'questionId': questionId, // ✅ 카멜케이스로 변경 (question_id → questionId)
      'answer': value, // ✅ value → answer로 필드명 변경
    };
  }
}
