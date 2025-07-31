/// 챕터 진행 상황 모델
/// 백엔드 Entity: ChapterProgress
class ChapterProgress {
  final int id;
  final int userId;
  final int chapterId;
  final bool isTheoryCompleted;
  final bool isQuizCompleted;
  final bool isChapterCompleted;
  final int? currentTheoryId;
  final int? currentQuizId;

  const ChapterProgress({
    required this.id,
    required this.userId,
    required this.chapterId,
    required this.isTheoryCompleted,
    required this.isQuizCompleted,
    required this.isChapterCompleted,
    this.currentTheoryId,
    this.currentQuizId,
  });

  /// JSON에서 객체로 변환
  factory ChapterProgress.fromJson(Map<String, dynamic> json) {
    return ChapterProgress(
      id: json['id'] as int,
      userId: json['userId'] as int,
      chapterId: json['chapterId'] as int,
      isTheoryCompleted: json['isTheoryCompleted'] as bool? ?? false,
      isQuizCompleted: json['isQuizCompleted'] as bool? ?? false,
      isChapterCompleted: json['isChapterCompleted'] as bool? ?? false,
      currentTheoryId: json['currentTheoryId'] as int?,
      currentQuizId: json['currentQuizId'] as int?,
    );
  }

  /// 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'chapterId': chapterId,
      'isTheoryCompleted': isTheoryCompleted,
      'isQuizCompleted': isQuizCompleted,
      'isChapterCompleted': isChapterCompleted,
      'currentTheoryId': currentTheoryId,
      'currentQuizId': currentQuizId,
    };
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'ChapterProgress(id: $id, userId: $userId, chapterId: $chapterId, '
        'isTheoryCompleted: $isTheoryCompleted, isQuizCompleted: $isQuizCompleted, '
        'isChapterCompleted: $isChapterCompleted, currentTheoryId: $currentTheoryId, '
        'currentQuizId: $currentQuizId)';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChapterProgress &&
        other.id == id &&
        other.userId == userId &&
        other.chapterId == chapterId &&
        other.isTheoryCompleted == isTheoryCompleted &&
        other.isQuizCompleted == isQuizCompleted &&
        other.isChapterCompleted == isChapterCompleted &&
        other.currentTheoryId == currentTheoryId &&
        other.currentQuizId == currentQuizId;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        chapterId,
        isTheoryCompleted,
        isQuizCompleted,
        isChapterCompleted,
        currentTheoryId,
        currentQuizId,
      );

  /// 복사본 생성
  ChapterProgress copyWith({
    int? id,
    int? userId,
    int? chapterId,
    bool? isTheoryCompleted,
    bool? isQuizCompleted,
    bool? isChapterCompleted,
    int? currentTheoryId,
    int? currentQuizId,
  }) {
    return ChapterProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      chapterId: chapterId ?? this.chapterId,
      isTheoryCompleted: isTheoryCompleted ?? this.isTheoryCompleted,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
      isChapterCompleted: isChapterCompleted ?? this.isChapterCompleted,
      currentTheoryId: currentTheoryId ?? this.currentTheoryId,
      currentQuizId: currentQuizId ?? this.currentQuizId,
    );
  }
}
