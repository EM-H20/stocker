/// 퀴즈 문제 정보 모델
/// 백엔드 데이터 구조와 호환되도록 설계
class QuizInfo {
  final int id;
  final int chapterId; // 백엔드 chapter_id와 매칭
  final String question;
  final List<String> options; // option_1~4를 배열로 변환
  final int correctAnswerIndex; // correct_option(1~4) → (0~3)으로 변환
  final String explanation; // hint 필드와 매칭

  const QuizInfo({
    required this.id,
    required this.chapterId,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  /// 백엔드 JSON에서 QuizInfo 객체 생성
  /// 백엔드: option_1~4 개별 필드, correct_option(1~4), hint
  /// 프론트엔드: options 배열, correctAnswerIndex(0~3), explanation
  factory QuizInfo.fromBackendJson(Map<String, dynamic> json) {
    // option_1~4를 배열로 변환
    final options = <String>[
      json['option_1'] as String? ?? '',
      json['option_2'] as String? ?? '',
      json['option_3'] as String? ?? '',
      json['option_4'] as String? ?? '',
    ];
    
    // correct_option(1~4)을 correctAnswerIndex(0~3)로 변환
    final correctOption = json['correct_option'] as int? ?? 1;
    final correctAnswerIndex = correctOption - 1; // 1-based → 0-based
    
    return QuizInfo(
      id: json['id'] as int,
      chapterId: json['chapter_id'] as int,
      question: json['question'] as String,
      options: options,
      correctAnswerIndex: correctAnswerIndex.clamp(0, 3), // 안전장치
      explanation: json['hint'] as String? ?? '',
    );
  }

  /// 기존 Mock 데이터용 JSON 변환 (하위 호환성)
  factory QuizInfo.fromJson(Map<String, dynamic> json) {
    return QuizInfo(
      id: json['id'] as int,
      chapterId: json['chapterId'] as int? ?? json['chapter_id'] as int? ?? 0,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  /// 백엔드 형태로 JSON 변환 (필요시 사용)
  Map<String, dynamic> toBackendJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'question': question,
      'option_1': options.isNotEmpty ? options[0] : '',
      'option_2': options.length > 1 ? options[1] : '',
      'option_3': options.length > 2 ? options[2] : '',
      'option_4': options.length > 3 ? options[3] : '',
      'correct_option': correctAnswerIndex + 1, // 0-based → 1-based
      'hint': explanation,
    };
  }

  /// Mock/기존 형태로 JSON 변환 (하위 호환성)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterId': chapterId,
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
    return 'QuizInfo(id: $id, chapterId: $chapterId, question: $question, correctAnswerIndex: $correctAnswerIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizInfo &&
        other.id == id &&
        other.chapterId == chapterId &&
        other.question == question &&
        other.correctAnswerIndex == correctAnswerIndex;
  }

  @override
  int get hashCode => Object.hash(id, chapterId, question, correctAnswerIndex);
}
