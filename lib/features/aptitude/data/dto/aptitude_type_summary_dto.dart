
// features/aptitude/data/dto/aptitude_type_summary_dto.dart (새 파일)
import '../../domain/model/aptitude_type_summary.dart';

/// 서버로부터 성향 요약 목록을 수신하는 DTO
class AptitudeTypeSummaryDto {
  final String typeCode;
  final String typeName;
  final String description;

  AptitudeTypeSummaryDto({
    required this.typeCode,
    required this.typeName,
    required this.description,
  });

  factory AptitudeTypeSummaryDto.fromJson(Map<String, dynamic> json) {
    return AptitudeTypeSummaryDto(
      typeCode: json['type_code'] as String? ?? '',
      typeName: json['type_name'] as String? ?? '알 수 없는 타입',
      description: json['description'] as String? ?? '',
    );
  }

  // DTO를 도메인 모델로 변환
  AptitudeTypeSummary toModel() {
    return AptitudeTypeSummary(
      typeCode: typeCode,
      typeName: typeName,
      description: description,
    );
  }
}
