// features/aptitude/presentation/provider/aptitude_provider.dart
import 'package:flutter/material.dart';
import '../../domain/model/aptitude_type_summary.dart'; // ✅ [추가]
import '../../domain/model/aptitude_question.dart';
import '../../domain/model/aptitude_result.dart';
import '../../domain/repository/aptitude_repository.dart';
import '../../data/dto/aptitude_answer_request.dart';

/// 성향 분석 기능의 상태를 관리하는 Provider
class AptitudeProvider with ChangeNotifier {
  final AptitudeRepository _repository;
  AptitudeProvider(this._repository);

  // --- 상태 변수 ---

  /// 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 에러 메시지
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 성향 분석 질문 목록
  List<AptitudeQuestion> _questions = [];
  List<AptitudeQuestion> get questions => _questions;

  /// 사용자의 답변 목록 (questionId: value)
  final Map<int, int> _answers = {};
  Map<int, int> get answers => _answers;

  /// 사용자의 이전 검사 결과
  AptitudeResult? _myResult;
  AptitudeResult? get myResult => _myResult;

  /// 현재 검사 후 나온 결과
  AptitudeResult? _currentResult;
  AptitudeResult? get currentResult => _currentResult;
  
  // ✅ [수정] 'currentResult'의 setter 추가
  set currentResult(AptitudeResult? value) {
    _currentResult = value;
    // notifyListeners(); // 필요에 따라 UI 갱신을 알릴 수 있음
  }

  /// 사용자가 이전에 검사를 했는지 여부
  bool _hasPreviousResult = false;
  bool get hasPreviousResult => _hasPreviousResult;

  /// 모든 성향 타입 요약 목록
  List<AptitudeTypeSummary> _allTypes = [];
  List<AptitudeTypeSummary> get allTypes => _allTypes;


  // --- 로직 메서드 ---

  /// 초기 화면 진입 시, 이전 검사 결과 유무를 확인
  Future<void> checkPreviousResult() async {
    _setLoading(true);
    try {
      // 내 결과 조회 API를 호출해보고, 성공하면 결과가 있는 것
      _myResult = await _repository.getMyResult();
      _hasPreviousResult = true;
    } catch (e) {
      // API 호출 실패 (404 Not Found 등)는 결과가 없는 것으로 간주
      _myResult = null;
      _hasPreviousResult = false;
    } finally {
      _setLoading(false);
    }
  }

  /// 검사 시작 시, 질문 목록을 가져옴
  Future<bool> startTest() async {
    _setLoading(true);
    _answers.clear(); // 새 검사 시작 시 이전 답변 초기화
    try {
      _questions = await _repository.getQuestions();
      return _questions.isNotEmpty;
    } catch (e) {
      _errorMessage = '검사지를 불러오는 데 실패했습니다: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 모든 성향 타입 목록을 가져옴
  Future<void> fetchAllTypes() async {
    _setLoading(true);
    try {
      _allTypes = await _repository.getAllTypes();
    } catch (e) {
      _errorMessage = '성향 목록을 불러오는 데 실패했습니다: ${e.toString()}';
      _allTypes = []; // 실패 시 빈 리스트로 초기화
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 타입의 상세 결과를 가져와 currentResult에 저장
  Future<bool> fetchResultByType(String typeCode) async {
    _setLoading(true);
    try {
      // 상세 결과를 currentResult에 저장
      _currentResult = await _repository.getResultByType(typeCode);
      return true;
    } catch (e) {
      _errorMessage = '상세 결과를 불러오는 데 실패했습니다: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 질문에 대한 답변을 저장
  void answerQuestion(int questionId, int value) {
    _answers[questionId] = value;
    notifyListeners();
  }

  /// 모든 답변을 서버에 제출
  Future<bool> submitAnswers() async {
    _setLoading(true);
    try {
      final answerList = _answers.entries.map((e) {
        return Answer(questionId: e.key, value: e.value);
      }).toList();

      final request = AptitudeAnswerRequest(answers: answerList);

      // 이전에 결과가 있었는지 여부에 따라 다른 API 호출
      if (_hasPreviousResult) {
        _currentResult = await _repository.retest(request);
      } else {
        _currentResult = await _repository.submitResult(request);
      }
      
      // 성공 후 상태 갱신
      _myResult = _currentResult;
      _hasPreviousResult = true;
      return true;

    } catch (e) {
      _errorMessage = '결과 제출에 실패했습니다: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 로딩 상태 변경 및 UI 업데이트 알림
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
