/// 출석 퀴즈 한 문제에 대한 정보를 나타내는 모델
class AttendanceQuiz {
  final int id; // 퀴즈 고유 ID
  final String question; // 퀴즈 질문
  final bool answer; // 정답 (true: O, false: X)

  AttendanceQuiz({
    required this.id,
    required this.question,
    required this.answer,
  });
}
