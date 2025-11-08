import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/model/aptitude_question.dart';
import '../../domain/model/aptitude_result.dart';
import '../../domain/model/aptitude_type_summary.dart';

part 'aptitude_state.freezed.dart';

/// 🔥 Riverpod 성향분석 상태 클래스 (Freezed)
@freezed
class AptitudeState with _$AptitudeState {
  const factory AptitudeState({
    /// 로딩 중
    @Default(false) bool isLoading,

    /// 에러 메시지
    String? errorMessage,

    /// 질문 목록
    @Default([]) List<AptitudeQuestion> questions,

    /// 답변 맵 (questionId → value)
    @Default({}) Map<int, int> answers,

    /// 내 검사 결과 (마지막 저장된 결과)
    AptitudeResult? myResult,

    /// 현재 보고 있는 결과 (상세 보기용)
    AptitudeResult? currentResult,

    /// 이전 검사 결과 존재 여부
    @Default(false) bool hasPreviousResult,

    /// 모든 성향 타입 목록
    @Default([]) List<AptitudeTypeSummary> allTypes,
  }) = _AptitudeState;

  const AptitudeState._();

  // === Computed Getters (Helper Methods) ===

  /// 에러 존재 여부
  bool get hasError => errorMessage != null;

  /// 질문 개수
  int get questionCount => questions.length;

  /// 답변 완료된 질문 개수
  int get answeredCount => answers.length;

  /// 모든 질문에 답했는지
  bool get isAllAnswered => answeredCount == questionCount && questionCount > 0;

  /// 진행률 (0.0 ~ 1.0)
  double get progressRatio =>
      questionCount > 0 ? answeredCount / questionCount : 0.0;

  /// 진행률 퍼센트 (0 ~ 100)
  int get progressPercent => (progressRatio * 100).toInt();

  /// 특정 질문에 대한 답변 가져오기
  int? getAnswer(int questionId) => answers[questionId];

  /// 특정 질문에 답했는지 확인
  bool hasAnswered(int questionId) => answers.containsKey(questionId);

  /// 타입 코드로 TypeSummary 찾기
  AptitudeTypeSummary? findTypeByCode(String typeCode) {
    try {
      return allTypes.firstWhere(
        (type) => type.typeCode.toUpperCase() == typeCode.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
