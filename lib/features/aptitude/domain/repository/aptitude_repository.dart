// features/aptitude/domain/repository/aptitude_repository.dart
import '../model/aptitude_question.dart';
import '../model/aptitude_result.dart';
import '../model/aptitude_type_summary.dart'; 
import '../../data/dto/aptitude_answer_request.dart';

/// 성향 분석 관련 데이터 처리를 위한 Repository 추상 클래스 (설계도)
abstract class AptitudeRepository {
  /// 성향 분석 질문지 전체를 가져옵니다.
  Future<List<AptitudeQuestion>> getQuestions();

  /// 사용자의 답변을 제출하고 최종 결과를 받습니다. (최초 검사)
  Future<AptitudeResult> submitResult(AptitudeAnswerRequest request);

  /// 사용자의 이전 검사 결과를 조회합니다.
  Future<AptitudeResult> getMyResult();

  /// 사용자가 재검사를 하고 결과를 갱신합니다.
  Future<AptitudeResult> retest(AptitudeAnswerRequest request);

  /// ✅ [추가] 모든 성향 타입 목록을 조회합니다.
  Future<List<AptitudeTypeSummary>> getAllTypes();

  /// ✅ [추가] 특정 타입 코드로 상세 결과를 조회합니다.
  Future<AptitudeResult> getResultByType(String typeCode);
}