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

/// 오답노트 항목 모델 (백엔드 구조와 매칭)
/// 백엔드: id, quiz_id, chapter_id, user_id, selected_option, created_date
class WrongNoteItem {
  final int id;
  final int quizId;
  final int chapterId;
  final int userId;
  final int selectedOption; // 1~4 (백엔드와 동일)
  final DateTime createdDate;

  // UI 표시용 추가 정보 (JOIN으로 조회되는 데이터)
  final String? chapterTitle;
  final String? question;
  final List<String>? options;
  final String? explanation;

  const WrongNoteItem({
    required this.id,
    required this.quizId,
    required this.chapterId,
    required this.userId,
    required this.selectedOption,
    required this.createdDate,
    this.chapterTitle,
    this.question,
    this.options,
    this.explanation,
  });

  /// 백엔드 JSON에서 객체 생성 (JOIN 데이터 포함)
  factory WrongNoteItem.fromBackendJson(Map<String, dynamic> json) {
    return WrongNoteItem(
      id: json['id'] as int,
      quizId: json['quiz_id'] as int,
      chapterId: json['chapter_id'] as int,
      userId: json['user_id'] as int,
      selectedOption: json['selected_option'] as int,
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'] as String)
          : DateTime.now(),
      // JOIN된 추가 정보
      chapterTitle: json['chapter_title'] as String?,
      question: json['question'] as String?,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      explanation: json['explanation'] as String?,
    );
  }

  /// Mock/기존 JSON 변환 (하위 호환성)
  factory WrongNoteItem.fromJson(Map<String, dynamic> json) {
    return WrongNoteItem(
      id: json['id'] as int,
      chapterId: json['chapter_id'] as int,
      quizId: json['quiz_id'] as int,
      userId: json['user_id'] as int? ?? 0,
      selectedOption: json['selected_option'] as int? ?? 1,
      createdDate: json['created_date'] != null || json['wrong_date'] != null
          ? DateTime.parse(
              (json['created_date'] ?? json['wrong_date']) as String)
          : DateTime.now(),
      chapterTitle: json['chapter_title'] as String?,
      question: json['question'] as String?,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      explanation: json['explanation'] as String?,
    );
  }

  /// 백엔드 형태로 JSON 변환
  Map<String, dynamic> toBackendJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'chapter_id': chapterId,
      'user_id': userId,
      'selected_option': selectedOption,
      'created_date': createdDate.toIso8601String(),
    };
  }

  /// Mock/기존 형태로 JSON 변환 (하위 호환성)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'chapter_id': chapterId,
      'user_id': userId,
      'selected_option': selectedOption,
      'created_date': createdDate.toIso8601String(),
      'chapter_title': chapterTitle,
      'question': question,
      'options': options,
      'explanation': explanation,
    };
  }

  /// 복사본 생성
  WrongNoteItem copyWith({
    int? id,
    int? quizId,
    int? chapterId,
    int? userId,
    int? selectedOption,
    DateTime? createdDate,
    String? chapterTitle,
    String? question,
    List<String>? options,
    String? explanation,
  }) {
    return WrongNoteItem(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      chapterId: chapterId ?? this.chapterId,
      userId: userId ?? this.userId,
      selectedOption: selectedOption ?? this.selectedOption,
      createdDate: createdDate ?? this.createdDate,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      question: question ?? this.question,
      options: options ?? this.options,
      explanation: explanation ?? this.explanation,
    );
  }

  /// 정답 여부 확인
  bool get isCorrect => false; // selected_option이 정답이 아니므로 항상 false

  /// 선택한 답안 텍스트
  String get selectedAnswerText {
    if (options == null ||
        selectedOption < 1 ||
        selectedOption > options!.length) {
      return '선택 $selectedOption번';
    }
    return options![selectedOption - 1]; // 1-based → 0-based
  }
}
