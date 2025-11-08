import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/quiz_session.dart';
import '../../domain/models/quiz_result.dart';

part 'quiz_state.freezed.dart';

/// 🔥 Riverpod 퀴즈 상태 클래스 (Freezed)
@freezed
class QuizState with _$QuizState {
  const factory QuizState({
    /// 현재 퀴즈 세션
    QuizSession? currentQuizSession,

    /// 퀴즈 결과 목록
    @Default([]) List<QuizResult> quizResults,

    /// 퀴즈 로딩 중
    @Default(false) bool isLoadingQuiz,

    /// 답안 제출 중
    @Default(false) bool isSubmittingAnswer,

    /// 퀴즈 결과 로딩 중
    @Default(false) bool isLoadingResults,

    /// 읽기 전용 모드 (오답노트 복습용)
    @Default(false) bool isReadOnlyMode,

    /// 타이머 실행 중
    @Default(false) bool isTimerRunning,

    /// 남은 시간 (초)
    @Default(0) int remainingSeconds,

    /// 퀴즈 에러 메시지
    String? quizError,

    /// 퀴즈 결과 에러 메시지
    String? resultsError,
  }) = _QuizState;

  const QuizState._();

  // === Computed Getters (Helper Methods) ===

  /// 현재 퀴즈 정보
  get currentQuiz => currentQuizSession?.currentQuiz;

  /// 전체 퀴즈 개수
  int get totalQuizCount => currentQuizSession?.totalCount ?? 0;

  /// 현재 퀴즈 인덱스
  int get currentQuizIndex => currentQuizSession?.currentQuizIndex ?? 0;

  /// 다음 퀴즈가 있는지
  bool get hasNextQuiz => currentQuizSession?.hasNext ?? false;

  /// 이전 퀴즈가 있는지
  bool get hasPreviousQuiz => currentQuizSession?.hasPrevious ?? false;

  /// 현재 진행률 (0.0 ~ 1.0)
  double get progressRatio => currentQuizSession?.progressRatio ?? 0.0;

  /// 답변한 퀴즈 개수
  int get answeredCount => currentQuizSession?.answeredCount ?? 0;

  /// 모든 퀴즈에 답했는지
  bool get isAllAnswered => currentQuizSession?.isAllAnswered ?? false;

  /// 남은 시간 포맷 (MM:SS)
  String get formattedRemainingTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
