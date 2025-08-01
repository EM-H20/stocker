/// 챕터 정보 도메인 모델
/// Presentation 계층에서 사용하는 챕터 데이터
class ChapterInfo {
  final int id;
  final String title;
  final bool isTheoryCompleted;
  final bool isQuizCompleted;

  const ChapterInfo({
    required this.id,
    required this.title,
    required this.isTheoryCompleted,
    required this.isQuizCompleted,
  });

  /// 복사본 생성
  /// 이유 : Provider에서 챕터 정보를 업데이트할 때 사용
  ChapterInfo copyWith({
    int? id,
    String? title,
    bool? isTheoryCompleted,
    bool? isQuizCompleted,
  }) {
    return ChapterInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      isTheoryCompleted: isTheoryCompleted ?? this.isTheoryCompleted,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
    );
  }

  @override
  String toString() {
    return 'ChapterInfo(id: $id, title: $title, '
        'isTheoryCompleted: $isTheoryCompleted, isQuizCompleted: $isQuizCompleted)';
  }

  // chapterInfo가 같은지 비교(id, title, isTheoryCompleted, isQuizCompleted)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChapterInfo &&
        other.id == id &&
        other.title == title &&
        other.isTheoryCompleted == isTheoryCompleted &&
        other.isQuizCompleted == isQuizCompleted;
  }

  // chapterInfo의 해시코드
  @override
  int get hashCode {
    return Object.hash(id, title, isTheoryCompleted, isQuizCompleted);
  }
}
