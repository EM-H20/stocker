import 'models/quiz_info.dart';
import 'models/quiz_session.dart';
import 'models/quiz_result.dart';

/// 퀴즈 Mock Repository
/// UI 개발 및 테스트를 위한 더미 데이터 제공
class QuizMockRepository {
  // Mock API 지연 시간 시뮬레이션
  static const Duration _mockDelay = Duration(milliseconds: 500);

  /// 퀴즈 진입 (API.md 스펙 준수)
  ///
  /// UI 개발을 위한 샘플 퀴즈 데이터 제공
  /// Returns: QuizSession
  Future<QuizSession> enterQuiz(int chapterId) async {
    await Future.delayed(_mockDelay);

    final quizList = _generateMockQuizzes(chapterId);
    final userAnswers = List<int?>.filled(quizList.length, null);

    return QuizSession(
      chapterId: chapterId,
      quizList: quizList,
      currentQuizId: quizList.isNotEmpty ? quizList.first.id : 1,
      userAnswers: userAnswers,
      startedAt: DateTime.now(),
    );
  }

  /// 퀴즈 진도 업데이트 (API.md 스펙 준수)
  ///
  /// 퀴즈 진행 상황 업데이트 시뮬레이션
  Future<void> updateQuizProgress(
    int chapterId,
    int currentQuizId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock에서는 별도 처리 없음 (로컬 상태로 관리)
  }

  /// 퀴즈 완료 처리 (API.md 스펙 준수)
  ///
  /// 퀴즈 완료 및 결과 저장 시뮬레이션
  /// Returns: QuizResult
  Future<QuizResult> completeQuiz(
    int chapterId,
    List<Map<String, int>> answers,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 더미 퀴즈 데이터 생성
    final quizList = _generateMockQuizzes(chapterId);

    // 정답 개수 계산 (answers 기반)
    int correctCount = 0;
    for (final answer in answers) {
      final quizId = answer['quiz_id']!;
      final selectedAnswer = answer['selected_option']!; // 올바른 키 사용
      final quiz = quizList.firstWhere((q) => q.id == quizId,
          orElse: () => quizList.first);
      if (selectedAnswer == quiz.correctAnswerIndex + 1) {
        // API에서는 1-based
        correctCount++;
      }
    }

    final totalQuestions = answers.length;
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
      timeSpentSeconds: 300 + (correctCount * 30), // Mock: 기본 300초 + 정답당 30초
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

  /// 현재 진행 중인 퀴즈 세션 조회 (로컬 전용)
  ///
  /// Mock에서는 사용하지 않음 (Repository에서 로컬 저장소만 사용)
  /// Returns: null (Mock에서는 항상 null 반환)
  Future<QuizSession?> getCurrentQuizSession() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return null; // Mock에서는 로컬 저장소만 사용
  }

  /// 챕터별 더미 퀴즈 데이터 생성
  List<QuizInfo> _generateMockQuizzes(int chapterId) {
    switch (chapterId) {
      case 1:
        return [
          const QuizInfo(
            id: 1,
            chapterId: 1, // 백엔드 호환성을 위해 추가
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
            chapterId: 1,
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
            chapterId: 1,
            question: '주식 투자의 주요 수익원은?',
            options: ['이자 수익만', '배당 수익만', '자본 이득만', '배당 수익과 자본 이득'],
            correctAnswerIndex: 3,
            explanation: '주식 투자의 수익원은 배당 수익(배당금)과 자본 이득(주가 상승)입니다.',
          ),
          const QuizInfo(
            id: 4,
            chapterId: 1,
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
            chapterId: 1,
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
            chapterId: 2,
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
            chapterId: 2,
            question: 'ROE(자기자본이익률)는 무엇을 나타내나요?',
            options: ['총자산 대비 수익률', '매출 대비 수익률', '자기자본 대비 수익률', '부채 대비 수익률'],
            correctAnswerIndex: 2,
            explanation: 'ROE는 자기자본 대비 순이익의 비율로, 주주 투자 대비 수익률을 나타냅니다.',
          ),
          const QuizInfo(
            id: 8,
            chapterId: 2,
            question: '유동비율이 높다는 것은?',
            options: ['단기 지급능력이 좋다', '장기 지급능력이 좋다', '수익성이 좋다', '성장성이 좋다'],
            correctAnswerIndex: 0,
            explanation: '유동비율은 유동자산을 유동부채로 나눈 비율로, 단기 지급능력을 나타냅니다.',
          ),
        ];

      default:
        return [
          QuizInfo(
            id: 99,
            chapterId: chapterId,
            question: '기본 퀴즈 문제입니다.',
            options: ['선택지 1', '선택지 2', '선택지 3', '선택지 4'],
            correctAnswerIndex: 0,
            explanation: '기본 설명입니다.',
          ),
        ];
    }
  }
}
