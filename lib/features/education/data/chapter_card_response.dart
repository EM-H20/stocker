/// 챕터 목록 조회 응답 모델
/// 백엔드 DTO: ChapterCardResponseDto
class ChapterCardResponse {
  final int chapterId;
  final String title;
  final String? keyword; // 쉼표로 구분된 키워드 (검색용)
  final bool isTheoryCompleted;
  final bool isQuizCompleted;
  final bool isChapterCompleted;

  const ChapterCardResponse({
    required this.chapterId,
    required this.title,
    this.keyword,
    required this.isTheoryCompleted,
    required this.isQuizCompleted,
    required this.isChapterCompleted,
  });

  /// JSON에서 객체로 변환
  factory ChapterCardResponse.fromJson(Map<String, dynamic> json) {
    return ChapterCardResponse(
      chapterId: json['chapter_id'] as int,
      title: json['title'] as String,
      keyword: json['keyword'] as String?,
      isTheoryCompleted: json['is_theory_completed'] as bool? ?? false,
      isQuizCompleted: json['is_quiz_completed'] as bool? ?? false,
      // 백엔드에서 is_chapter_completed 필드가 없는 경우 false로 기본값 설정
      // 실제로는 이론+퀴즈 완료 시 Flutter에서 자동으로 true로 업데이트됨
      isChapterCompleted: json['is_chapter_completed'] as bool? ?? false,
    );
  }

  /// 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'title': title,
      'keyword': keyword,
      'isTheoryCompleted': isTheoryCompleted,
      'isQuizCompleted': isQuizCompleted,
      'isChapterCompleted': isChapterCompleted,
    };
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'ChapterCardResponse(chapterId: $chapterId, title: $title, '
        'keyword: $keyword, isTheoryCompleted: $isTheoryCompleted, '
        'isQuizCompleted: $isQuizCompleted, isChapterCompleted: $isChapterCompleted)';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChapterCardResponse &&
        other.chapterId == chapterId &&
        other.title == title &&
        other.keyword == keyword &&
        other.isTheoryCompleted == isTheoryCompleted &&
        other.isQuizCompleted == isQuizCompleted &&
        other.isChapterCompleted == isChapterCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(chapterId, title, keyword, isTheoryCompleted,
        isQuizCompleted, isChapterCompleted);
  }

  /// 복사본 생성 (일부 필드만 변경)
  ChapterCardResponse copyWith({
    int? chapterId,
    String? title,
    String? keyword,
    bool? isTheoryCompleted,
    bool? isQuizCompleted,
    bool? isChapterCompleted,
  }) {
    return ChapterCardResponse(
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      keyword: keyword ?? this.keyword,
      isTheoryCompleted: isTheoryCompleted ?? this.isTheoryCompleted,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
      isChapterCompleted: isChapterCompleted ?? this.isChapterCompleted,
    );
  }
}
