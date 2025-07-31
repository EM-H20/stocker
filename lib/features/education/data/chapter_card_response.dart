/// 챕터 목록 조회 응답 모델
/// 백엔드 DTO: ChapterCardResponseDto
class ChapterCardResponse {
  final int chapterId;
  final String title;
  final bool isTheoryCompleted;
  final bool isQuizCompleted;

  const ChapterCardResponse({
    required this.chapterId,
    required this.title,
    required this.isTheoryCompleted,
    required this.isQuizCompleted,
  });

  /// JSON에서 객체로 변환
  factory ChapterCardResponse.fromJson(Map<String, dynamic> json) {
    return ChapterCardResponse(
      chapterId: json['chapterId'] as int,
      title: json['title'] as String,
      isTheoryCompleted: json['isTheoryCompleted'] as bool,
      isQuizCompleted: json['isQuizCompleted'] as bool,
    );
  }

  /// 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'title': title,
      'isTheoryCompleted': isTheoryCompleted,
      'isQuizCompleted': isQuizCompleted,
    };
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'ChapterCardResponse(chapterId: $chapterId, title: $title, '
        'isTheoryCompleted: $isTheoryCompleted, isQuizCompleted: $isQuizCompleted)';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChapterCardResponse &&
        other.chapterId == chapterId &&
        other.title == title &&
        other.isTheoryCompleted == isTheoryCompleted &&
        other.isQuizCompleted == isQuizCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(chapterId, title, isTheoryCompleted, isQuizCompleted);
  }

  /// 복사본 생성 (일부 필드만 변경)
  ChapterCardResponse copyWith({
    int? chapterId,
    String? title,
    bool? isTheoryCompleted,
    bool? isQuizCompleted,
  }) {
    return ChapterCardResponse(
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      isTheoryCompleted: isTheoryCompleted ?? this.isTheoryCompleted,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
    );
  }
}
