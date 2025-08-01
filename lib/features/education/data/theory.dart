import '../domain/models/theory_info.dart';

/// 개별 이론 정보 모델
/// TheoryEnterResponseDto 내부의 theories 배열 요소
class Theory {
  final int theoryId;
  final String word;
  final String content;

  const Theory({
    required this.theoryId,
    required this.word,
    required this.content,
  });

  /// JSON에서 객체로 변환
  factory Theory.fromJson(Map<String, dynamic> json) {
    return Theory(
      theoryId: json['theoryId'] as int,
      word: json['word'] as String,
      content: json['content'] as String,
    );
  }

  /// 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {'theoryId': theoryId, 'word': word, 'content': content};
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'Theory(theoryId: $theoryId, word: $word, content: $content)';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Theory &&
        other.theoryId == theoryId &&
        other.word == word &&
        other.content == content;
  }

  @override
  int get hashCode => Object.hash(theoryId, word, content);

  /// 복사본 생성
  Theory copyWith({int? theoryId, String? word, String? content}) {
    return Theory(
      theoryId: theoryId ?? this.theoryId,
      word: word ?? this.word,
      content: content ?? this.content,
    );
  }

  /// 도메인 모델로 변환
  /// Theory(data) → TheoryInfo(domain)
  TheoryInfo toDomain() {
    return TheoryInfo(id: theoryId, word: word, content: content);
  }
}
