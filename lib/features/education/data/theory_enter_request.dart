/// 이론 진입 요청 모델
/// 백엔드 DTO: TheoryEnterRequestDto
class TheoryEnterRequest {
  final int chapterId;

  const TheoryEnterRequest({
    required this.chapterId,
  });

  /// JSON에서 객체로 변환
  factory TheoryEnterRequest.fromJson(Map<String, dynamic> json) {
    return TheoryEnterRequest(
      chapterId: json['chapter_id'] as int,
    );
  }

  /// 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
    };
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'TheoryEnterRequest(chapterId: $chapterId)';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TheoryEnterRequest && other.chapterId == chapterId;
  }

  @override
  int get hashCode => chapterId.hashCode;

  /// 복사본 생성
  TheoryEnterRequest copyWith({
    int? chapterId,
  }) {
    return TheoryEnterRequest(
      chapterId: chapterId ?? this.chapterId,
    );
  }
}
