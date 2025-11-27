import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/model/aptitude_result.dart';
import '../../domain/repository/aptitude_repository.dart';
import '../../data/dto/aptitude_answer_request.dart';
import '../../data/repository/aptitude_mock_repository.dart';
import '../../../../app/core/providers/riverpod/repository_providers.dart';
import 'aptitude_state.dart';

part 'aptitude_notifier.g.dart';

@riverpod
class AptitudeNotifier extends _$AptitudeNotifier {
  @override
  AptitudeState build() {
    _logRepositoryType();
    return const AptitudeState();
  }

  /// AptitudeRepository 접근
  AptitudeRepository get _repository => ref.read(aptitudeRepositoryProvider);

  /// 현재 사용 중인 Repository 타입 로깅
  void _logRepositoryType() {
    final repo = ref.read(aptitudeRepositoryProvider);
    final isMock = repo is AptitudeMockRepository;
    debugPrint('');
    debugPrint('╔════════════════════════════════════════════════════════════╗');
    debugPrint('║  🏦 APTITUDE REPOSITORY INFO                               ║');
    debugPrint('╠════════════════════════════════════════════════════════════╣');
    debugPrint('║  📡 Mode: ${isMock ? "🎭 MOCK (더미 데이터)" : "🌐 REAL API (백엔드 연동)"}');
    debugPrint('║  📦 Type: ${repo.runtimeType}');
    debugPrint('╚════════════════════════════════════════════════════════════╝');
    debugPrint('');
  }

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
    final isMock = _repository is AptitudeMockRepository;
    debugPrint('');
    debugPrint('┌─────────────────────────────────────────────────────────────┐');
    debugPrint('│ 📋 fetchAllTypes() - 모든 성향 목록 가져오기                 │');
    debugPrint('├─────────────────────────────────────────────────────────────┤');
    debugPrint('│ 🔗 API: GET /api/investment_profile/masters');
    debugPrint('│ 📡 Mode: ${isMock ? "🎭 MOCK" : "🌐 REAL API"}');
    debugPrint('└─────────────────────────────────────────────────────────────┘');

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final allTypes = await _repository.getAllTypes();
      state = state.copyWith(
        allTypes: allTypes,
        isLoading: false,
      );

      debugPrint('');
      debugPrint('✅ [fetchAllTypes] 성공! ${allTypes.length}개 거장 로드');
      debugPrint('┌─────────────────────────────────────────────────────────────┐');
      for (final type in allTypes) {
        debugPrint('│ 📌 ${type.typeCode.padRight(6)} │ ${type.typeName.padRight(12)} │ 거장: ${type.masterName}');
        if (type.portfolio.isNotEmpty) {
          debugPrint('│    └─ 포트폴리오: ${type.portfolio}');
        }
      }
      debugPrint('└─────────────────────────────────────────────────────────────┘');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ [fetchAllTypes] 실패: $e');
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
  /// 🔧 수정: 하드코딩 데이터가 아닌 백엔드에서 받은 실제 거장 데이터 사용!
  Future<bool> fetchResultByType(String typeCode) async {
    final isMock = _repository is AptitudeMockRepository;

    debugPrint('');
    debugPrint('┌─────────────────────────────────────────────────────────────┐');
    debugPrint('│ 🔎 fetchResultByType() - 특정 타입 결과 가져오기             │');
    debugPrint('├─────────────────────────────────────────────────────────────┤');
    debugPrint('│ 🏷️  TypeCode: $typeCode');
    debugPrint('│ 📡 Mode: ${isMock ? "🎭 MOCK" : "🌐 REAL API"}');
    debugPrint('│ 💾 Cache: ${state.allTypes.isNotEmpty ? "있음 (${state.allTypes.length}개)" : "없음"}');
    debugPrint('└─────────────────────────────────────────────────────────────┘');

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // ✅ [최적화] 이미 로드된 allTypes 데이터가 있으면 그걸 사용!
      if (state.allTypes.isNotEmpty) {
        debugPrint('');
        debugPrint('💾 [fetchResultByType] 캐시 사용 (API 호출 스킵!)');

        final matchedType = state.findTypeByCode(typeCode);
        if (matchedType != null) {
          debugPrint('┌─────────────────────────────────────────────────────────────┐');
          debugPrint('│ ✅ 캐시에서 발견!                                            │');
          debugPrint('├─────────────────────────────────────────────────────────────┤');
          debugPrint('│ 📌 TypeCode: ${matchedType.typeCode}');
          debugPrint('│ 📝 TypeName: ${matchedType.typeName}');
          debugPrint('│ 👤 거장 이름: ${matchedType.masterName}');
          debugPrint('│ 🖼️  이미지 URL: ${matchedType.imageUrl.isNotEmpty ? "${matchedType.imageUrl.substring(0, matchedType.imageUrl.length.clamp(0, 50))}..." : "(없음)"}');
          debugPrint('│ 📊 포트폴리오: ${matchedType.portfolio}');
          debugPrint('│ 💬 스타일: ${matchedType.style}');
          debugPrint('│ 📄 설명: ${matchedType.description.length > 30 ? "${matchedType.description.substring(0, 30)}..." : matchedType.description}');
          debugPrint('└─────────────────────────────────────────────────────────────┘');

          // 🔧 수정: 백엔드 데이터로 거장 정보 생성 (하드코딩 X!)
          final master = matchedType.toInvestmentMaster();
          final cachedResult = AptitudeResult(
            typeName: matchedType.typeName,
            typeDescription: matchedType.description,
            master: master,
          );

          state = state.copyWith(
            currentResult: cachedResult,
            isLoading: false,
          );

          debugPrint('');
          debugPrint('🎉 [fetchResultByType] 백엔드 데이터로 결과 생성 완료!');
          debugPrint('   → InvestmentMaster.name: ${master.name}');
          debugPrint('   → InvestmentMaster.portfolio: ${master.portfolio}');
          debugPrint('');
          return true;
        } else {
          debugPrint('⚠️ [fetchResultByType] 캐시에서 typeCode="$typeCode" 찾기 실패');
        }
      }

      // 캐시가 없거나 찾기 실패하면 API 호출 (기존 로직)
      debugPrint('');
      debugPrint('📡 [fetchResultByType] 캐시 없음 - API 직접 호출');
      debugPrint('   🔗 API: GET /api/aptitude-test/results/details/$typeCode');

      final result = await _repository.getResultByType(typeCode).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏰ [fetchResultByType] 타임아웃 발생 (30초 초과)');
          throw Exception('요청 시간이 초과되었습니다');
        },
      );

      state = state.copyWith(currentResult: result, isLoading: false);
      debugPrint('✅ [fetchResultByType] API 응답 성공!');
      debugPrint('   → typeName: ${result.typeName}');
      debugPrint('   → 거장: ${result.master.name}');
      debugPrint('   → 포트폴리오: ${result.master.portfolio}');
      debugPrint('');
      return true;
    } catch (e) {
      debugPrint('');
      debugPrint('💥 [fetchResultByType] 예외 발생!');
      debugPrint('   Error: $e');
      debugPrint('');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '상세 결과를 불러오는 데 실패했습니다: ${e.toString()}',
        currentResult: null,
      );
      return false;
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
