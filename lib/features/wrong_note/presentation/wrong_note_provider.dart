import 'package:flutter/material.dart';
import '../domain/wrong_note_repository.dart';
import '../data/wrong_note_mock_repository.dart';
import '../data/models/wrong_note_request.dart';
import '../data/models/wrong_note_response.dart';

/// 오답노트 상태 관리 Provider
class WrongNoteProvider extends ChangeNotifier {
  final WrongNoteRepository? _repository;
  final WrongNoteMockRepository? _mockRepository;

  // 상태 변수들
  List<WrongNoteItem> _wrongNotes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 재시도된 퀴즈 ID들을 추적 (isRetried 대체)
  Set<int> _retriedQuizIds = {};

  // Getters
  List<WrongNoteItem> get wrongNotes => _wrongNotes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  Set<int> get retriedQuizIds => Set.from(_retriedQuizIds);

  /// 실제 API Repository 사용 생성자
  WrongNoteProvider(this._repository) : _mockRepository = null;

  /// Mock Repository 사용 생성자
  WrongNoteProvider.withMock(this._mockRepository) : _repository = null;

  /// 오답노트 목록 로드
  /// [chapterId]: 선택사항 - null이면 전체 챕터 조회
  Future<void> loadWrongNotes({int? chapterId}) async {
    debugPrint('📚 [WrongNote] 오답노트 로드 시작 (chapterId: $chapterId)');
    _setLoading(true);
    _clearError();

    try {
      final WrongNoteResponse response;

      if (_mockRepository != null) {
        // Mock 데이터 사용
        debugPrint('🎭 [WrongNote] Mock Repository 사용');
        response = await _mockRepository.getWrongNotes('mock_user');
        // Mock Repository에서 재시도 상태 정보도 가져오기
        _retriedQuizIds = _mockRepository.retriedQuizIds;
      } else if (_repository != null) {
        // 실제 API 사용 - chapterId 지원
        debugPrint('🌐 [WrongNote] Real API Repository 사용');
        response = await _repository.getWrongNotes(chapterId: chapterId);
        // 실제 API에서는 별도로 재시도 상태 정보를 가져와야 할 수 있음
        // TODO: 실제 API 구현 시 재시도 상태 로직 추가
      } else {
        throw Exception('Repository가 설정되지 않았습니다.');
      }

      _wrongNotes = response.wrongNotes;
      debugPrint('✅ [WrongNote] 오답노트 로드 완료 - ${_wrongNotes.length}개 문제');
      
      // 각 문제 정보 출력 (디버깅용)
      for (int i = 0; i < _wrongNotes.length; i++) {
        final note = _wrongNotes[i];
        debugPrint('   [$i] ID: ${note.id}, Quiz: ${note.quizId}, Chapter: ${note.chapterId}');
        
        // 문자열 안전하게 자르기
        String questionPreview = '미지정';
        if (note.question != null) {
          final question = note.question!;
          questionPreview = question.length > 20 ? '${question.substring(0, 20)}...' : question;
        }
        debugPrint('       문제: $questionPreview');
        debugPrint('       선택: ${note.selectedOption}, 정답: ${note.correctAnswerIndex}');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [WrongNote] 오답노트 로드 실패: $e');
      _setError('오답노트 로드 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 퀴즈 결과 제출 (일반 퀴즈 전용)
  /// [chapterId]: 챕터 ID
  /// [wrongItems]: 오답 항목 리스트
  Future<void> submitQuizResults(
      int chapterId, List<Map<String, dynamic>> wrongItems) async {
    try {
      debugPrint('📝 [WrongNote] 일반 퀴즈 결과 제출 시작 - Chapter: $chapterId, 오답 수: ${wrongItems.length}');
      
      if (_mockRepository != null) {
        // Mock repository는 기존 방식 유지 - WrongNoteRequest 형식으로 변환
        final request = WrongNoteRequest(
          userId: 'mock_user',
          chapterId: chapterId,
          results: wrongItems
              .map((item) => QuizResult(
                    quizId: item['quiz_id'],
                    isCorrect: false, // 오답이므로 false
                  ))
              .toList(),
        );
        await _mockRepository.submitQuizResults(request);
      } else if (_repository != null) {
        // 실제 API는 새로운 방식 사용
        await _repository.submitQuizResults(chapterId, wrongItems);
      }

      // 제출 후 오답노트 다시 로드
      await loadWrongNotes();
      debugPrint('✅ [WrongNote] 일반 퀴즈 결과 제출 완료');
    } catch (e) {
      debugPrint('❌ [WrongNote] 일반 퀴즈 결과 제출 실패: $e');
      _setError('퀴즈 결과 제출 실패: $e');
    }
  }

  /// 단일 퀴즈 결과 제출 (단일 퀴즈 전용)
  /// [chapterId]: 챕터 ID
  /// [quizId]: 퀴즈 ID
  /// [selectedOption]: 선택한 답안 (1~4)
  Future<void> submitSingleQuizResult(int chapterId, int quizId, int selectedOption) async {
    try {
      debugPrint('📝 [WrongNote] 단일 퀴즈 결과 제출 시작 - Chapter: $chapterId, Quiz: $quizId, Option: $selectedOption');
      
      if (_mockRepository != null) {
        debugPrint('🎭 [WrongNote] Mock Repository로 단일 퀴즈 제출');
        await _mockRepository.submitSingleQuizResult('mock_user', chapterId, quizId, selectedOption);
      } else if (_repository != null) {
        debugPrint('🌐 [WrongNote] Real API Repository로 단일 퀴즈 제출');
        await _repository.submitSingleQuizResult(chapterId, quizId, selectedOption);
      }

      // 제출 후 오답노트 다시 로드 (새로운 오답이 추가되었으므로)
      await loadWrongNotes();
      debugPrint('✅ [WrongNote] 단일 퀴즈 결과 제출 완료 - Quiz $quizId 오답노트에 추가됨');
    } catch (e) {
      debugPrint('❌ [WrongNote] 단일 퀴즈 결과 제출 실패: $e');
      _setError('단일 퀴즈 결과 제출 실패: $e');
    }
  }

  /// 문제 재시도 표시
  Future<void> markAsRetried(int quizId) async {
    try {
      if (_mockRepository != null) {
        await _mockRepository.markAsRetried('mock_user', quizId);
      } else if (_repository != null) {
        await _repository.markAsRetried(quizId);
      }

      // 로컬 상태 업데이트 (재시도 Set에 추가)
      _retriedQuizIds.add(quizId);
      notifyListeners();
    } catch (e) {
      _setError('재시도 표시 실패: $e');
    }
  }

  /// 오답노트에서 문제 삭제 (정답 처리 시)
  Future<void> removeWrongNote(int quizId) async {
    debugPrint('🗑️ [WrongNote] 오답노트 삭제 시작 - Quiz ID: $quizId');
    
    // 현재 오답노트 상태 요약 로깅
    debugPrint('📊 [WrongNote] 현재 오답노트 상태: ${_wrongNotes.length}개 문제');
    for (final note in _wrongNotes) {
      debugPrint('   - Quiz ${note.quizId} (Chapter: ${note.chapterId}, Selected: ${note.selectedOption})');
    }
    
    // 로컬에서 해당 quiz_id 찾기
    final existingNote = _wrongNotes.where((item) => item.quizId == quizId).toList();
    if (existingNote.isEmpty) {
      debugPrint('⚠️ [WrongNote] 로컬에서 Quiz $quizId를 찾을 수 없음');
      debugPrint('💡 [WrongNote] 가능한 원인:');
      debugPrint('   1. 이미 삭제된 문제');
      debugPrint('   2. 오답노트에 없던 문제 (원래 정답이었던 문제)');
      debugPrint('   3. 서버와 로컬 상태 불일치');
      debugPrint('🏁 [WrongNote] 삭제 작업 건너뛰기');
      return; // 로컬에 없으면 삭제할 필요 없음
    }
    
    debugPrint('📍 [WrongNote] 삭제 대상 발견: ${existingNote.length}개');
    for (final note in existingNote) {
      debugPrint('   - ID: ${note.id}, Quiz: ${note.quizId}, Chapter: ${note.chapterId}');
      debugPrint('   - 선택: ${note.selectedOption}, 정답: ${note.correctAnswerIndex}');
    }

    try {
      if (_mockRepository != null) {
        debugPrint('🎭 [WrongNote] Mock Repository로 삭제 API 호출');
        await _mockRepository.removeWrongNote('mock_user', quizId);
      } else if (_repository != null) {
        debugPrint('🌐 [WrongNote] Real API Repository로 삭제 API 호출');
        await _repository.removeWrongNote(quizId);
      }

      // API 호출 성공 시 로컬 상태에서 제거
      final removedCount = _wrongNotes.length;
      _wrongNotes.removeWhere((item) => item.quizId == quizId);
      final currentCount = _wrongNotes.length;
      final actualRemoved = removedCount - currentCount;
      
      debugPrint('✅ [WrongNote] 서버 & 로컬 삭제 성공!');
      debugPrint('   - Quiz ID: $quizId');
      debugPrint('   - 제거된 항목 수: $actualRemoved개');
      debugPrint('   - 삭제 전 총 개수: $removedCount개 → 삭제 후: $currentCount개');
      notifyListeners();
      
    } catch (e) {
      final errorStr = e.toString();
      
      // 404 에러 처리: 서버에서 이미 삭제되었거나 없는 경우
      if (errorStr.contains('404') || errorStr.contains('찾을 수 없습니다')) {
        debugPrint('🤷‍♀️ [WrongNote] 서버 404 에러 - Quiz $quizId를 찾을 수 없음');
        debugPrint('💡 [WrongNote] 서버에서 이미 삭제되었을 가능성이 높음');
        debugPrint('🧹 [WrongNote] 로컬 상태만 정리하여 서버와 동기화');
        
        // 로컬에서는 제거 (서버와 동기화)
        final removedCount = _wrongNotes.length;
        _wrongNotes.removeWhere((item) => item.quizId == quizId);
        final currentCount = _wrongNotes.length;
        final actualRemoved = removedCount - currentCount;
        
        debugPrint('✅ [WrongNote] 로컬 정리 완료 - ${actualRemoved}개 항목 제거됨');
        notifyListeners();
        return; // 404는 성공으로 처리
      }
      
      // 다른 에러는 실제 에러로 처리
      debugPrint('❌ [WrongNote] 오답노트 삭제 실패 - Quiz $quizId');
      debugPrint('💥 [WrongNote] 에러 상세: $e');
      debugPrint('🚨 [WrongNote] 이 에러는 상위 콜백으로 전파됩니다');
      _setError('오답노트 삭제 실패: $e');
      rethrow; // 실제 에러는 다시 던져서 상위에서 처리
    }
  }

  /// 챕터별 필터링
  List<WrongNoteItem> getWrongNotesByChapter(int chapterId) {
    return _wrongNotes.where((item) => item.chapterId == chapterId).toList();
  }

  /// 재시도 여부별 필터링
  List<WrongNoteItem> getWrongNotesByRetryStatus(bool isRetried) {
    return _wrongNotes
        .where((item) => _retriedQuizIds.contains(item.quizId) == isRetried)
        .toList();
  }

  /// 통계 정보 가져오기
  Map<String, int> getStatistics() {
    final totalCount = _wrongNotes.length;
    final retriedCount = _wrongNotes
        .where((item) => _retriedQuizIds.contains(item.quizId))
        .length;
    final pendingCount = totalCount - retriedCount;

    return {
      'total': totalCount,
      'retried': retriedCount,
      'pending': pendingCount,
    };
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 설정
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 에러 클리어
  void _clearError() {
    _errorMessage = null;
  }

  /// 에러 클리어 (외부에서 호출 가능)
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
