/// 투자성향 검사 결과 응답 모델
/// API.md 명세: POST /api/investment_profile/result 응답
class InvestmentResultResponse {
  final bool created;
  final int profileId;
  final int userId;
  final String typeCode;
  final List<InvestmentMaster> matchedMaster;
  final InvestmentComputed? computed;

  InvestmentResultResponse({
    required this.created,
    required this.profileId,
    required this.userId,
    required this.typeCode,
    required this.matchedMaster,
    this.computed,
  });

  factory InvestmentResultResponse.fromJson(Map<String, dynamic> json) {
    return InvestmentResultResponse(
      created: json['created'] ?? false,
      profileId: json['profile_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      typeCode: json['type_code'] ?? '',
      matchedMaster: (json['matched_master'] as List<dynamic>? ?? [])
          .map((m) => InvestmentMaster.fromJson(m as Map<String, dynamic>))
          .toList(),
      computed: json['computed'] != null
          ? InvestmentComputed.fromJson(
              json['computed'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created': created,
      'profile_id': profileId,
      'user_id': userId,
      'type_code': typeCode,
      'matched_master': matchedMaster.map((m) => m.toJson()).toList(),
      if (computed != null) 'computed': computed!.toJson(),
    };
  }
}

/// 투자 거장 정보 모델
class InvestmentMaster {
  final int masterId;
  final String name;
  final String bio;
  final String portfolioSummary;
  final String imageUrl;
  final String style;
  final String typeCode;
  final int? score;
  final Map<String, double> portfolio; // 포트폴리오 비중 (예: {"주식": 80, "현금": 20})

  InvestmentMaster({
    required this.masterId,
    required this.name,
    required this.bio,
    required this.portfolioSummary,
    required this.imageUrl,
    required this.style,
    required this.typeCode,
    this.score,
    required this.portfolio,
  });

  factory InvestmentMaster.fromJson(Map<String, dynamic> json) {
    // 포트폴리오 맵 변환: API 응답의 int/double을 double로 통일
    final Map<String, dynamic> portfolioJson =
        json['portfolio'] as Map<String, dynamic>? ?? {};
    final Map<String, double> portfolio = portfolioJson.map((key, value) {
      return MapEntry(key, (value as num).toDouble());
    });

    return InvestmentMaster(
      masterId: json['master_id'] ?? 0,
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      portfolioSummary: json['portfolio_summary'] ?? '',
      imageUrl: json['image_url'] ?? '',
      style: json['style'] ?? '',
      typeCode: json['type_code'] ?? '',
      score: json['score'],
      portfolio: portfolio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'master_id': masterId,
      'name': name,
      'bio': bio,
      'portfolio_summary': portfolioSummary,
      'image_url': imageUrl,
      'style': style,
      'type_code': typeCode,
      if (score != null) 'score': score,
      'portfolio': portfolio,
    };
  }

  @override
  String toString() {
    return 'InvestmentMaster(masterId: $masterId, name: $name, style: $style, portfolio: $portfolio)';
  }
}

/// 투자성향 계산 결과 모델
class InvestmentComputed {
  final String version;
  final String typeCode;
  final Map<String, InvestmentDimension> dimensions;

  InvestmentComputed({
    required this.version,
    required this.typeCode,
    required this.dimensions,
  });

  factory InvestmentComputed.fromJson(Map<String, dynamic> json) {
    final dimensionsData = json['dimensions'] as Map<String, dynamic>? ?? {};

    return InvestmentComputed(
      version: json['version'] ?? 'v1.1',
      typeCode: json['type_code'] ?? '',
      dimensions: dimensionsData.map(
        (key, value) => MapEntry(
          key,
          InvestmentDimension.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'type_code': typeCode,
      'dimensions': dimensions.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

/// 투자성향 차원 정보 모델
class InvestmentDimension {
  final double avg;
  final String label;
  final double confidence;
  final String left;
  final String right;

  InvestmentDimension({
    required this.avg,
    required this.label,
    required this.confidence,
    required this.left,
    required this.right,
  });

  factory InvestmentDimension.fromJson(Map<String, dynamic> json) {
    return InvestmentDimension(
      avg: (json['avg'] as num?)?.toDouble() ?? 0.0,
      label: json['label'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      left: json['left'] ?? '',
      right: json['right'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avg': avg,
      'label': label,
      'confidence': confidence,
      'left': left,
      'right': right,
    };
  }

  @override
  String toString() {
    return 'InvestmentDimension(avg: $avg, label: $label, confidence: $confidence)';
  }
}
