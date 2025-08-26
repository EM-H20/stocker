import '../../../../features/aptitude/domain/model/aptitude_question.dart';


// features/aptitude/data/dto/aptitude_question_dto.dart
/// 서버로부터 질문 목록을 수신하는 DTO
class AptitudeQuestionDto {
  final int id;
  final String text;
  final List<AptitudeChoiceDto> choices;

  AptitudeQuestionDto({
    required this.id,
    required this.text,
    required this.choices,
  });

  factory AptitudeQuestionDto.fromJson(Map<String, dynamic> json) {
    var choiceList = json['choices'] as List? ?? [];
    List<AptitudeChoiceDto> choices = choiceList.map((i) => AptitudeChoiceDto.fromJson(i)).toList();
    
    return AptitudeQuestionDto(
      id: json['id'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      choices: choices,
    );
  }

  // DTO를 도메인 모델로 변환
  AptitudeQuestion toModel() {
    return AptitudeQuestion(
      id: id,
      text: text,
      choices: choices.map((c) => c.toModel()).toList(),
    );
  }
}

class AptitudeChoiceDto {
  final String text;
  final int value;

  AptitudeChoiceDto({required this.text, required this.value});

  factory AptitudeChoiceDto.fromJson(Map<String, dynamic> json) {
    return AptitudeChoiceDto(
      text: json['text'] as String? ?? '',
      value: json['value'] as int? ?? 0,
    );
  }

  AptitudeChoice toModel() {
    return AptitudeChoice(text: text, value: value);
  }
}