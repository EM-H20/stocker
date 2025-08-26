// features/aptitude/domain/model/aptitude_question.dart
/// 성향 분석 질문 한 개를 나타내는 모델
class AptitudeQuestion {
  final int id;
  final String text;
  final List<AptitudeChoice> choices;

  AptitudeQuestion({
    required this.id,
    required this.text,
    required this.choices,
  });
}

/// 질문에 대한 선택지를 나타내는 모델
class AptitudeChoice {
  final String text;
  final int value;

  AptitudeChoice({required this.text, required this.value});
}
