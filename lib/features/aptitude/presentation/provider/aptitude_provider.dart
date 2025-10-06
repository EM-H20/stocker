// features/aptitude/presentation/provider/aptitude_provider.dart

import 'package:flutter/material.dart';
import '../../domain/model/aptitude_type_summary.dart';
import '../../domain/model/aptitude_question.dart';
import '../../domain/model/aptitude_result.dart';
import '../../domain/repository/aptitude_repository.dart';
import '../../data/dto/aptitude_answer_request.dart';

/// 성향 분석 기능의 상태를 관리하는 Provider
class AptitudeProvider with ChangeNotifier {
  final AptitudeRepository _repository;
  AptitudeProvider(this._repository);

  // --- 상태 변수 ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AptitudeQuestion> _questions = [];
  List<AptitudeQuestion> get questions => _questions;

  final Map<int, int> _answers = {};
  Map<int, int> get answers => _answers;

  AptitudeResult? _myResult;
  AptitudeResult? get myResult => _myResult;

  AptitudeResult? _currentResult;
  AptitudeResult? get currentResult => _currentResult;

  void clearCurrentResult() {
    debugPrint('🧹 [APTITUDE_PROVIDER] currentResult 초기화');
    _currentResult = null;
    notifyListeners();
  }

  bool _hasPreviousResult = false;
  bool get hasPreviousResult => _hasPreviousResult;

  List<AptitudeTypeSummary> _allTypes = [];
  List<AptitudeTypeSummary> get allTypes => _allTypes;

  // --- 로직 메서드 ---

  /// 초기 화면 진입 시, 이전 검사 결과 유무를 확인
  Future<void> checkPreviousResult() async {
    debugPrint('🔍 [APTITUDE_PROVIDER] 이전 검사 결과 확인 시작');
    _setLoading(true);
    try {
      _myResult = await _repository.getMyResult();
      _hasPreviousResult = true;
      debugPrint('✅ [APTITUDE_PROVIDER] 이전 검사 결과 있음: ${_myResult?.typeName}');
    } catch (e) {
      _myResult = null;
      _hasPreviousResult = false;
      debugPrint('ℹ️ [APTITUDE_PROVIDER] 이전 검사 결과 없음: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 검사 시작 시, 질문 목록을 가져옴
  Future<bool> startTest() async {
    debugPrint('🎯 [APTITUDE_PROVIDER] 검사 시작');
    _setLoading(true);
    _answers.clear();
    try {
      _questions = await _repository.getQuestions();
      debugPrint('✅ [APTITUDE_PROVIDER] 질문 ${_questions.length}개 로드');
      return _questions.isNotEmpty;
    } catch (e) {
      debugPrint('❌ [APTITUDE_PROVIDER] 질문 로드 실패: $e');
      _errorMessage = '검사지를 불러오는 데 실패했습니다: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 모든 성향 타입 목록을 가져옴
  Future<void> fetchAllTypes() async {
    debugPrint('📋 [APTITUDE_PROVIDER] 모든 성향 목록 가져오기 시작');
    _setLoading(true);
    try {
      _allTypes = await _repository.getAllTypes();
      debugPrint('✅ [APTITUDE_PROVIDER] 성향 ${_allTypes.length}개 로드');
      
      // 로드된 성향들 로그 출력
      for (final type in _allTypes) {
        debugPrint('   - ${type.typeCode}: ${type.typeName}');
      }
    } catch (e) {
      debugPrint('❌ [APTITUDE_PROVIDER] 성향 목록 로드 실패: $e');
      _errorMessage = '성향 목록을 불러오는 데 실패했습니다: ${e.toString()}';
      _allTypes = [];
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 타입의 상세 결과를 가져와 currentResult에 저장
  Future<bool> fetchResultByType(String typeCode) async {
    debugPrint('🔎 [APTITUDE_PROVIDER] fetchResultByType 시작: $typeCode');
    
    try {
      _setLoading(true);
      _errorMessage = null; // 이전 에러 메시지 초기화
      
      debugPrint('📡 [APTITUDE_PROVIDER] Repository 호출 중...');
      
      // 타임아웃과 함께 실행 (수정된 버전)
      _currentResult = await _repository.getResultByType(typeCode).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏰ [APTITUDE_PROVIDER] 타임아웃 발생');
          throw Exception('요청 시간이 초과되었습니다');
        },
      );
      
      if (_currentResult != null) {
        debugPrint('✅ [APTITUDE_PROVIDER] 결과 로드 성공: ${_currentResult!.typeName}');
        debugPrint('   거장: ${_currentResult!.master.name}');
        return true;
      } else {
        debugPrint('⚠️ [APTITUDE_PROVIDER] 결과가 null');
        _errorMessage = '결과를 불러올 수 없습니다';
        return false;
      }
    } catch (e) {
      debugPrint('💥 [APTITUDE_PROVIDER] fetchResultByType 예외: $e');
      _errorMessage = '상세 결과를 불러오는 데 실패했습니다: ${e.toString()}';
      _currentResult = null;
      return false;
    } finally {
      debugPrint('🏁 [APTITUDE_PROVIDER] fetchResultByType 완료');
      _setLoading(false);
    }
  }

  /// 특정 질문에 대한 답변을 저장
  void answerQuestion(int questionId, int value) {
    _answers[questionId] = value;
    debugPrint('💭 [APTITUDE_PROVIDER] 답변 저장: Q$questionId = $value');
    notifyListeners();
  }

  /// 모든 답변을 서버에 제출
  Future<bool> submitAnswers() async {
    debugPrint('📤 [APTITUDE_PROVIDER] 답변 제출 시작');
    _setLoading(true);
    try {
      final answerList = _answers.entries.map((e) {
        return Answer(questionId: e.key, value: e.value);
      }).toList();

      final request = AptitudeAnswerRequest(answers: answerList);
      debugPrint('📤 [APTITUDE_PROVIDER] ${answerList.length}개 답변 제출');

      if (_hasPreviousResult) {
        debugPrint('🔄 [APTITUDE_PROVIDER] 재검사 모드');
        _currentResult = await _repository.retest(request);
      } else {
        debugPrint('🆕 [APTITUDE_PROVIDER] 신규 검사 모드');
        _currentResult = await _repository.submitResult(request);
      }

      _myResult = _currentResult;
      _hasPreviousResult = true;
      debugPrint('✅ [APTITUDE_PROVIDER] 답변 제출 성공: ${_currentResult?.typeName}');
      return true;
    } catch (e) {
      debugPrint('❌ [APTITUDE_PROVIDER] 답변 제출 실패: $e');
      _errorMessage = '결과 제출에 실패했습니다: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 로딩 상태 변경 및 UI 업데이트 알림
  void _setLoading(bool value) {
    debugPrint('⚡ [APTITUDE_PROVIDER] 로딩 상태 변경: $_isLoading → $value');
    _isLoading = value;
    notifyListeners();
  }
}