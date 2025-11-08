/// 메모 템플릿 타입 enum
/// API.md DB 스키마 기준: ENUM('일지','복기','체크리스트','자유','재무제표')
enum MemoTemplateType {
  journal('일지'),
  review('복기'),
  checklist('체크리스트'),
  free('자유'),
  financialStatement('재무제표');

  const MemoTemplateType(this.displayName);

  /// 화면에 표시될 한글 이름
  final String displayName;

  /// 서버로 전송할 때 사용하는 문자열 값
  String get serverValue => displayName;

  /// 서버에서 받은 문자열을 enum으로 변환
  static MemoTemplateType fromServerValue(String serverValue) {
    for (final type in MemoTemplateType.values) {
      if (type.serverValue == serverValue) {
        return type;
      }
    }
    throw ArgumentError('Unknown memo template type: $serverValue');
  }

  /// 서버에서 받은 문자열을 enum으로 변환 (null 허용)
  static MemoTemplateType? fromServerValueOrNull(String? serverValue) {
    if (serverValue == null) return null;
    try {
      return fromServerValue(serverValue);
    } catch (e) {
      return null;
    }
  }

  /// 모든 템플릿 타입의 서버 값 목록
  static List<String> get allServerValues =>
      values.map((type) => type.serverValue).toList();

  /// 사용자 친화적인 설명
  String get description {
    switch (this) {
      case MemoTemplateType.journal:
        return '일상적인 투자 기록이나 생각을 정리';
      case MemoTemplateType.review:
        return '투자 결과나 경험을 되돌아보고 분석';
      case MemoTemplateType.checklist:
        return '투자 전 체크할 항목들을 목록으로 관리';
      case MemoTemplateType.free:
        return '자유롭게 메모하고 싶은 내용';
      case MemoTemplateType.financialStatement:
        return '재무제표 분석 내용 정리';
    }
  }

  /// 아이콘 정보 (Material Icons 코드포인트)
  int get iconCodePoint {
    switch (this) {
      case MemoTemplateType.journal:
        return 0xe7f0; // Icons.book
      case MemoTemplateType.review:
        return 0xe86c; // Icons.rate_review
      case MemoTemplateType.checklist:
        return 0xe6b1; // Icons.checklist
      case MemoTemplateType.free:
        return 0xe3c9; // Icons.edit_note
      case MemoTemplateType.financialStatement:
        return 0xe85c; // Icons.pie_chart
    }
  }

  @override
  String toString() => displayName;
}
