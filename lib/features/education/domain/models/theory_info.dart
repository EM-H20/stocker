/// 개별 이론 정보 도메인 모델
/// Presentation 계층에서 사용하는 이론 데이터
class TheoryInfo {
  final int id;
  final String word;
  final String content;

  const TheoryInfo({
    required this.id,
    required this.word,
    required this.content,
  });

  /// 복사본 생성
  /// 이유 : Provider에서 이론 정보를 업데이트할 때 사용
  TheoryInfo copyWith({int? id, String? word, String? content}) {
    return TheoryInfo(
      id: id ?? this.id,
      word: word ?? this.word,
      content: content ?? this.content,
    );
  }

  @override
  String toString() {
    return 'TheoryInfo(id: $id, word: $word, content: $content)';
  }

  // theoryInfo가 같은지 비교(id, word, content)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TheoryInfo &&
        other.id == id &&
        other.word == word &&
        other.content == content;
  }

  // theoryInfo의 해시코드
  @override
  int get hashCode => Object.hash(id, word, content);
}
