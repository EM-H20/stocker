import 'theory_info.dart';

/// 이론 학습 세션 도메인 모델
/// Presentation 계층에서 사용하는 이론 학습 데이터
class TheorySession {
  final int chapterId;
  final String chapterTitle;
  final List<TheoryInfo> theories;
  final int currentTheoryIndex;

  const TheorySession({
    required this.chapterId,
    required this.chapterTitle,
    required this.theories,
    required this.currentTheoryIndex,
  });

  /// 현재 이론 정보
  TheoryInfo? get currentTheory {
    if (currentTheoryIndex >= 0 && currentTheoryIndex < theories.length) {
      return theories[currentTheoryIndex];
    }
    return null;
  }

  /// 전체 이론 개수
  int get totalCount => theories.length;

  /// 다음 이론이 있는지 확인
  bool get hasNext => currentTheoryIndex < theories.length - 1;

  /// 이전 이론이 있는지 확인
  bool get hasPrevious => currentTheoryIndex > 0;

  /// 다음 이론 정보
  TheoryInfo? get nextTheory {
    if (hasNext) {
      return theories[currentTheoryIndex + 1];
    }
    return null;
  }

  /// 이전 이론 정보
  TheoryInfo? get previousTheory {
    if (hasPrevious) {
      return theories[currentTheoryIndex - 1];
    }
    return null;
  }

  /// 현재 진행률 (0.0 ~ 1.0)
  double get progressRatio {
    if (theories.isEmpty) return 0.0;
    return (currentTheoryIndex + 1) / theories.length;
  }

  /// 복사본 생성
  TheorySession copyWith({
    int? chapterId,
    String? chapterTitle,
    List<TheoryInfo>? theories,
    int? currentTheoryIndex,
  }) {
    return TheorySession(
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      theories: theories ?? this.theories,
      currentTheoryIndex: currentTheoryIndex ?? this.currentTheoryIndex,
    );
  }

  @override
  String toString() {
    return 'TheorySession(chapterId: $chapterId, chapterTitle: $chapterTitle, '
        'theories: ${theories.length} items, currentTheoryIndex: $currentTheoryIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TheorySession &&
        other.chapterId == chapterId &&
        other.chapterTitle == chapterTitle &&
        other.currentTheoryIndex == currentTheoryIndex &&
        _listEquals(other.theories, theories);
  }

  @override
  int get hashCode {
    return Object.hash(chapterId, chapterTitle, currentTheoryIndex, theories);
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
