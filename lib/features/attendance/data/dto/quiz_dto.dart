//# (서버 수신용) 출석 퀴즈 목록 DTO

import '../../domain/model/attendance_quiz.dart';

/// 서버로부터 출석 퀴즈 목록을 수신하는 DTO
class QuizDto {
  final List<AttendanceQuiz> quizzes;

  QuizDto({required this.quizzes});

  factory QuizDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> quizList = json['quizzes'] as List<dynamic>? ?? [];

    return QuizDto(
      quizzes: quizList.map((item) {
        final mapItem = item as Map<String, dynamic>? ?? {};
        return AttendanceQuiz(
          id: mapItem['id'] as int? ?? 0,
          question: mapItem['question'] as String? ?? '',
          answer: mapItem['answer'] as bool? ?? false,
        );
      }).toList(),
    );
  }
}
