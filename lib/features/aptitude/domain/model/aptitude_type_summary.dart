// features/aptitude/domain/model/aptitude_type_summary.dart
import 'aptitude_result.dart';

/// 성향 목록의 각 아이템을 나타내는 모델 (투자 거장 정보 포함)
class AptitudeTypeSummary {
  final String typeCode; // 예: "CLPD", "ELAI" 등 API에서 사용하는 고유 코드
  final String typeName; // 예: "보수적 창조형"
  final String description; // 예: "단기간에 높은 수익을 추구하는..."
  final String masterName; // 투자 거장 이름 (예: "워렌 버핏")
  final String imageUrl; // 투자 거장 이미지 URL
  final String portfolioSummary; // 포트폴리오 요약 설명
  final String style; // 투자 스타일 (예: "가치 투자")
  final Map<String, double> portfolio; // 포트폴리오 비중 (예: {"주식": 80, "현금": 20})

  AptitudeTypeSummary({
    required this.typeCode,
    required this.typeName,
    required this.description,
    this.masterName = '',
    this.imageUrl = '',
    this.portfolioSummary = '',
    this.style = '',
    this.portfolio = const {},
  });

  /// 백엔드에서 받은 거장 정보를 InvestmentMaster로 변환
  /// 하드코딩이 아닌 실제 API 데이터를 사용!
  InvestmentMaster toInvestmentMaster() {
    return InvestmentMaster(
      name: masterName,
      imageUrl: imageUrl,
      description: portfolioSummary.isNotEmpty ? portfolioSummary : style,
      portfolio: portfolio.isNotEmpty
          ? portfolio
          : {'주식': 50.0, '채권': 30.0, '현금': 20.0}, // 포트폴리오가 비어있을 때만 기본값
    );
  }
}
