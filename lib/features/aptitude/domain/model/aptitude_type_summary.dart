// features/aptitude/domain/model/aptitude_type_summary.dart (새 파일)
/// 성향 목록의 각 아이템을 나타내는 모델
class AptitudeTypeSummary {
  final String typeCode; // 예: "AGGRESSIVE", "STABLE" 등 API에서 사용하는 고유 코드
  final String typeName; // 예: "단기 집중형"
  final String description; // 예: "단기간에 높은 수익을 추구하는..."

  AptitudeTypeSummary({
    required this.typeCode,
    required this.typeName,
    required this.description,
  });
}
