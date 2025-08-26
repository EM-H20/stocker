import 'models/quiz_info.dart';
import 'models/quiz_session.dart';
import 'models/quiz_result.dart';

/// 퀴즈 Mock Repository
/// UI 개발 및 테스트를 위한 더미 데이터 제공
class QuizMockRepository {
  // Mock API 지연 시간 시뮬레이션
  static const Duration _mockDelay = Duration(milliseconds: 500);

  /// 더미 퀴즈 세션 시작
  ///
  /// UI 개발을 위한 샘플 퀴즈 데이터 제공
  /// Returns: QuizSession
  Future<QuizSession> startQuiz(int chapterId) async {
    await Future.delayed(_mockDelay);

    final quizzes = _generateMockQuizzes(chapterId);
    final userAnswers = List<int?>.filled(quizzes.length, null);

    return QuizSession(
      chapterId: chapterId,
      chapterTitle: '챕터 $chapterId 퀴즈',
      quizzes: quizzes,
      currentQuizIndex: 0,
      userAnswers: userAnswers,
      timeLimit: 600, // 10분
      startedAt: DateTime.now(),
    );
  }

  /// 더미 퀴즈 답안 제출
  ///
  /// 퀴즈 답안 제출 시뮬레이션
  Future<void> submitAnswer(
    int chapterId,
    int quizIndex,
    int selectedAnswer,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock에서는 별도 처리 없음 (로컬 상태로 관리)
  }

  /// 더미 퀴즈 완료 처리
  ///
  /// 퀴즈 완료 및 결과 저장 시뮬레이션
  /// Returns: QuizResult
  Future<QuizResult> completeQuiz(
    int chapterId,
    List<QuizInfo> quizzes,
    List<int?> userAnswers,
    int timeSpentSeconds,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 정답 개수 계산
    int correctCount = 0;
    for (int i = 0; i < quizzes.length && i < userAnswers.length; i++) {
      if (userAnswers[i] != null &&
          userAnswers[i] == quizzes[i].correctAnswerIndex) {
        correctCount++;
      }
    }

    final totalQuestions = quizzes.length;
    final wrongAnswers = totalQuestions - correctCount;
    final scorePercentage = ((correctCount / totalQuestions) * 100).round();
    final grade = QuizResult.calculateGrade(scorePercentage);
    final isPassed = QuizResult.calculatePassed(scorePercentage);

    return QuizResult(
      chapterId: chapterId,
      chapterTitle: '챕터 $chapterId',
      totalQuestions: totalQuestions,
      correctAnswers: correctCount,
      wrongAnswers: wrongAnswers,
      scorePercentage: scorePercentage,
      grade: grade,
      isPassed: isPassed,
      timeSpentSeconds: timeSpentSeconds,
      completedAt: DateTime.now(),
    );
  }

  /// 더미 퀴즈 결과 조회
  ///
  /// 이전 퀴즈 결과 조회 시뮬레이션
  /// Returns: List QuizResult
  Future<List<QuizResult>> getQuizResults(int chapterId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 더미 이전 결과들 생성
    final results = <QuizResult>[];
    final now = DateTime.now();

    for (int i = 0; i < 3; i++) {
      final score = 70 + (i * 10) + (DateTime.now().millisecond % 20);
      results.add(
        QuizResult(
          chapterId: chapterId,
          chapterTitle: '챕터 $chapterId',
          totalQuestions: 5,
          correctAnswers: (score * 5 / 100).round(),
          wrongAnswers: 5 - (score * 5 / 100).round(),
          scorePercentage: score,
          grade: QuizResult.calculateGrade(score),
          isPassed: QuizResult.calculatePassed(score),
          timeSpentSeconds: 300 + (i * 60),
          completedAt: now.subtract(Duration(days: i + 1)),
        ),
      );
    }

    return results;
  }

  /// 더미 현재 진행 중인 퀴즈 조회
  ///
  /// 진행 중인 퀴즈 세션 정보 제공
  /// Returns: QuizSession? (null이면 진행 중인 퀴즈 없음)
  Future<QuizSession?> getCurrentQuizSession() async {
    await Future.delayed(const Duration(milliseconds: 200));

    // 30% 확률로 진행 중인 세션 반환 (테스트용)
    if (DateTime.now().millisecondsSinceEpoch % 3 == 0) {
      final quizzes = _generateMockQuizzes(1);
      final userAnswers = List<int?>.filled(quizzes.length, null);
      userAnswers[0] = 1; // 첫 번째 문제는 답변 완료

      return QuizSession(
        chapterId: 1,
        chapterTitle: '진행 중인 퀴즈',
        quizzes: quizzes,
        currentQuizIndex: 1,
        userAnswers: userAnswers,
        timeLimit: 600,
        startedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      );
    }

    return null; // 진행 중인 세션 없음
  }

  /// 챕터별 더미 퀴즈 데이터 생성
  List<QuizInfo> _generateMockQuizzes(int chapterId) {
    switch (chapterId) {
      case 1:
        return [
          const QuizInfo(
            id: 1,
            question: '주식이란 무엇인가요?',
            options: [
              '기업의 부채를 나타내는 증권',
              '기업의 소유권을 나타내는 증권',
              '정부에서 발행하는 채권',
              '은행에서 제공하는 예금상품',
            ],
            correctAnswerIndex: 1,
            explanation:
                '주식은 기업의 소유권을 나타내는 증권입니다. 주식을 보유하면 해당 기업의 일부를 소유하게 됩니다.',
          ),
          const QuizInfo(
            id: 2,
            question: '보통주와 우선주의 차이점은?',
            options: [
              '보통주는 의결권이 있고, 우선주는 배당 우선권이 있다',
              '보통주는 배당 우선권이 있고, 우선주는 의결권이 있다',
              '둘 다 동일한 권리를 갖는다',
              '보통주만 거래가 가능하다',
            ],
            correctAnswerIndex: 0,
            explanation: '보통주는 의결권을 가지며, 우선주는 배당금 지급에서 우선권을 갖습니다.',
          ),
          const QuizInfo(
            id: 3,
            question: '주식 투자의 주요 수익원은?',
            options: ['이자 수익만', '배당 수익만', '자본 이득만', '배당 수익과 자본 이득'],
            correctAnswerIndex: 3,
            explanation: '주식 투자의 수익원은 배당 수익(배당금)과 자본 이득(주가 상승)입니다.',
          ),
          const QuizInfo(
            id: 4,
            question: 'PER이 높다는 것은 무엇을 의미하나요?',
            options: [
              '주식이 저평가되어 있다',
              '주식이 고평가되어 있을 가능성이 있다',
              '회사의 부채가 많다',
              '배당금이 높다',
            ],
            correctAnswerIndex: 1,
            explanation:
                'PER이 높다는 것은 주가가 수익에 비해 높게 형성되어 있어 고평가되어 있을 가능성을 의미합니다.',
          ),
          const QuizInfo(
            id: 5,
            question: '분산투자의 주요 목적은?',
            options: [
              '수익률을 극대화하기 위해',
              '리스크를 줄이기 위해',
              '거래비용을 줄이기 위해',
              '세금을 절약하기 위해',
            ],
            correctAnswerIndex: 1,
            explanation: '분산투자의 주요 목적은 포트폴리오의 리스크를 줄이는 것입니다.',
          ),
        ];

      case 2:
        return [
          const QuizInfo(
            id: 6,
            question: '재무제표의 3대 구성요소는?',
            options: [
              '손익계산서, 현금흐름표, 자본변동표',
              '대차대조표, 손익계산서, 현금흐름표',
              '대차대조표, 손익계산서, 자본변동표',
              '손익계산서, 현금흐름표, 주석',
            ],
            correctAnswerIndex: 1,
            explanation: '재무제표의 3대 구성요소는 대차대조표, 손익계산서, 현금흐름표입니다.',
          ),
          const QuizInfo(
            id: 7,
            question: 'ROE(자기자본이익률)는 무엇을 나타내나요?',
            options: ['총자산 대비 수익률', '매출 대비 수익률', '자기자본 대비 수익률', '부채 대비 수익률'],
            correctAnswerIndex: 2,
            explanation: 'ROE는 자기자본 대비 순이익의 비율로, 주주 투자 대비 수익률을 나타냅니다.',
          ),
          const QuizInfo(
            id: 8,
            question: '유동비율이 높다는 것은?',
            options: ['단기 지급능력이 좋다', '장기 지급능력이 좋다', '수익성이 좋다', '성장성이 좋다'],
            correctAnswerIndex: 0,
            explanation: '유동비율은 유동자산을 유동부채로 나눈 비율로, 단기 지급능력을 나타냅니다.',
          ),
        ];

      default:
        return [
          const QuizInfo(
            id: 99,
            question: '기본 퀴즈 문제입니다.',
            options: ['선택지 1', '선택지 2', '선택지 3', '선택지 4'],
            correctAnswerIndex: 0,
            explanation: '기본 설명입니다.',
          ),
        ];
    }
  }
}
