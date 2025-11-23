import '../../../../features/aptitude/domain/model/aptitude_result.dart';

// features/aptitude/data/dto/aptitude_result_dto.dart
/// 서버로부터 성향 분석 결과를 수신하는 DTO (백엔드 실제 응답 구조에 맞춤)
class AptitudeResultDto {
  final int? profileId;
  final int? userId;
  final String typeCode;
  final List<InvestmentMasterDto> matchedMaster;

  AptitudeResultDto({
    this.profileId,
    this.userId,
    required this.typeCode,
    required this.matchedMaster,
  });

  factory AptitudeResultDto.fromJson(Map<String, dynamic> json) {
    // 백엔드 실제 응답: { profile_id, user_id, type_code, matched_master }
    // saveResult API의 경우 추가로 created, computed 필드도 포함
    final matchedMasterList = json['matched_master'] as List<dynamic>? ?? [];

    return AptitudeResultDto(
      profileId: json['profile_id'] as int?,
      userId: json['user_id'] as int?,
      typeCode: json['type_code'] as String? ?? 'UNKNOWN',
      matchedMaster: matchedMasterList
          .map((item) =>
              InvestmentMasterDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // DTO를 도메인 모델로 변환
  AptitudeResult toModel() {
    return AptitudeResult(
      typeName: _getTypeNameFromCode(typeCode),
      typeDescription: _getTypeDescriptionFromCode(typeCode),
      master: matchedMaster.isNotEmpty
          ? matchedMaster.first.toModel()
          : _getDefaultMaster(),
    );
  }

  // 타입 코드에서 타입 이름 추출
  String _getTypeNameFromCode(String code) {
    const typeNameMap = {
      'CONSERVATIVE': '보수형 투자자',
      'MODERATE': '중립형 투자자',
      'AGGRESSIVE': '공격형 투자자',
      'GROWTH': '성장형 투자자',
      'VALUE': '가치형 투자자',
    };
    return typeNameMap[code] ?? '분석 결과 ($code)';
  }

  // 타입 코드에서 설명 추출
  String _getTypeDescriptionFromCode(String code) {
    const typeDescriptionMap = {
      'CONSERVATIVE': '안정적인 수익을 추구하는 투자 성향',
      'MODERATE': '균형잡힌 투자를 선호하는 성향',
      'AGGRESSIVE': '높은 수익을 위해 위험을 감수하는 성향',
      'GROWTH': '기업의 성장 가능성에 주목하는 성향',
      'VALUE': '저평가된 기업을 찾는 성향',
    };
    return typeDescriptionMap[code] ?? '투자 성향 분석 결과';
  }

  // 기본 마스터 정보 (matched_master가 비어있을 때)
  InvestmentMaster _getDefaultMaster() {
    return InvestmentMaster(
      name: '투자 전문가',
      imageUrl: '',
      description: '당신의 투자 성향에 맞는 전문가',
      portfolio: {'주식': 50.0, '채권': 30.0, '현금': 20.0},
    );
  }
}

class InvestmentMasterDto {
  final String name;
  final String imageUrl;
  final String description;
  final Map<String, double> portfolio;

  InvestmentMasterDto({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.portfolio,
  });

  factory InvestmentMasterDto.fromJson(Map<String, dynamic> json) {
    // 포트폴리오 맵 변환
    final Map<String, dynamic> portfolioJson = json['portfolio'] ?? {};
    final Map<String, double> portfolio = portfolioJson.map((key, value) {
      return MapEntry(key, (value as num).toDouble());
    });

    // 디버깅: 포트폴리오가 비어있으면 로그 출력
    if (portfolio.isEmpty) {
      print('⚠️ [DTO] ${json['name']} 포트폴리오가 비어있습니다! JSON: ${json['portfolio']}');
    }

    return InvestmentMasterDto(
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      portfolio: portfolio.isNotEmpty
          ? portfolio
          : {'주식': 40.0, '채권': 30.0, '현금': 20.0, '기타': 10.0}, // 기본 포트폴리오
    );
  }

  InvestmentMaster toModel() {
    return InvestmentMaster(
      name: name,
      imageUrl: imageUrl,
      description: description,
      portfolio: portfolio,
    );
  }
}
