/// 투자성향 검사 결과 저장 요청 모델
/// API.md 명세: POST /api/investment_profile/result
class InvestmentResultRequest {
  final String version;
  final List<InvestmentAnswer> answers;

  InvestmentResultRequest({
    required this.version,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }

  factory InvestmentResultRequest.fromJson(Map<String, dynamic> json) {
    return InvestmentResultRequest(
      version: json['version'] ?? 'v1.1',
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((a) => InvestmentAnswer.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'InvestmentResultRequest(version: $version, answers: ${answers.length} items)';
  }
}

/// 투자성향 검사 답안 모델
class InvestmentAnswer {
  final int globalNo;
  final int answer;

  InvestmentAnswer({
    required this.globalNo,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'globalNo': globalNo,
      'answer': answer,
    };
  }

  factory InvestmentAnswer.fromJson(Map<String, dynamic> json) {
    return InvestmentAnswer(
      globalNo: json['globalNo'] ?? 0,
      answer: json['answer'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'InvestmentAnswer(globalNo: $globalNo, answer: $answer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvestmentAnswer &&
        other.globalNo == globalNo &&
        other.answer == answer;
  }

  @override
  int get hashCode => Object.hash(globalNo, answer);
}