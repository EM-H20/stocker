/// 이론 페이지 모델
/// API.md 명세의 theory_pages 항목
class TheoryPage {
  final int pageNo;
  final int id;
  final String word;
  final String content;

  const TheoryPage({
    required this.pageNo,
    required this.id,
    required this.word,
    required this.content,
  });

  factory TheoryPage.fromJson(Map<String, dynamic> json) {
    return TheoryPage(
      pageNo: json['page_no'] ?? 0,
      id: json['id'] ?? 0,
      word: json['Word'] ?? '', // API.md에서는 'Word' (대문자)
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page_no': pageNo,
      'id': id,
      'Word': word,
      'content': content,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TheoryPage &&
        other.pageNo == pageNo &&
        other.id == id &&
        other.word == word &&
        other.content == content;
  }

  @override
  int get hashCode {
    return Object.hash(pageNo, id, word, content);
  }

  @override
  String toString() {
    return 'TheoryPage(pageNo: $pageNo, id: $id, word: $word, content: $content)';
  }
}

/// 이론 진입 응답 모델
/// API.md 명세: POST /api/theory/enter
class TheoryEnterResponse {
  final List<TheoryPage> theoryPages;
  final int totalPages;
  final int currentPage;

  const TheoryEnterResponse({
    required this.theoryPages,
    required this.totalPages,
    required this.currentPage,
  });

  /// JSON에서 객체로 변환
  factory TheoryEnterResponse.fromJson(Map<String, dynamic> json) {
    return TheoryEnterResponse(
      theoryPages: (json['theory_pages'] as List<dynamic>)
          .map((pageJson) =>
              TheoryPage.fromJson(pageJson as Map<String, dynamic>))
          .toList(),
      totalPages: json['total_pages'] ?? 0,
      currentPage: json['current_page'] ?? 1,
    );
  }

  /// 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'theory_pages': theoryPages.map((page) => page.toJson()).toList(),
      'total_pages': totalPages,
      'current_page': currentPage,
    };
  }

  /// 현재 페이지 객체 반환
  TheoryPage? get currentTheoryPage {
    try {
      return theoryPages.firstWhere((page) => page.pageNo == currentPage);
    } catch (e) {
      return null;
    }
  }

  /// 현재 페이지의 인덱스 반환 (0부터 시작)
  int get currentPageIndex {
    return theoryPages.indexWhere((page) => page.pageNo == currentPage);
  }

  /// 다음 페이지가 있는지 확인
  bool get hasNextPage {
    return currentPage < totalPages;
  }

  /// 이전 페이지가 있는지 확인
  bool get hasPreviousPage {
    return currentPage > 1;
  }

  /// 다음 페이지 객체 반환
  TheoryPage? get nextPage {
    if (!hasNextPage) return null;
    try {
      return theoryPages.firstWhere((page) => page.pageNo == currentPage + 1);
    } catch (e) {
      return null;
    }
  }

  /// 이전 페이지 객체 반환
  TheoryPage? get previousPage {
    if (!hasPreviousPage) return null;
    try {
      return theoryPages.firstWhere((page) => page.pageNo == currentPage - 1);
    } catch (e) {
      return null;
    }
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'TheoryEnterResponse(theoryPages: ${theoryPages.length}, totalPages: $totalPages, currentPage: $currentPage)';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TheoryEnterResponse &&
        other.totalPages == totalPages &&
        other.currentPage == currentPage &&
        _listEquals(other.theoryPages, theoryPages);
  }

  @override
  int get hashCode {
    return Object.hash(totalPages, currentPage, theoryPages);
  }

  /// 복사본 생성
  TheoryEnterResponse copyWith({
    List<TheoryPage>? theoryPages,
    int? totalPages,
    int? currentPage,
  }) {
    return TheoryEnterResponse(
      theoryPages: theoryPages ?? this.theoryPages,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
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
