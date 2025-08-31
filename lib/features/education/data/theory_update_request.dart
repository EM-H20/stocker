/// 이론 슬라이드 진도 갱신 요청 모델
/// 백엔드 DTO: TheoryUpdateRequestDto
class TheoryUpdateRequest {
  final int chapterId;
  final int currentTheoryId;

  const TheoryUpdateRequest({
    required this.chapterId,
    required this.currentTheoryId,
  });

  /// JSON에서 객체로 변환
  factory TheoryUpdateRequest.fromJson(Map<String, dynamic> json) {
    return TheoryUpdateRequest(
      chapterId: json['chapter_id'] as int,
      currentTheoryId: json['current_theory_id'] as int,
    );
  }

  /// 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'current_theory_id': currentTheoryId,
    };
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'TheoryUpdateRequest(chapterId: $chapterId, currentTheoryId: $currentTheoryId)';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TheoryUpdateRequest &&
        other.chapterId == chapterId &&
        other.currentTheoryId == currentTheoryId;
  }

  @override
  int get hashCode => Object.hash(chapterId, currentTheoryId);

  /// 복사본 생성
  TheoryUpdateRequest copyWith({
    int? chapterId,
    int? currentTheoryId,
  }) {
    return TheoryUpdateRequest(
      chapterId: chapterId ?? this.chapterId,
      currentTheoryId: currentTheoryId ?? this.currentTheoryId,
    );
  }
}
