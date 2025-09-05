import 'models/wrong_note_request.dart';
import 'models/wrong_note_response.dart';

/// 오답노트 Mock Repository
/// 더미 데이터를 사용하여 오답노트 기능을 시뮬레이션합니다.
class WrongNoteMockRepository {
  // 더미 오답노트 데이터 (새로운 백엔드 구조 사용)
  final List<WrongNoteItem> _mockWrongNotes = [
    WrongNoteItem(
      id: 1,
      quizId: 101,
      chapterId: 1,
      userId: 1,
      selectedOption: 1, // 사용자가 선택한 옵션 (1번 선택)
      createdDate: DateTime.now().subtract(const Duration(days: 2)),
      // UI 표시용 추가 정보
      chapterTitle: '주식 기초 이론',
      question: '주식의 기본 개념에서 주주가 갖는 권리가 아닌 것은?',
      options: ['의결권', '배당수익권', '잔여재산분배권', '채권자 우선변제권'],
      explanation:
          '주주는 기업의 소유자로서 의결권, 배당수익권, 잔여재산분배권을 가지지만, 채권자 우선변제권은 채권자의 권리입니다.',
    ),
    WrongNoteItem(
      id: 2,
      quizId: 201,
      chapterId: 2,
      userId: 1,
      selectedOption: 4, // 사용자가 선택한 옵션 (4번 선택)
      createdDate: DateTime.now().subtract(const Duration(days: 1)),
      // UI 표시용 추가 정보
      chapterTitle: '기술적 분석',
      question: 'RSI 지표에서 과매수 구간으로 판단하는 수치는?',
      options: ['50 이상', '60 이상', '70 이상', '80 이상'],
      explanation: 'RSI는 일반적으로 70 이상을 과매수, 30 이하를 과매도 구간으로 판단합니다.',
    ),
    WrongNoteItem(
      id: 3,
      quizId: 301,
      chapterId: 3,
      userId: 1,
      selectedOption: 1, // 사용자가 선택한 옵션 (1번 선택)
      createdDate: DateTime.now(),
      // UI 표시용 추가 정보
      chapterTitle: '기업 분석',
      question: 'PER(주가수익비율)이 낮다는 것은 무엇을 의미하는가?',
      options: ['주가가 비싸다', '주가가 저평가되어 있다', '수익성이 낮다', '위험도가 높다'],
      explanation: 'PER이 낮다는 것은 주가가 기업의 수익 대비 저평가되어 있음을 의미합니다.',
    ),
  ];

  // 재시도한 퀴즈 ID들을 추적 (isRetried 대체)
  final Set<int> _retriedQuizIds = {201}; // 201번 퀴즈는 재시도 완료로 설정

  /// 사용자의 오답노트 목록 조회
  Future<WrongNoteResponse> getWrongNotes(String userId) async {
    // 실제 API 호출을 시뮬레이션하기 위한 지연
    await Future.delayed(const Duration(milliseconds: 500));

    return WrongNoteResponse(wrongNotes: List.from(_mockWrongNotes));
  }

  /// 퀴즈 결과를 제출하여 오답노트 업데이트
  Future<void> submitQuizResults(WrongNoteRequest request) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 틀린 문제들을 오답노트에 추가하는 로직 시뮬레이션
    for (final result in request.results) {
      if (!result.isCorrect) {
        // 실제로는 서버에서 퀴즈 정보를 가져와서 오답노트에 추가
        // 여기서는 더미 데이터로 시뮬레이션
        final newWrongNote = WrongNoteItem(
          id: _mockWrongNotes.length + 1,
          quizId: result.quizId,
          chapterId: request.chapterId,
          userId: 1, // Mock 사용자 ID
          selectedOption: 1, // TODO: QuizResult에서 선택된 답안 정보 가져오기
          createdDate: DateTime.now(),
          // UI 표시용 추가 정보
          chapterTitle: '챕터 ${request.chapterId}',
          question: '새로운 틀린 문제 ${result.quizId}',
          options: ['옵션1', '옵션2', '옵션3', '옵션4'],
          explanation: '문제 해설입니다.',
        );
        _mockWrongNotes.add(newWrongNote);
      }
    }
  }

  /// 특정 오답 문제 재시도 표시
  Future<void> markAsRetried(String userId, int quizId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // 재시도 퀴즈 ID를 Set에 추가
    _retriedQuizIds.add(quizId);
  }

  /// 오답노트에서 문제 삭제 (정답 처리 시)
  Future<void> removeWrongNote(String userId, int quizId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _mockWrongNotes.removeWhere((item) => item.quizId == quizId);
    // 재시도 상태에서도 제거
    _retriedQuizIds.remove(quizId);
  }

  /// 특정 퀴즈가 재시도되었는지 확인
  bool isQuizRetried(int quizId) {
    return _retriedQuizIds.contains(quizId);
  }

  /// 모든 재시도된 퀴즈 ID 목록 가져오기
  Set<int> get retriedQuizIds => Set.from(_retriedQuizIds);
}
