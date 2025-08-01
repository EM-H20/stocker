/// 이론 완료 처리 요청 모델
/// 백엔드 DTO: TheoryCompletedRequestDto
class TheoryCompletedRequest {
  final int chapterId;

  const TheoryCompletedRequest({required this.chapterId});

  /// JSON에서 객체로 변환
  factory TheoryCompletedRequest.fromJson(Map<String, dynamic> json) {
    return TheoryCompletedRequest(chapterId: json['chapterId'] as int);
  }

  /// 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() => {'chapterId': chapterId};

  /// 디버깅용 문자열 표현
  @override
  String toString() => 'TheoryCompletedRequest(chapterId: $chapterId)';

  /// 동등성 비교
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TheoryCompletedRequest && other.chapterId == chapterId;

  @override
  int get hashCode => chapterId.hashCode;

  /// 복사본 생성
  TheoryCompletedRequest copyWith({int? chapterId}) {
    return TheoryCompletedRequest(chapterId: chapterId ?? this.chapterId);
  }
}
