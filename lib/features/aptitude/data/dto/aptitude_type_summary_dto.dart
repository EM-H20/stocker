// features/aptitude/data/dto/aptitude_type_summary_dto.dart
import '../../domain/model/aptitude_type_summary.dart';

/// 서버로부터 투자 거장(InvestmentMaster) 목록을 수신하는 DTO (백엔드 실제 응답 구조에 맞춤)
class AptitudeTypeSummaryDto {
  final int masterId;
  final String name;
  final String bio;
  final String portfolioSummary;
  final String imageUrl;
  final String style;
  final String typeCode;

  AptitudeTypeSummaryDto({
    required this.masterId,
    required this.name,
    required this.bio,
    required this.portfolioSummary,
    required this.imageUrl,
    required this.style,
    required this.typeCode,
  });

  factory AptitudeTypeSummaryDto.fromJson(Map<String, dynamic> json) {
    // 백엔드 실제 응답: InvestmentMaster 테이블 구조
    return AptitudeTypeSummaryDto(
      masterId: json['master_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      portfolioSummary: json['portfolio_summary'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      style: json['style'] as String? ?? '',
      typeCode: json['type_code'] as String? ?? '',
    );
  }

  // DTO를 도메인 모델로 변환
  AptitudeTypeSummary toModel() {
    return AptitudeTypeSummary(
      typeCode: typeCode,
      typeName: _getTypeNameFromCode(typeCode), // 타입 코드를 이름으로 변환
      description: bio.isNotEmpty ? bio : style, // bio가 있으면 bio, 없으면 style 사용
    );
  }

  // 타입 코드에서 타입 이름 추출 (AptitudeResultDto와 동일한 로직)
  String _getTypeNameFromCode(String code) {
    const typeNameMap = {
      'ELAI': '적극적 성장형',
      'ELAD': '신중한 성장형', 
      'ELPI': '균형잡힌 가치형',
      'ELPD': '보수적 가치형',
      'ESAI': '적극적 안정형',
      'ESAD': '신중한 안정형',
      'ESPI': '균형잡힌 안정형',
      'ESPD': '보수적 안정형',
      'CLAI': '적극적 창조형',
      'CLAD': '신중한 창조형',
      'CLPI': '균형잡힌 창조형', 
      'CLPD': '보수적 창조형',
      'CSAI': '적극적 탐색형',
      'CSAD': '신중한 탐색형',
      'CSPI': '균형잡힌 탐색형',
      'CSPD': '보수적 탐색형',
    };
    return typeNameMap[code] ?? '투자 거장 ($code)';
  }
}
