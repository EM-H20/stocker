import '../../../../features/aptitude/domain/model/aptitude_question.dart';

// features/aptitude/data/dto/aptitude_question_dto.dart
/// 서버로부터 질문 목록을 수신하는 DTO (백엔드 실제 응답 구조에 맞춤)
class AptitudeQuestionDto {
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

  AptitudeQuestionDto({
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

  factory AptitudeQuestionDto.fromJson(Map<String, dynamic> json) {
    return AptitudeQuestionDto(
      questionId: json['questionId'] as int? ?? 0,
      version: json['version'] as String? ?? 'v1.1',
      globalNo: json['globalNo'] as int? ?? 0,
      dimCode: json['dimCode'] as String? ?? '',
      dimName: json['dimName'] as String? ?? '',
      leftLabel: json['leftLabel'] as String? ?? '',
      rightLabel: json['rightLabel'] as String? ?? '',
      question: json['question'] as String? ?? '',
      isReverse: json['isReverse'] as bool? ?? false,
      note: json['note'] as String?,
    );
  }

  // DTO를 도메인 모델로 변환
  AptitudeQuestion toModel() {
    // 1-5 스케일 선택지 생성 (leftLabel ~ rightLabel)
    final choices = List.generate(5, (index) {
      final value = index + 1;
      String text;

      if (value == 1) {
        text = '$leftLabel (매우 그렇다)';
      } else if (value == 2) {
        text = '$leftLabel (그렇다)';
      } else if (value == 3) {
        text = '보통';
      } else if (value == 4) {
        text = '$rightLabel (그렇다)';
      } else {
        text = '$rightLabel (매우 그렇다)';
      }

      return AptitudeChoice(
        text: text,
        value: isReverse ? (6 - value) : value, // 역방향 질문 처리
      );
    });

    return AptitudeQuestion(
      id: questionId,
      text: question,
      choices: choices,
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
