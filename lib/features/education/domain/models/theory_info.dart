/// 개별 이론 정보 도메인 모델
/// Presentation 계층에서 사용하는 이론 데이터
class TheoryInfo {
  final int id;
  final int? chapterId; // 백엔드 chapter_id와 매칭
  final String word;
  final String content;

  const TheoryInfo({
    required this.id,
    this.chapterId,
    required this.word,
    required this.content,
  });

  /// 백엔드 JSON에서 TheoryInfo 객체 생성
  factory TheoryInfo.fromBackendJson(Map<String, dynamic> json) {
    return TheoryInfo(
      id: json['id'] as int,
      chapterId: json['chapter_id'] as int?,
      word: json['word'] as String,
      content: json['content'] as String,
    );
  }

  /// 백엔드 JSON으로 변환 (필요시 사용)
  Map<String, dynamic> toBackendJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'word': word,
      'content': content,
    };
  }

  /// Mock/기존 JSON 변환 (하위 호환성)
  factory TheoryInfo.fromJson(Map<String, dynamic> json) {
    return TheoryInfo(
      id: json['id'] as int,
      chapterId: json['chapterId'] as int? ?? json['chapter_id'] as int?,
      word: json['word'] as String,
      content: json['content'] as String,
    );
  }

  /// Mock/기존 형태로 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterId': chapterId,
      'word': word,
      'content': content,
    };
  }

  /// 복사본 생성
  /// 이유 : Provider에서 이론 정보를 업데이트할 때 사용
  TheoryInfo copyWith({int? id, int? chapterId, String? word, String? content}) {
    return TheoryInfo(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      word: word ?? this.word,
      content: content ?? this.content,
    );
  }

  @override
  String toString() {
    return 'TheoryInfo(id: $id, chapterId: $chapterId, word: $word, content: $content)';
  }

  // theoryInfo가 같은지 비교(id, chapterId, word, content)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TheoryInfo &&
        other.id == id &&
        other.chapterId == chapterId &&
        other.word == word &&
        other.content == content;
  }

  // theoryInfo의 해시코드
  @override
  int get hashCode => Object.hash(id, chapterId, word, content);
}
