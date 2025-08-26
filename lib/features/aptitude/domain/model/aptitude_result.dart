// features/aptitude/domain/model/aptitude_result.dart

/// 투자 거장 정보를 나타내는 모델
class InvestmentMaster {
  final String name;
  final String imageUrl;
  final String description;
  final Map<String, double> portfolio; // 예: {"주식": 70.0, "채권": 30.0}

  InvestmentMaster({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.portfolio,
  });
}

/// 성향 분석 최종 결과를 나타내는 모델
class AptitudeResult {
  final String typeName; // 예: "단기 집중 투자자"
  final String typeDescription; // 성향에 대한 설명
  final InvestmentMaster master; // 추천 거장 정보
  // TODO: 추천 교육 과정 모델 추가 필요
  // final List<RecommendedCourse> courses;

  AptitudeResult({
    required this.typeName,
    required this.typeDescription,
    required this.master,
    // required this.courses,
  });
}
