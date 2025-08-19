import'../../../../features/aptitude/domain/model/aptitude_result.dart';

// features/aptitude/data/dto/aptitude_result_dto.dart
/// 서버로부터 성향 분석 결과를 수신하는 DTO
class AptitudeResultDto {
  final String typeName;
  final String typeDescription;
  final InvestmentMasterDto master;

  AptitudeResultDto({
    required this.typeName,
    required this.typeDescription,
    required this.master,
  });

  factory AptitudeResultDto.fromJson(Map<String, dynamic> json) {
    return AptitudeResultDto(
      typeName: json['typeName'] as String? ?? '분석 결과 없음',
      typeDescription: json['typeDescription'] as String? ?? '',
      master: InvestmentMasterDto.fromJson(json['master'] ?? {}),
    );
  }

  // DTO를 도메인 모델로 변환
  AptitudeResult toModel() {
    return AptitudeResult(
      typeName: typeName,
      typeDescription: typeDescription,
      master: master.toModel(),
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

    return InvestmentMasterDto(
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      portfolio: portfolio,
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