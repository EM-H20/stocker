

// features/aptitude/data/repository/aptitude_api_repository.dart
import '../../domain/model/aptitude_question.dart';
import '../../domain/model/aptitude_result.dart';
import '../../domain/repository/aptitude_repository.dart';
import '../dto/aptitude_answer_request.dart';
import '../source/aptitude_api.dart';
import '../../domain/model/aptitude_type_summary.dart'; // ✅ [추가]


/// 실제 API를 호출하는 Repository 구현체
class AptitudeApiRepository implements AptitudeRepository {
  final AptitudeApi _api;
  AptitudeApiRepository(this._api);

  @override
  Future<List<AptitudeQuestion>> getQuestions() async {
    final dtoList = await _api.getQuestionnaire();
    // DTO 리스트를 도메인 모델 리스트로 변환
    return dtoList.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<AptitudeResult> submitResult(AptitudeAnswerRequest request) async {
    final dto = await _api.saveResult(request);
    return dto.toModel();
  }

  @override
  Future<AptitudeResult> getMyResult() async {
    final dto = await _api.getResult();
    return dto.toModel();
  }

  @override
  Future<AptitudeResult> retest(AptitudeAnswerRequest request) async {
    final dto = await _api.retestAndUpdate(request);
    return dto.toModel();
  }

  @override
  Future<List<AptitudeTypeSummary>> getAllTypes() async {
    final dtoList = await _api.listAllMasters();
    return dtoList.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<AptitudeResult> getResultByType(String typeCode) async {
    final dto = await _api.getResultByType(typeCode);
    return dto.toModel();
  }
}
