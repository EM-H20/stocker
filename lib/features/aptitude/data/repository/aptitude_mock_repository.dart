// features/aptitude/data/repository/aptitude_mock_repository.dart
import 'package:flutter/foundation.dart';
import '../../domain/model/aptitude_question.dart';
import '../../domain/model/aptitude_result.dart';
import '../../domain/repository/aptitude_repository.dart';
import '../dto/aptitude_answer_request.dart';
import '../../domain/model/aptitude_type_summary.dart';

/// 테스트용 더미 데이터를 반환하는 Repository 구현체
class AptitudeMockRepository implements AptitudeRepository {
  @override
  Future<List<AptitudeQuestion>> getQuestions() async {
    debugPrint('🎭 [MOCK_REPO] 질문 목록 요청');
    await Future.delayed(const Duration(milliseconds: 300));

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
    debugPrint('🎭 [MOCK_REPO] 결과 제출 요청');
    await Future.delayed(const Duration(milliseconds: 500));
    return _getResultByTypeCode('AGGRESSIVE');
  }

  @override
  Future<AptitudeResult> getMyResult() async {
    debugPrint('🎭 [MOCK_REPO] 내 결과 조회 요청');
    await Future.delayed(const Duration(milliseconds: 300));
    return _getResultByTypeCode('AGGRESSIVE');
  }

  @override
  Future<AptitudeResult> retest(AptitudeAnswerRequest request) async {
    debugPrint('🎭 [MOCK_REPO] 재검사 요청');
    await Future.delayed(const Duration(milliseconds: 500));
    return _getResultByTypeCode('AGGRESSIVE');
  }

  @override
  Future<List<AptitudeTypeSummary>> getAllTypes() async {
    debugPrint('🎭 [MOCK_REPO] 모든 성향 목록 요청');
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      AptitudeTypeSummary(
        typeCode: 'STABLE',
        typeName: '보수적 장기형',
        description: '위험을 회피하며 안정적인 수익을 추구하는 투자자',
      ),
      AptitudeTypeSummary(
        typeCode: 'AGGRESSIVE',
        typeName: '공격적 단기형',
        description: '높은 위험을 감수하며 단기 고수익을 추구하는 투자자',
      ),
      AptitudeTypeSummary(
        typeCode: 'NEUTRAL',
        typeName: '균형적 성장형',
        description: '위험과 수익의 균형을 맞추며 꾸준한 성장을 추구하는 투자자',
      ),
      AptitudeTypeSummary(
        typeCode: 'CONSERVATIVE',
        typeName: '신중한 장기형',
        description: '리스크를 최소화하며 장기적 관점에서 투자하는 투자자',
      ),
      AptitudeTypeSummary(
        typeCode: 'GROWTH',
        typeName: '적극적 탐색형',
        description: '새로운 기회를 적극 탐색하며 성장 가능성이 높은 자산에 투자하는 투자자',
      ),
      AptitudeTypeSummary(
        typeCode: 'DIVIDEND',
        typeName: '배당 중심형',
        description: '안정적인 배당 수익을 중시하며 현금흐름에 집중하는 투자자',
      ),
    ];
  }

  @override
  Future<AptitudeResult> getResultByType(String typeCode) async {
    debugPrint('🎭 [MOCK_REPO] 타입별 결과 요청: $typeCode');

    // 빠른 응답을 위해 지연시간 최소화
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final result = _getResultByTypeCode(typeCode);
      debugPrint('✅ [MOCK_REPO] 타입별 결과 반환: ${result.typeName}');
      return result;
    } catch (e) {
      debugPrint('❌ [MOCK_REPO] 타입별 결과 생성 실패: $e');
      rethrow;
    }
  }

  /// 타입 코드에 따른 상세 결과 반환 (간소화된 버전)
  AptitudeResult _getResultByTypeCode(String typeCode) {
    debugPrint('🏭 [MOCK_REPO] 결과 생성 중: $typeCode');

    // 기본 포트폴리오 맵
    Map<String, double> createPortfolio(List<MapEntry<String, double>> items) {
      return Map.fromEntries(items);
    }

    switch (typeCode.toUpperCase()) {
      case 'STABLE':
        return AptitudeResult(
          typeName: '보수적 장기형',
          typeDescription: '안정성을 최우선으로 생각하며, 원금 손실 위험을 최소화하는 것을 중요하게 여깁니다.',
          master: InvestmentMaster(
            name: '워렌 버핏',
            imageUrl: 'https://placehold.co/100x100/4285F4/FFFFFF?text=WB',
            description: '오마하의 현인으로 불리는 워렌 버핏은 가치 투자의 대가입니다.',
            portfolio: createPortfolio([
              const MapEntry('Apple', 45.6),
              const MapEntry('은행주', 25.0),
              const MapEntry('기타', 29.4),
            ]),
          ),
        );

      case 'AGGRESSIVE':
        return AptitudeResult(
          typeName: '공격적 단기형',
          typeDescription: '높은 위험을 감수하더라도 단기간에 큰 수익을 얻고자 하는 적극적인 투자 성향입니다.',
          master: InvestmentMaster(
            name: '조지 소로스',
            imageUrl: 'https://placehold.co/100x100/EA4335/FFFFFF?text=GS',
            description: '퀀텀 펀드의 창립자로 알려진 조지 소로스는 거시경제 분석을 통한 투기적 투자로 유명합니다.',
            portfolio: createPortfolio([
              const MapEntry('선물', 35.0),
              const MapEntry('주식', 25.0),
              const MapEntry('원자재', 20.0),
              const MapEntry('현금', 20.0),
            ]),
          ),
        );

      case 'NEUTRAL':
        return AptitudeResult(
          typeName: '균형적 성장형',
          typeDescription:
              '위험과 수익의 적절한 균형을 추구하며, 다양한 자산에 분산 투자를 통해 안정적인 성장을 도모합니다.',
          master: InvestmentMaster(
            name: '레이 달리오',
            imageUrl: 'https://placehold.co/100x100/34A853/FFFFFF?text=RD',
            description: '브리지워터 어소시에이츠의 창립자인 레이 달리오는 올웨더 포트폴리오로 유명합니다.',
            portfolio: createPortfolio([
              const MapEntry('주식', 30.0),
              const MapEntry('채권', 40.0),
              const MapEntry('원자재', 15.0),
              const MapEntry('기타', 15.0),
            ]),
          ),
        );

      case 'CONSERVATIVE':
        return AptitudeResult(
          typeName: '신중한 장기형',
          typeDescription: '리스크를 철저히 관리하면서 장기적인 관점에서 꾸준한 성장을 추구합니다.',
          master: InvestmentMaster(
            name: '벤저민 그레이엄',
            imageUrl: 'https://placehold.co/100x100/9C27B0/FFFFFF?text=BG',
            description: '가치 투자의 아버지로 불리는 벤저민 그레이엄입니다.',
            portfolio: createPortfolio([
              const MapEntry('가치주', 50.0),
              const MapEntry('채권', 30.0),
              const MapEntry('배당주', 15.0),
              const MapEntry('현금', 5.0),
            ]),
          ),
        );

      case 'GROWTH':
        return AptitudeResult(
          typeName: '적극적 탐색형',
          typeDescription: '새로운 기회와 성장 가능성이 높은 자산을 적극적으로 탐색합니다.',
          master: InvestmentMaster(
            name: '캐시 우드',
            imageUrl: 'https://placehold.co/100x100/FF9800/FFFFFF?text=CW',
            description: 'ARK 인베스트의 CEO인 캐시 우드는 파괴적 혁신 기업에 투자하는 것으로 유명합니다.',
            portfolio: createPortfolio([
              const MapEntry('Tesla', 15.0),
              const MapEntry('Nvidia', 12.0),
              const MapEntry('혁신기업', 60.0),
              const MapEntry('기타', 13.0),
            ]),
          ),
        );

      case 'DIVIDEND':
        return AptitudeResult(
          typeName: '배당 중심형',
          typeDescription: '안정적이고 지속적인 배당 수익을 중시하며, 현금흐름 창출에 집중합니다.',
          master: InvestmentMaster(
            name: '존 보글',
            imageUrl: 'https://placehold.co/100x100/607D8B/FFFFFF?text=JB',
            description: '뱅가드 그룹의 창립자인 존 보글은 인덱스 펀드의 아버지로 불립니다.',
            portfolio: createPortfolio([
              const MapEntry('배당주', 40.0),
              const MapEntry('REIT', 25.0),
              const MapEntry('유틸리티', 20.0),
              const MapEntry('채권', 15.0),
            ]),
          ),
        );

      default:
        debugPrint('⚠️ [MOCK_REPO] 알 수 없는 타입, 기본값 반환: $typeCode');
        return _getResultByTypeCode('AGGRESSIVE');
    }
  }
}
