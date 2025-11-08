import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/model/aptitude_result.dart';
import '../../domain/repository/aptitude_repository.dart';
import '../../data/dto/aptitude_answer_request.dart';
import '../../../../app/core/providers/riverpod/repository_providers.dart';
import 'aptitude_state.dart';

part 'aptitude_notifier.g.dart';
@riverpod
class AptitudeNotifier extends _$AptitudeNotifier {
  @override
  AptitudeState build() {
    return const AptitudeState();
  }

  /// AptitudeRepository 접근
  AptitudeRepository get _repository => ref.read(aptitudeRepositoryProvider);

  // === 검사 결과 확인 ===

  /// 초기 화면 진입 시, 이전 검사 결과 유무를 확인
  Future<void> checkPreviousResult() async {
    debugPrint('🔍 [APTITUDE_NOTIFIER] 이전 검사 결과 확인 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _repository.getMyResult();
      state = state.copyWith(
        myResult: result,
        hasPreviousResult: true,
        isLoading: false,
      );
      debugPrint('✅ [APTITUDE_NOTIFIER] 이전 검사 결과 있음: ${result.typeName}');
    } catch (e) {
      state = state.copyWith(
        myResult: null,
        hasPreviousResult: false,
        isLoading: false,
      );
      debugPrint('ℹ️ [APTITUDE_NOTIFIER] 이전 검사 결과 없음: $e');
    }
  }

  // === 검사 시작 ===

  /// 검사 시작 시, 질문 목록을 가져옴
  Future<bool> startTest() async {
    debugPrint('🎯 [APTITUDE_NOTIFIER] 검사 시작');
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      answers: {}, // 답변 초기화
    );

    try {
      final questions = await _repository.getQuestions();
      state = state.copyWith(
        questions: questions,
        isLoading: false,
      );
      debugPrint('✅ [APTITUDE_NOTIFIER] 질문 ${questions.length}개 로드');
      return questions.isNotEmpty;
    } catch (e) {
      debugPrint('❌ [APTITUDE_NOTIFIER] 질문 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '검사지를 불러오는 데 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  // === 모든 성향 타입 목록 ===

  /// 모든 성향 타입 목록을 가져옴
  Future<void> fetchAllTypes() async {
    debugPrint('📋 [APTITUDE_NOTIFIER] 모든 성향 목록 가져오기 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final allTypes = await _repository.getAllTypes();
      state = state.copyWith(
        allTypes: allTypes,
        isLoading: false,
      );
      debugPrint('✅ [APTITUDE_NOTIFIER] 성향 ${allTypes.length}개 로드');

      // 로드된 성향들 로그 출력
      for (final type in allTypes) {
        debugPrint('   - ${type.typeCode}: ${type.typeName}');
      }
    } catch (e) {
      debugPrint('❌ [APTITUDE_NOTIFIER] 성향 목록 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '성향 목록을 불러오는 데 실패했습니다: ${e.toString()}',
        allTypes: [],
      );
    }
  }

  // === 특정 타입 결과 가져오기 ===

  /// ✅ [최적화] 특정 타입의 상세 결과를 가져와 currentResult에 저장
  /// 이미 로드된 allTypes 데이터를 재사용하여 불필요한 API 호출 방지!
  Future<bool> fetchResultByType(String typeCode) async {
    debugPrint('🔎 [APTITUDE_NOTIFIER] fetchResultByType 시작: $typeCode');

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // ✅ [최적화] 이미 로드된 allTypes 데이터가 있으면 그걸 사용!
      if (state.allTypes.isNotEmpty) {
        debugPrint('💾 [APTITUDE_NOTIFIER] 캐시된 데이터에서 검색 중...');

        final matchedType = state.findTypeByCode(typeCode);
        if (matchedType != null) {
          debugPrint('✅ [APTITUDE_NOTIFIER] 캐시에서 발견: ${matchedType.typeName}');

          // 캐시된 데이터로 즉시 결과 생성 (API 호출 없음!)
          final cachedResult = AptitudeResult(
            typeName: matchedType.typeName,
            typeDescription: matchedType.description,
            master: _getDefaultMasterForType(typeCode), // 기본 거장 정보
          );

          state = state.copyWith(
            currentResult: cachedResult,
            isLoading: false,
          );

          debugPrint(
              '✅ [APTITUDE_NOTIFIER] 캐시 데이터로 결과 생성 완료 - API 호출 없음!');
          return true;
        } else {
          debugPrint('⚠️ [APTITUDE_NOTIFIER] 캐시에서 찾기 실패');
        }
      }

      // 캐시가 없거나 찾기 실패하면 API 호출 (기존 로직)
      debugPrint('📡 [APTITUDE_NOTIFIER] 캐시 없음 - Repository 호출 중...');

      final result = await _repository.getResultByType(typeCode).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('⏰ [APTITUDE_NOTIFIER] 타임아웃 발생');
              throw Exception('요청 시간이 초과되었습니다');
            },
          );

      if (result != null) {
        state = state.copyWith(currentResult: result, isLoading: false);
        debugPrint(
            '✅ [APTITUDE_NOTIFIER] API로 결과 로드 성공: ${result.typeName}');
        debugPrint('   거장: ${result.master.name}');
        return true;
      } else {
        debugPrint('⚠️ [APTITUDE_NOTIFIER] 결과가 null');
        state = state.copyWith(
          isLoading: false,
          errorMessage: '결과를 불러올 수 없습니다',
        );
        return false;
      }
    } catch (e) {
      debugPrint('💥 [APTITUDE_NOTIFIER] fetchResultByType 예외: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '상세 결과를 불러오는 데 실패했습니다: ${e.toString()}',
        currentResult: null,
      );
      return false;
    } finally {
      debugPrint('🏁 [APTITUDE_NOTIFIER] fetchResultByType 완료');
    }
  }

  /// ✅ [추가] 타입 코드에 맞는 기본 거장 정보 반환
  /// Mock Repository의 로직을 재사용하여 일관성 유지
  InvestmentMaster _getDefaultMasterForType(String typeCode) {
    switch (typeCode.toUpperCase()) {
      case 'STABLE':
        return InvestmentMaster(
          name: '워렌 버핏',
          imageUrl: 'https://placehold.co/100x100/4285F4/FFFFFF?text=WB',
          description: '오마하의 현인으로 불리는 워렌 버핏은 가치 투자의 대가입니다.',
          portfolio: {'Apple': 45.6, '은행주': 25.0, '기타': 29.4},
        );
      case 'AGGRESSIVE':
        return InvestmentMaster(
          name: '조지 소로스',
          imageUrl: 'https://placehold.co/100x100/EA4335/FFFFFF?text=GS',
          description:
              '퀀텀 펀드의 창립자로 알려진 조지 소로스는 거시경제 분석을 통한 투기적 투자로 유명합니다.',
          portfolio: {'선물': 35.0, '주식': 25.0, '원자재': 20.0, '현금': 20.0},
        );
      case 'NEUTRAL':
        return InvestmentMaster(
          name: '레이 달리오',
          imageUrl: 'https://placehold.co/100x100/34A853/FFFFFF?text=RD',
          description:
              '브리지워터 어소시에이츠의 창립자인 레이 달리오는 올웨더 포트폴리오로 유명합니다.',
          portfolio: {'주식': 30.0, '채권': 40.0, '원자재': 15.0, '기타': 15.0},
        );
      case 'CONSERVATIVE':
        return InvestmentMaster(
          name: '벤저민 그레이엄',
          imageUrl: 'https://placehold.co/100x100/9C27B0/FFFFFF?text=BG',
          description: '가치 투자의 아버지로 불리는 벤저민 그레이엄입니다.',
          portfolio: {'가치주': 50.0, '채권': 30.0, '배당주': 15.0, '현금': 5.0},
        );
      case 'GROWTH':
        return InvestmentMaster(
          name: '캐시 우드',
          imageUrl: 'https://placehold.co/100x100/FF9800/FFFFFF?text=CW',
          description:
              'ARK 인베스트의 CEO인 캐시 우드는 파괴적 혁신 기업에 투자하는 것으로 유명합니다.',
          portfolio: {'Tesla': 15.0, 'Nvidia': 12.0, '혁신기업': 60.0, '기타': 13.0},
        );
      case 'DIVIDEND':
        return InvestmentMaster(
          name: '존 보글',
          imageUrl: 'https://placehold.co/100x100/607D8B/FFFFFF?text=JB',
          description: '뱅가드 그룹의 창립자인 존 보글은 인덱스 펀드의 아버지로 불립니다.',
          portfolio: {'배당주': 40.0, 'REIT': 25.0, '유틸리티': 20.0, '채권': 15.0},
        );
      default:
        return InvestmentMaster(
          name: '투자 전문가',
          imageUrl: 'https://placehold.co/100x100/999999/FFFFFF?text=??',
          description: '당신의 투자 성향에 맞는 전문가',
          portfolio: {'주식': 50.0, '채권': 30.0, '현금': 20.0},
        );
    }
  }

  // === 답변 관리 ===

  /// 특정 질문에 대한 답변을 저장
  void answerQuestion(int questionId, int value) {
    final updatedAnswers = Map<int, int>.from(state.answers);
    updatedAnswers[questionId] = value;

    state = state.copyWith(answers: updatedAnswers);
    debugPrint('💭 [APTITUDE_NOTIFIER] 답변 저장: Q$questionId = $value');
  }

  // === 답변 제출 ===

  /// 모든 답변을 서버에 제출
  Future<bool> submitAnswers() async {
    debugPrint('📤 [APTITUDE_NOTIFIER] 답변 제출 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final answerList = state.answers.entries.map((e) {
        return Answer(questionId: e.key, value: e.value);
      }).toList();

      final request = AptitudeAnswerRequest(answers: answerList);
      debugPrint('📤 [APTITUDE_NOTIFIER] ${answerList.length}개 답변 제출');

      final AptitudeResult result;
      if (state.hasPreviousResult) {
        debugPrint('🔄 [APTITUDE_NOTIFIER] 재검사 모드');
        result = await _repository.retest(request);
      } else {
        debugPrint('🆕 [APTITUDE_NOTIFIER] 신규 검사 모드');
        result = await _repository.submitResult(request);
      }

      state = state.copyWith(
        currentResult: result,
        myResult: result,
        hasPreviousResult: true,
        isLoading: false,
      );

      debugPrint('✅ [APTITUDE_NOTIFIER] 답변 제출 성공: ${result.typeName}');
      return true;
    } catch (e) {
      debugPrint('❌ [APTITUDE_NOTIFIER] 답변 제출 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '결과 제출에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  // === currentResult 초기화 ===

  /// currentResult 초기화 (상세 보기 종료 시)
  void clearCurrentResult() {
    debugPrint('🧹 [APTITUDE_NOTIFIER] currentResult 초기화');
    state = state.copyWith(currentResult: null);
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
