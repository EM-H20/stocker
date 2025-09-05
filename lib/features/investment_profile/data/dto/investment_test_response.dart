/// 투자성향 검사지 조회 응답 모델
/// API.md 명세: GET /api/investment_profile/test
class InvestmentTestResponse {
  final String version;
  final List<InvestmentQuestion> questions;

  InvestmentTestResponse({
    required this.version,
    required this.questions,
  });

  factory InvestmentTestResponse.fromJson(Map<String, dynamic> json) {
    return InvestmentTestResponse(
      version: json['version'] ?? 'v1.1',
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => InvestmentQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

/// 투자성향 검사 문항 모델
class InvestmentQuestion {
  final int questionId;
  final String version;
  final int globalNo;
  final String dimCode;
  final String dimName;
  final String leftLabel;
  final String rightLabel;
  final String question;
  final bool isReverse;
  final String? note;

  InvestmentQuestion({
    required this.questionId,
    required this.version,
    required this.globalNo,
    required this.dimCode,
    required this.dimName,
    required this.leftLabel,
    required this.rightLabel,
    required this.question,
    required this.isReverse,
    this.note,
  });

  factory InvestmentQuestion.fromJson(Map<String, dynamic> json) {
    return InvestmentQuestion(
      questionId: json['questionId'] ?? 0,
      version: json['version'] ?? 'v1.1',
      globalNo: json['globalNo'] ?? 0,
      dimCode: json['dimCode'] ?? '',
      dimName: json['dimName'] ?? '',
      leftLabel: json['leftLabel'] ?? '',
      rightLabel: json['rightLabel'] ?? '',
      question: json['question'] ?? '',
      isReverse: json['isReverse'] ?? false,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'version': version,
      'globalNo': globalNo,
      'dimCode': dimCode,
      'dimName': dimName,
      'leftLabel': leftLabel,
      'rightLabel': rightLabel,
      'question': question,
      'isReverse': isReverse,
      if (note != null) 'note': note,
    };
  }

  @override
  String toString() {
    return 'InvestmentQuestion(questionId: $questionId, globalNo: $globalNo, question: $question)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvestmentQuestion &&
        other.questionId == questionId &&
        other.globalNo == globalNo;
  }

  @override
  int get hashCode => Object.hash(questionId, globalNo);
}
