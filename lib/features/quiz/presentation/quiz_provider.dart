import 'package:flutter/foundation.dart';
import '../domain/quiz_repository.dart';
import '../domain/quiz_mock_repository.dart';
import '../domain/models/quiz_session.dart';
import '../domain/models/quiz_result.dart';

/// 퀴즈 상태 관리 Provider
class QuizProvider extends ChangeNotifier {
  final QuizRepository? _repository;
  final QuizMockRepository? _mockRepository;
  final bool _useMock;

  // 퀴즈 완료 시 호출될 콜백 함수들
  final List<Function(int chapterId, QuizResult result)>
      _onQuizCompletedCallbacks = [];

  // 단일 퀴즈 완료 시 호출될 콜백 함수들 (오답노트 관리용)
  final List<
          Function(
              int chapterId, int quizId, bool isCorrect, int selectedOption)>
      _onSingleQuizCompletedCallbacks = [];

  // 단일 퀴즈 오답 삭제 완료 시 호출될 콜백 함수들 (네비게이션용)
  final List<Function(int quizId)> _onWrongNoteRemovedCallbacks = [];

  /// 실제 API Repository를 사용하는 생성자
  QuizProvider(QuizRepository repository)
      : _repository = repository,
        _mockRepository = null,
        _useMock = false;

  /// Mock Repository를 사용하는 생성자 (UI 개발/테스트용)
  QuizProvider.withMock(QuizMockRepository mockRepository)
      : _repository = null,
        _mockRepository = mockRepository,
        _useMock = true;

  /// 퀴즈 완료 콜백 등록
  void addOnQuizCompletedCallback(
      Function(int chapterId, QuizResult result) callback) {
    _onQuizCompletedCallbacks.add(callback);
  }

  /// 퀴즈 완료 콜백 해제
  void removeOnQuizCompletedCallback(
      Function(int chapterId, QuizResult result) callback) {
    _onQuizCompletedCallbacks.remove(callback);
  }

  /// 단일 퀴즈 완료 콜백 등록
  void addOnSingleQuizCompletedCallback(
      Function(int chapterId, int quizId, bool isCorrect, int selectedOption)
          callback) {
    _onSingleQuizCompletedCallbacks.add(callback);
  }

  /// 단일 퀴즈 완료 콜백 해제
  void removeOnSingleQuizCompletedCallback(
      Function(int chapterId, int quizId, bool isCorrect, int selectedOption)
          callback) {
    _onSingleQuizCompletedCallbacks.remove(callback);
  }

  /// 오답노트 삭제 완료 콜백 등록
  void addOnWrongNoteRemovedCallback(Function(int quizId) callback) {
    _onWrongNoteRemovedCallbacks.add(callback);
  }

  /// 오답노트 삭제 완료 콜백 해제
  void removeOnWrongNoteRemovedCallback(Function(int quizId) callback) {
    _onWrongNoteRemovedCallbacks.remove(callback);
  }

  /// 오답노트 삭제 완료 알림 (외부에서 호출)
  void notifyWrongNoteRemoved(int quizId) {
    for (final callback in _onWrongNoteRemovedCallbacks) {
      try {
        callback(quizId);
      } catch (e) {
        debugPrint('오답노트 삭제 완료 콜백 실행 실패: $e');
      }
    }
  }

  // === 퀴즈 세션 관련 상태 ===
  QuizSession? _currentQuizSession;
  bool _isLoadingQuiz = false;
  bool _isSubmittingAnswer = false;
  String? _quizError;

  // === 읽기 전용 모드 (오답노트 복습용) ===
  bool _isReadOnlyMode = false;

  // === 타이머 관련 상태 ===
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;

  // === 퀴즈 결과 관련 상태 ===
  List<QuizResult> _quizResults = [];
  bool _isLoadingResults = false;
  String? _resultsError;

  // === Getters ===

  /// 현재 퀴즈 세션
  QuizSession? get currentQuizSession => _currentQuizSession;

  /// 퀴즈 로딩 중인지
  bool get isLoadingQuiz => _isLoadingQuiz;

  /// 답안 제출 중인지
  bool get isSubmittingAnswer => _isSubmittingAnswer;

  /// 퀴즈 오류 메시지
  String? get quizError => _quizError;

  /// 퀴즈 결과 목록
  List<QuizResult> get quizResults => _quizResults;

  /// 퀴즈 결과 로딩 중인지
  bool get isLoadingResults => _isLoadingResults;

  /// 퀴즈 결과 오류 메시지
  String? get resultsError => _resultsError;

  /// 현재 퀴즈 정보
  get currentQuiz => _currentQuizSession?.currentQuiz;

  /// 전체 퀴즈 개수
  int get totalQuizCount => _currentQuizSession?.totalCount ?? 0;

  /// 현재 퀴즈 인덱스
  int get currentQuizIndex => _currentQuizSession?.currentQuizIndex ?? 0;

  /// 다음 퀴즈가 있는지
  bool get hasNextQuiz => _currentQuizSession?.hasNext ?? false;

  /// 이전 퀴즈가 있는지
  bool get hasPreviousQuiz => _currentQuizSession?.hasPrevious ?? false;

  /// 현재 진행률 (0.0 ~ 1.0)
  double get progressRatio => _currentQuizSession?.progressRatio ?? 0.0;

  /// 답변한 퀴즈 개수
  int get answeredCount => _currentQuizSession?.answeredCount ?? 0;

  /// 모든 퀴즈에 답했는지
  bool get isAllAnswered => _currentQuizSession?.isAllAnswered ?? false;

  /// 남은 시간 (초)
  int get remainingSeconds => _remainingSeconds;

  /// 타이머 실행 중인지
  bool get isTimerRunning => _isTimerRunning;

  /// 읽기 전용 모드인지 (오답노트 복습용)
  bool get isReadOnlyMode => _isReadOnlyMode;

  /// 🚨 ReadOnly 모드 해제 (무한루프 방지용)
  void exitReadOnlyMode() {
    if (_isReadOnlyMode) {
      _isReadOnlyMode = false;
      debugPrint('🛡️ [QUIZ_PROVIDER] ReadOnly 모드 해제 완료');
      notifyListeners();
    }
  }

  /// 남은 시간 포맷 (MM:SS)
  String get formattedRemainingTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // === 퀴즈 세션 관련 메서드 ===

  /// 퀴즈 진입 (API.md 스펙 준수)
  ///
  /// [chapterId]: 시작할 챕터 ID
  Future<bool> startQuiz(int chapterId) async {
    if (_isLoadingQuiz) return false;

    debugPrint(
        '🧠 [QUIZ_PROVIDER] 일반 퀴즈 진입 요청 - 챕터 ID: $chapterId (useMock: $_useMock)');
    _isLoadingQuiz = true;
    _quizError = null;
    notifyListeners();

    try {
      if (_useMock) {
        debugPrint('🎭 [QUIZ_PROVIDER] Mock Repository로 퀴즈 진입 중...');
        _currentQuizSession = await _mockRepository!.enterQuiz(chapterId);
      } else {
        debugPrint('🌐 [QUIZ_PROVIDER] Real API Repository로 퀴즈 진입 중...');
        _currentQuizSession = await _repository!.enterQuiz(chapterId);
      }

      // 기본 10분 타이머 시작 (API.md 스펙에서 timeLimit 제거됨)
      _startTimer(600); // 10분
      debugPrint('⏰ [QUIZ_PROVIDER] 퀴즈 타이머 시작 - 10분');

      debugPrint(
          '✅ [QUIZ_PROVIDER] 일반 퀴즈 진입 성공 - 총 ${_currentQuizSession?.totalCount ?? 0}개 문제');
      _quizError = null;
      return true;
    } catch (e) {
      _quizError = e.toString();
      debugPrint('❌ [QUIZ_PROVIDER] 일반 퀴즈 진입 실패 - 챕터: $chapterId, 에러: $e');
      return false;
    } finally {
      _isLoadingQuiz = false;
      notifyListeners();
    }
  }

  /// 단일 퀴즈 진입 (오답노트 재시도용)
  ///
  /// [chapterId]: 챕터 ID
  /// [quizId]: 특정 퀴즈 ID
  /// [isReadOnly]: 읽기 전용 모드 (오답노트 복습용, DB 수정 없음)
  ///
  /// ReadOnly 모드에서는 DB를 수정하지 않고 복습만 가능합니다.
  Future<bool> startSingleQuiz(int chapterId, int quizId,
      {bool isReadOnly = false}) async {
    if (_isLoadingQuiz) return false;

    debugPrint(
        '🎯 [QUIZ_PROVIDER] 단일 퀴즈 진입 요청 - 챕터: $chapterId, 퀴즈: $quizId (useMock: $_useMock, readOnly: $isReadOnly)');
    _isLoadingQuiz = true;
    _quizError = null;
    _isReadOnlyMode = isReadOnly; // 읽기 전용 모드 설정

    if (_isReadOnlyMode) {
      debugPrint('📖 [QUIZ_PROVIDER] ReadOnly 모드 활성화 - DB 수정 없음, 복습 전용');
      debugPrint('🛡️ [QUIZ_PROVIDER] 이 모드에서는 오답노트가 삭제되지 않습니다');
    } else {
      debugPrint('🔄 [QUIZ_PROVIDER] 일반 모드 - DB 수정 포함');
    }

    notifyListeners();

    try {
      // 먼저 전체 퀴즈 세션을 가져온 후 특정 퀴즈만 필터링
      QuizSession fullSession;
      if (_useMock) {
        debugPrint('🎭 [QUIZ_PROVIDER] Mock Repository로 단일 퀴즈 데이터 로드 중...');
        fullSession = await _mockRepository!.enterQuiz(chapterId);
      } else {
        debugPrint('🌐 [QUIZ_PROVIDER] Real API Repository로 단일 퀴즈 데이터 로드 중...');
        fullSession = await _repository!.enterQuiz(chapterId);
      }

      // 해당 quizId를 가진 퀴즈만 찾기
      final targetQuiz =
          fullSession.quizList.where((quiz) => quiz.id == quizId).toList();

      if (targetQuiz.isEmpty) {
        debugPrint('❌ [QUIZ_PROVIDER] 단일 퀴즈 찾기 실패 - ID: $quizId');
        throw Exception('해당 퀴즈를 찾을 수 없습니다 (ID: $quizId)');
      }

      debugPrint(
          '🔍 [QUIZ_PROVIDER] 단일 퀴즈 찾기 성공 - 문제: ${targetQuiz.first.question}');

      // 단일 퀴즈로 구성된 새로운 QuizSession 생성
      _currentQuizSession = QuizSession(
        chapterId: chapterId,
        quizList: targetQuiz,
        currentQuizId: targetQuiz.first.id,
        userAnswers: [null], // 1개 퀴즈이므로 하나의 null 답안
        startedAt: DateTime.now(),
        isSingleQuizMode: true, // 단일 퀴즈 모드 표시
      );

      // 단일 퀴즈는 5분 타이머
      _startTimer(300); // 5분
      debugPrint('⏰ [QUIZ_PROVIDER] 단일 퀴즈 타이머 시작 - 5분');

      _quizError = null;
      debugPrint('✅ [QUIZ_PROVIDER] 단일 퀴즈 진입 성공 - 챕터: $chapterId, 퀴즈: $quizId');
      return true;
    } catch (e) {
      _quizError = e.toString();
      debugPrint(
          '❌ [QUIZ_PROVIDER] 단일 퀴즈 진입 실패 - 챕터: $chapterId, 퀴즈: $quizId, 에러: $e');
      return false;
    } finally {
      _isLoadingQuiz = false;
      notifyListeners();
    }
  }

  /// 답안 제출 및 진행 상황 업데이트 (API.md 스펙)
  ///
  /// [selectedAnswer]: 선택한 답안 인덱스 (0-based)
  Future<bool> submitAnswer(int selectedAnswer) async {
    if (_isSubmittingAnswer || _currentQuizSession == null) return false;

    _isSubmittingAnswer = true;
    notifyListeners();

    try {
      final chapterId = _currentQuizSession!.chapterId;
      final currentQuizIndex = _currentQuizSession!.currentQuizIndex;
      final currentQuizId = _currentQuizSession!.currentQuizId;

      // 1. 로컬 답안 저장 (즉시 UI 업데이트용)
      _updateLocalAnswer(currentQuizIndex, selectedAnswer);

      // 2. Mock에서는 진행상황 업데이트만, Real에서는 서버와 통신
      if (_useMock) {
        await _mockRepository!.updateQuizProgress(chapterId, currentQuizId);
        // Mock에서는 로컬 Repository를 통해 답안도 업데이트
        await _repository?.updateLocalAnswer(
            chapterId, currentQuizIndex, selectedAnswer);
      } else {
        // Real API: 서버에 진행상황 업데이트 + 로컬 답안 저장
        await _repository!.updateQuizProgress(chapterId, currentQuizId);
        await _repository.updateLocalAnswer(
            chapterId, currentQuizIndex, selectedAnswer);
      }

      return true;
    } catch (e) {
      _quizError = e.toString();
      debugPrint('답안 제출 및 진행상황 업데이트 실패: $e');
      return false;
    } finally {
      _isSubmittingAnswer = false;
      notifyListeners();
    }
  }

  /// 다음 퀴즈로 이동 (currentQuizId 기반)
  void moveToNextQuiz() {
    if (_currentQuizSession?.hasNext ?? false) {
      final currentIndex = _currentQuizSession!.currentQuizIndex;
      final nextIndex = currentIndex + 1;
      if (nextIndex < _currentQuizSession!.quizList.length) {
        final nextQuizId = _currentQuizSession!.quizList[nextIndex].id;
        _currentQuizSession = _currentQuizSession!.copyWith(
          currentQuizId: nextQuizId,
        );
        notifyListeners();
      }
    }
  }

  /// 이전 퀴즈로 이동 (currentQuizId 기반)
  void moveToPreviousQuiz() {
    if (_currentQuizSession?.hasPrevious ?? false) {
      final currentIndex = _currentQuizSession!.currentQuizIndex;
      final prevIndex = currentIndex - 1;
      if (prevIndex >= 0) {
        final prevQuizId = _currentQuizSession!.quizList[prevIndex].id;
        _currentQuizSession = _currentQuizSession!.copyWith(
          currentQuizId: prevQuizId,
        );
        notifyListeners();
      }
    }
  }

  /// 특정 퀴즈로 이동 (currentQuizId 기반)
  ///
  /// [index]: 이동할 퀴즈 인덱스
  void moveToQuiz(int index) {
    if (_currentQuizSession == null ||
        index < 0 ||
        index >= _currentQuizSession!.totalCount) {
      return;
    }

    final targetQuizId = _currentQuizSession!.quizList[index].id;
    _currentQuizSession = _currentQuizSession!.copyWith(
      currentQuizId: targetQuizId,
    );
    notifyListeners();
  }

  /// 퀴즈 완료 (API.md 스펙)
  ///
  /// Returns: QuizResult?
  Future<QuizResult?> completeQuiz() async {
    if (_currentQuizSession == null) return null;

    _isLoadingQuiz = true;
    _quizError = null;
    notifyListeners();

    try {
      final chapterId = _currentQuizSession!.chapterId;

      // 사용자 답안을 API 형식으로 변환: [{"quiz_id": 1, "selected_option": 2}]
      final answers = <Map<String, int>>[];
      for (int i = 0; i < _currentQuizSession!.quizList.length; i++) {
        final quiz = _currentQuizSession!.quizList[i];
        final userAnswer = _currentQuizSession!.userAnswers[i];
        if (userAnswer != null) {
          answers.add({
            'quiz_id': quiz.id,
            'selected_option': userAnswer + 1, // 0-based → 1-based 변환
          });
        }
      }

      QuizResult result;
      if (_useMock) {
        result = await _mockRepository!.completeQuiz(chapterId, answers);
      } else {
        result = await _repository!.completeQuiz(chapterId, answers);
      }

      // 결과 목록에 추가
      _quizResults.insert(0, result);

      // 단일 퀴즈 모드일 때 오답노트 삭제 처리
      final isSingleMode = _currentQuizSession!.isSingleQuizMode;
      if (isSingleMode && _currentQuizSession!.quizList.isNotEmpty) {
        final quiz = _currentQuizSession!.quizList.first;
        final userAnswer = _currentQuizSession!.userAnswers.first;
        final isCorrect = userAnswer == quiz.correctAnswerIndex;

        // 단일 퀴즈 완료 콜백 호출 (오답노트 관리용)
        for (final callback in _onSingleQuizCompletedCallbacks) {
          try {
            // selectedOption을 1-based로 변환 (백엔드 API 호환)
            final selectedOptionOneBased = userAnswer! + 1;
            callback(_currentQuizSession!.chapterId, quiz.id, isCorrect,
                selectedOptionOneBased);
          } catch (e) {
            debugPrint('단일 퀴즈 완료 콜백 실행 실패: $e');
          }
        }

        debugPrint(
            '🎯 [SINGLE_QUIZ] 단일 퀴즈 완료 - Quiz ${quiz.id}, 정답: $isCorrect');
      }

      // 일반 퀴즈 완료 콜백 호출 (교육 진도 업데이트용)
      if (!isSingleMode) {
        for (final callback in _onQuizCompletedCallbacks) {
          try {
            callback(chapterId, result);
          } catch (e) {
            debugPrint('퀴즈 완료 콜백 실행 실패: $e');
          }
        }
      }

      // 세션 정리
      _stopTimer();
      _currentQuizSession = null;

      debugPrint(
          '🎯 [QUIZ_PROVIDER] 퀴즈 완료 - 챕터 $chapterId, 점수: ${result.correctAnswers}/${result.totalQuestions} (${result.scorePercentage}%)');
      return result;
    } catch (e) {
      _quizError = e.toString();
      debugPrint('퀴즈 완료 실패: $e');
      return null;
    } finally {
      _isLoadingQuiz = false;
      notifyListeners();
    }
  }

  /// 퀴즈 중단 (완료하지 않고 나가기)
  Future<void> exitQuiz() async {
    _stopTimer();

    if (_useMock) {
      // Mock에서는 별도 처리 없음
    } else {
      // 실제 API에서는 진행 상황 저장 등 처리
    }

    _currentQuizSession = null;
    _remainingSeconds = 0;
    _quizError = null;
    _isReadOnlyMode = false; // 읽기 전용 모드 초기화
    notifyListeners();
  }

  // === 퀴즈 결과 관련 메서드 ===

  /// 퀴즈 결과 로드
  ///
  /// [chapterId]: 조회할 챕터 ID
  Future<void> loadQuizResults(int chapterId) async {
    if (_isLoadingResults) return;

    _isLoadingResults = true;
    _resultsError = null;
    notifyListeners();

    try {
      if (_useMock) {
        _quizResults = await _mockRepository!.getQuizResults(chapterId);
      } else {
        _quizResults = await _repository!.getQuizResults(chapterId);
      }
      _resultsError = null;
    } catch (e) {
      _resultsError = e.toString();
      debugPrint('퀴즈 결과 로드 실패: $e');
    } finally {
      _isLoadingResults = false;
      notifyListeners();
    }
  }

  /// 현재 진행 중인 퀴즈 세션 복원
  Future<void> restoreQuizSession() async {
    try {
      QuizSession? session;
      if (_useMock) {
        session = await _mockRepository!.getCurrentQuizSession();
      } else {
        session = await _repository!.getCurrentQuizSession();
      }

      if (session != null) {
        _currentQuizSession = session;

        // 진행 중인 세션이 있다면 기본 10분 타이머 시작
        final elapsed =
            DateTime.now().difference(_currentQuizSession!.startedAt).inSeconds;
        final defaultTimeLimit = 600; // 10분 고정
        final remaining = defaultTimeLimit - elapsed;
        if (remaining > 0) {
          _startTimer(remaining);
        } else {
          _startTimer(defaultTimeLimit); // 새로운 10분 타이머
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('퀴즈 세션 복원 실패: $e');
    }
  }

  /// 퀴즈 캐시 삭제
  Future<void> clearQuizCache() async {
    try {
      if (!_useMock) {
        await _repository!.clearQuizCache();
      }

      _quizResults.clear();
      _currentQuizSession = null;
      _quizError = null;
      _resultsError = null;

      notifyListeners();
    } catch (e) {
      debugPrint('퀴즈 캐시 삭제 실패: $e');
    }
  }

  // === Private 메서드들 ===

  /// 로컬 답안 상태 업데이트
  void _updateLocalAnswer(int quizIndex, int selectedAnswer) {
    if (_currentQuizSession != null) {
      final updatedAnswers = List<int?>.from(_currentQuizSession!.userAnswers);
      updatedAnswers[quizIndex] = selectedAnswer;

      _currentQuizSession = _currentQuizSession!.copyWith(
        userAnswers: updatedAnswers,
      );
    }
  }

  /// 타이머 시작
  void _startTimer(int seconds) {
    _remainingSeconds = seconds;
    _isTimerRunning = true;

    // 실제 타이머 구현은 여기서 처리
    // 예: Timer.periodic을 사용하여 1초마다 _remainingSeconds 감소
    // 시간이 0이 되면 자동으로 퀴즈 완료 처리

    notifyListeners();
  }

  /// 타이머 중지
  void _stopTimer() {
    _isTimerRunning = false;
    notifyListeners();
  }
}
