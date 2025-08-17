/// 오답노트 응답 모델
class WrongNoteResponse {
  final List<WrongNoteItem> wrongNotes;

  const WrongNoteResponse({
    required this.wrongNotes,
  });

  /// JSON에서 객체 생성
  factory WrongNoteResponse.fromJson(Map<String, dynamic> json) {
    return WrongNoteResponse(
      wrongNotes: (json['wrong_notes'] as List)
          .map((item) => WrongNoteItem.fromJson(item))
          .toList(),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'wrong_notes': wrongNotes.map((item) => item.toJson()).toList(),
    };
  }
}

/// 오답노트 항목 모델 (기존 WrongAnswerItem을 대체)
class WrongNoteItem {
  final int id;
  final int chapterId;
  final String chapterTitle;
  final int quizId;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String userAnswer;
  final String explanation;
  final DateTime wrongDate;
  final bool isRetried;

  const WrongNoteItem({
    required this.id,
    required this.chapterId,
    required this.chapterTitle,
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.userAnswer,
    required this.explanation,
    required this.wrongDate,
    this.isRetried = false,
  });

  /// JSON에서 객체 생성
  factory WrongNoteItem.fromJson(Map<String, dynamic> json) {
    return WrongNoteItem(
      id: json['id'] as int,
      chapterId: json['chapter_id'] as int,
      chapterTitle: json['chapter_title'] as String? ?? '',
      quizId: json['quiz_id'] as int,
      question: json['question'] as String,
      options: json['options'] != null 
          ? List<String>.from(json['options'] as List)
          : [],
      correctAnswer: json['correct_answer'] as String,
      userAnswer: json['user_answer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      wrongDate: json['wrong_date'] != null
          ? DateTime.parse(json['wrong_date'] as String)
          : DateTime.now(),
      isRetried: json['is_retried'] as bool? ?? false,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'chapter_title': chapterTitle,
      'quiz_id': quizId,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'user_answer': userAnswer,
      'explanation': explanation,
      'wrong_date': wrongDate.toIso8601String(),
      'is_retried': isRetried,
    };
  }

  /// 재시도 상태 변경
  WrongNoteItem copyWith({
    int? id,
    int? chapterId,
    String? chapterTitle,
    int? quizId,
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? userAnswer,
    String? explanation,
    DateTime? wrongDate,
    bool? isRetried,
  }) {
    return WrongNoteItem(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      quizId: quizId ?? this.quizId,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      explanation: explanation ?? this.explanation,
      wrongDate: wrongDate ?? this.wrongDate,
      isRetried: isRetried ?? this.isRetried,
    );
  }
}
