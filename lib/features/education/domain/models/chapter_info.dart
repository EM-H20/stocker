/// 챕터 정보 도메인 모델
/// Presentation 계층에서 사용하는 챕터 데이터
class ChapterInfo {
  final int id;
  final String title;
  final String? description; // 백엔드 데이터와 매칭
  final bool isTheoryCompleted;
  final bool isQuizCompleted;

  const ChapterInfo({
    required this.id,
    required this.title,
    this.description,
    required this.isTheoryCompleted,
    required this.isQuizCompleted,
  });

  /// 백엔드 JSON에서 ChapterInfo 객체 생성
  /// 백엔드 응답에는 progress 정보가 없으므로 기본값으로 설정
  factory ChapterInfo.fromBackendJson(Map<String, dynamic> json) {
    return ChapterInfo(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      isTheoryCompleted: false, // 별도 API로 조회 필요
      isQuizCompleted: false, // 별도 API로 조회 필요
    );
  }

  /// 백엔드 JSON으로 변환 (필요시 사용)
  Map<String, dynamic> toBackendJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  /// 복사본 생성
  /// 이유 : Provider에서 챕터 정보를 업데이트할 때 사용
  ChapterInfo copyWith({
    int? id,
    String? title,
    String? description,
    bool? isTheoryCompleted,
    bool? isQuizCompleted,
  }) {
    return ChapterInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isTheoryCompleted: isTheoryCompleted ?? this.isTheoryCompleted,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
    );
  }

  @override
  String toString() {
    return 'ChapterInfo(id: $id, title: $title, description: $description, '
        'isTheoryCompleted: $isTheoryCompleted, isQuizCompleted: $isQuizCompleted)';
  }

  // chapterInfo가 같은지 비교(id, title, description, isTheoryCompleted, isQuizCompleted)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChapterInfo &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isTheoryCompleted == isTheoryCompleted &&
        other.isQuizCompleted == isQuizCompleted;
  }

  // chapterInfo의 해시코드
  @override
  int get hashCode {
    return Object.hash(
        id, title, description, isTheoryCompleted, isQuizCompleted);
  }
}
