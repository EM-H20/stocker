/// 챕터 엔티티 모델
/// 백엔드 Entity: Chapter
class Chapter {
  final int id;
  final String title;
  final String keyword;

  const Chapter({
    required this.id,
    required this.title,
    required this.keyword,
  });

  /// JSON에서 객체로 변환
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int,
      title: json['title'] as String,
      keyword: json['keyword'] as String,
    );
  }

  /// 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'keyword': keyword,
    };
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'Chapter(id: $id, title: $title, keyword: $keyword)';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chapter &&
        other.id == id &&
        other.title == title &&
        other.keyword == keyword;
  }

  @override
  int get hashCode => Object.hash(id, title, keyword);

  /// 복사본 생성
  Chapter copyWith({
    int? id,
    String? title,
    String? keyword,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      keyword: keyword ?? this.keyword,
    );
  }
}
