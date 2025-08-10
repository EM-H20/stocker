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

  // === 퀴즈 세션 관련 상태 ===
  QuizSession? _currentQuizSession;
  bool _isLoadingQuiz = false;
  bool _isSubmittingAnswer = false;
  String? _quizError;

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

  /// 남은 시간 포맷 (MM:SS)
  String get formattedRemainingTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // === 퀴즈 세션 관련 메서드 ===

  /// 퀴즈 시작
  ///
  /// [chapterId]: 시작할 챕터 ID
  Future<bool> startQuiz(int chapterId) async {
    if (_isLoadingQuiz) return false;

    _isLoadingQuiz = true;
    _quizError = null;
    notifyListeners();

    try {
      if (_useMock) {
        _currentQuizSession = await _mockRepository!.startQuiz(chapterId);
      } else {
        _currentQuizSession = await _repository!.startQuiz(chapterId);
      }

      // 타이머 시작 (시간 제한이 있는 경우)
      if (_currentQuizSession?.timeLimit != null) {
        _startTimer(_currentQuizSession!.timeLimit!);
      }

      _quizError = null;
      return true;
    } catch (e) {
      _quizError = e.toString();
      debugPrint('퀴즈 시작 실패: $e');
      return false;
    } finally {
      _isLoadingQuiz = false;
      notifyListeners();
    }
  }

  /// 답안 제출
  ///
  /// [selectedAnswer]: 선택한 답안 인덱스
  Future<bool> submitAnswer(int selectedAnswer) async {
    if (_isSubmittingAnswer || _currentQuizSession == null) return false;

    _isSubmittingAnswer = true;
    notifyListeners();

    try {
      final chapterId = _currentQuizSession!.chapterId;
      final quizIndex = _currentQuizSession!.currentQuizIndex;

      if (_useMock) {
        await _mockRepository!.submitAnswer(
          chapterId,
          quizIndex,
          selectedAnswer,
        );
      } else {
        await _repository!.submitAnswer(chapterId, quizIndex, selectedAnswer);
      }

      // 로컬 상태 업데이트
      _updateLocalAnswer(quizIndex, selectedAnswer);

      return true;
    } catch (e) {
      _quizError = e.toString();
      debugPrint('답안 제출 실패: $e');
      return false;
    } finally {
      _isSubmittingAnswer = false;
      notifyListeners();
    }
  }

  /// 다음 퀴즈로 이동
  void moveToNextQuiz() {
    if (_currentQuizSession?.hasNext ?? false) {
      _currentQuizSession = _currentQuizSession!.copyWith(
        currentQuizIndex: _currentQuizSession!.currentQuizIndex + 1,
      );
      notifyListeners();
    }
  }

  /// 이전 퀴즈로 이동
  void moveToPreviousQuiz() {
    if (_currentQuizSession?.hasPrevious ?? false) {
      _currentQuizSession = _currentQuizSession!.copyWith(
        currentQuizIndex: _currentQuizSession!.currentQuizIndex - 1,
      );
      notifyListeners();
    }
  }

  /// 특정 퀴즈로 이동
  ///
  /// [index]: 이동할 퀴즈 인덱스
  void moveToQuiz(int index) {
    if (_currentQuizSession == null ||
        index < 0 ||
        index >= _currentQuizSession!.totalCount)
      return;

    _currentQuizSession = _currentQuizSession!.copyWith(
      currentQuizIndex: index,
    );
    notifyListeners();
  }

  /// 퀴즈 완료
  ///
  /// Returns: QuizResult?
  Future<QuizResult?> completeQuiz() async {
    if (_currentQuizSession == null) return null;

    _isLoadingQuiz = true;
    _quizError = null;
    notifyListeners();

    try {
      final timeSpent =
          _currentQuizSession!.timeLimit != null
              ? _currentQuizSession!.timeLimit! - _remainingSeconds
              : 0;

      QuizResult result;
      if (_useMock) {
        result = await _mockRepository!.completeQuiz(
          _currentQuizSession!.chapterId,
          _currentQuizSession!.quizzes,
          _currentQuizSession!.userAnswers,
          timeSpent,
        );
      } else {
        result = await _repository!.completeQuiz(
          _currentQuizSession!.chapterId,
          timeSpent,
        );
      }

      // 결과 목록에 추가
      _quizResults.insert(0, result);

      // 세션 정리
      _stopTimer();
      _currentQuizSession = null;

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

        // 진행 중인 세션이 있고 시간 제한이 있다면 타이머 재시작
        if (_currentQuizSession?.timeLimit != null) {
          final elapsed =
              DateTime.now()
                  .difference(_currentQuizSession!.startedAt)
                  .inSeconds;
          final remaining = _currentQuizSession!.timeLimit! - elapsed;
          if (remaining > 0) {
            _startTimer(remaining);
          }
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
