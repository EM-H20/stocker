// features/aptitude/data/repository/aptitude_mock_repository.dart
import '../../domain/model/aptitude_question.dart';
import '../../domain/model/aptitude_result.dart';
import '../../domain/repository/aptitude_repository.dart';
import '../dto/aptitude_answer_request.dart';
import '../../domain/model/aptitude_type_summary.dart'; // ✅ [추가]

/// 테스트용 더미 데이터를 반환하는 Repository 구현체
class AptitudeMockRepository implements AptitudeRepository {
  @override
  Future<List<AptitudeQuestion>> getQuestions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // 24개의 더미 질문 생성 (실제로는 더 많아야 함)
    return List.generate(
        24,
        (index) => AptitudeQuestion(
              id: index + 1,
              text: '질문 ${index + 1}: 이 질문은 테스트용입니다. 당신의 생각은?',
              choices: [
                AptitudeChoice(text: '매우 그렇다', value: 5),
                AptitudeChoice(text: '그렇다', value: 4),
                AptitudeChoice(text: '보통이다', value: 3),
                AptitudeChoice(text: '아니다', value: 2),
                AptitudeChoice(text: '매우 아니다', value: 1),
              ],
            ));
  }

  @override
  Future<AptitudeResult> submitResult(AptitudeAnswerRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // 제출 후 '단기 집중 투자자' 결과를 받았다고 가정
    return _getDummyResult();
  }

  @override
  Future<AptitudeResult> getMyResult() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // '내 결과 보기' 시 '단기 집중 투자자' 결과를 받았다고 가정
    return _getDummyResult();
  }

  @override
  Future<AptitudeResult> retest(AptitudeAnswerRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // 재검사 후에도 같은 결과를 받았다고 가정
    return _getDummyResult();
  }

  @override
  Future<List<AptitudeTypeSummary>> getAllTypes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      AptitudeTypeSummary(
          typeCode: 'STABLE',
          typeName: '안정 추구형',
          description: '원금 손실을 최소화하는 보수적 투자자'),
      AptitudeTypeSummary(
          typeCode: 'AGGRESSIVE',
          typeName: '단기 집중형',
          description: '단기간에 높은 수익을 추구하는 공격적 투자자'),
      AptitudeTypeSummary(
          typeCode: 'NEUTRAL',
          typeName: '위험 중립형',
          description: '안정성과 수익성의 균형을 맞추는 투자자'),
      AptitudeTypeSummary(
          typeCode: 'LONG_TERM',
          typeName: '장기 성장형',
          description: '장기적인 관점에서 꾸준한 성장을 추구하는 투자자'),
    ];
  }

  @override
  Future<AptitudeResult> getResultByType(String typeCode) async {
    // 어떤 타입을 요청하든, 항상 동일한 더미 결과를 반환
    return _getDummyResult();
  }

  // 공통으로 사용할 더미 결과 데이터
  AptitudeResult _getDummyResult() {
    return AptitudeResult(
      typeName: '단기 집중 투자자',
      typeDescription:
          '단기 집중 투자자는 시장의 흐름을 빠르게 파악하고, 단기간에 높은 수익을 목표로 하는 적극적인 투자 성향을 가집니다. 변동성이 큰 자산에 대한 이해도가 높으며, 빠른 의사결정을 통해 기회를 포착하는 데 능숙합니다.',
      master: InvestmentMaster(
        name: '워렌 버핏',
        imageUrl:
            'https://placehold.co/100x100/EFEFEF/AAAAAA&text=Master', // Placeholder image
        description:
            '오마하의 현인이라 불리는 워렌 버핏은 가치 투자의 대가입니다. 그는 기업의 내재 가치를 분석하여 저평가된 주식을 장기간 보유하는 전략으로 유명합니다.',
        portfolio: {
          'Apple (AAPL)': 45.0,
          'Bank of America (BAC)': 10.1,
          'Coca-Cola (KO)': 7.2,
          'Chevron (CVX)': 6.5,
          '기타': 31.2,
        },
      ),
    );
  }
}
