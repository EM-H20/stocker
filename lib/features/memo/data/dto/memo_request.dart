/// 메모 저장/갱신 요청 모델
/// API.md 명세: PUT /api/memo/
class MemoRequest {
  final int? id; // 갱신 시에만 필요
  final String templateType;
  final Map<String, dynamic> content;

  MemoRequest({
    this.id,
    required this.templateType,
    required this.content,
  });

  /// 신규 메모 저장용 생성자
  MemoRequest.create({
    required this.templateType,
    required this.content,
  }) : id = null;

  /// 기존 메모 갱신용 생성자
  MemoRequest.update({
    required int this.id,
    required this.templateType,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'template_type': templateType,
      'content': content,
    };
    
    if (id != null) {
      data['id'] = id!;
    }
    
    return data;
  }

  factory MemoRequest.fromJson(Map<String, dynamic> json) {
    return MemoRequest(
      id: json['id'],
      templateType: json['template_type'] ?? '',
      content: json['content'] as Map<String, dynamic>? ?? {},
    );
  }

  /// 신규 저장인지 확인
  bool get isCreate => id == null;
  
  /// 갱신인지 확인
  bool get isUpdate => id != null;

  @override
  String toString() {
    return 'MemoRequest(id: $id, templateType: $templateType, isCreate: $isCreate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoRequest &&
        other.id == id &&
        other.templateType == templateType;
  }

  @override
  int get hashCode => Object.hash(id, templateType);

  /// 복사본 생성
  MemoRequest copyWith({
    int? id,
    String? templateType,
    Map<String, dynamic>? content,
  }) {
    return MemoRequest(
      id: id ?? this.id,
      templateType: templateType ?? this.templateType,
      content: content ?? this.content,
    );
  }
}