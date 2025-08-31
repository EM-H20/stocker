/// 메모 조회 응답 모델
/// API.md 명세: GET /api/memo/
class MemoListResponse {
  final List<MemoDto> memos;

  MemoListResponse({required this.memos});

  factory MemoListResponse.fromJson(Map<String, dynamic> json) {
    return MemoListResponse(
      memos: (json['memos'] as List<dynamic>? ?? [])
          .map((memoData) => MemoDto.fromJson(memoData as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memos': memos.map((memo) => memo.toJson()).toList(),
    };
  }
}

/// 메모 단일 응답 모델
/// API.md 명세: PUT /api/memo/ 응답
class MemoSingleResponse {
  final MemoDto memo;

  MemoSingleResponse({required this.memo});

  factory MemoSingleResponse.fromJson(Map<String, dynamic> json) {
    return MemoSingleResponse(
      memo: MemoDto.fromJson(json['memo'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memo': memo.toJson(),
    };
  }
}

/// 메모 DTO 모델
class MemoDto {
  final int id;
  final int userId;
  final String templateType;
  final Map<String, dynamic> content;
  final String createdAt;

  MemoDto({
    required this.id,
    required this.userId,
    required this.templateType,
    required this.content,
    required this.createdAt,
  });

  factory MemoDto.fromJson(Map<String, dynamic> json) {
    return MemoDto(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      templateType: json['template_type'] ?? '',
      content: json['content'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'template_type': templateType,
      'content': content,
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'MemoDto(id: $id, templateType: $templateType, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoDto &&
        other.id == id &&
        other.templateType == templateType;
  }

  @override
  int get hashCode => Object.hash(id, templateType);

  /// 복사본 생성
  MemoDto copyWith({
    int? id,
    int? userId,
    String? templateType,
    Map<String, dynamic>? content,
    String? createdAt,
  }) {
    return MemoDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      templateType: templateType ?? this.templateType,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 메모 삭제 응답 모델
/// API.md 명세: DELETE /api/memo/{id} 응답
class MemoDeleteResponse {
  final bool success;

  MemoDeleteResponse({required this.success});

  factory MemoDeleteResponse.fromJson(Map<String, dynamic> json) {
    return MemoDeleteResponse(
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
    };
  }
}