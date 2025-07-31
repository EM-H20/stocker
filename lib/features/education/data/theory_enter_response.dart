import 'theory.dart';

/// 이론 진입 응답 모델
/// 백엔드 DTO: TheoryEnterResponseDto
class TheoryEnterResponse {
  final int chapterId;
  final String chapterTitle;
  final List<Theory> theories;
  final int currentTheoryId;

  const TheoryEnterResponse({
    required this.chapterId,
    required this.chapterTitle,
    required this.theories,
    required this.currentTheoryId,
  });

  /// JSON에서 객체로 변환
  factory TheoryEnterResponse.fromJson(Map<String, dynamic> json) {
    return TheoryEnterResponse(
      chapterId: json['chapterId'] as int,
      chapterTitle: json['chapterTitle'] as String,
      theories: (json['theories'] as List<dynamic>)
          .map((theoryJson) => Theory.fromJson(theoryJson as Map<String, dynamic>))
          .toList(),
      currentTheoryId: json['currentTheoryId'] as int,
    );
  }

  /// 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'theories': theories.map((theory) => theory.toJson()).toList(),
      'currentTheoryId': currentTheoryId,
    };
  }

  /// 현재 이론 객체 반환
  Theory? get currentTheory {
    try {
      return theories.firstWhere((theory) => theory.theoryId == currentTheoryId);
    } catch (e) {
      return null;
    }
  }

  /// 현재 이론의 인덱스 반환
  int get currentTheoryIndex {
    return theories.indexWhere((theory) => theory.theoryId == currentTheoryId);
  }

  /// 다음 이론이 있는지 확인
  bool get hasNextTheory {
    final currentIndex = currentTheoryIndex;
    return currentIndex >= 0 && currentIndex < theories.length - 1;
  }

  /// 이전 이론이 있는지 확인
  bool get hasPreviousTheory {
    final currentIndex = currentTheoryIndex;
    return currentIndex > 0;
  }

  /// 다음 이론 객체 반환
  Theory? get nextTheory {
    if (!hasNextTheory) return null;
    return theories[currentTheoryIndex + 1];
  }

  /// 이전 이론 객체 반환
  Theory? get previousTheory {
    if (!hasPreviousTheory) return null;
    return theories[currentTheoryIndex - 1];
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'TheoryEnterResponse(chapterId: $chapterId, chapterTitle: $chapterTitle, '
        'theories: ${theories.length} items, currentTheoryId: $currentTheoryId)';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TheoryEnterResponse &&
        other.chapterId == chapterId &&
        other.chapterTitle == chapterTitle &&
        other.currentTheoryId == currentTheoryId &&
        _listEquals(other.theories, theories);
  }

  @override
  int get hashCode {
    return Object.hash(chapterId, chapterTitle, currentTheoryId, theories);
  }

  /// 복사본 생성
  TheoryEnterResponse copyWith({
    int? chapterId,
    String? chapterTitle,
    List<Theory>? theories,
    int? currentTheoryId,
  }) {
    return TheoryEnterResponse(
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      theories: theories ?? this.theories,
      currentTheoryId: currentTheoryId ?? this.currentTheoryId,
    );
  }

  /// 리스트 동등성 비교 헬퍼 함수
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
