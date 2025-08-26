import 'models/wrong_note_request.dart';
import 'models/wrong_note_response.dart';

/// 오답노트 Mock Repository
/// 더미 데이터를 사용하여 오답노트 기능을 시뮬레이션합니다.
class WrongNoteMockRepository {
  // 더미 오답노트 데이터
  final List<WrongNoteItem> _mockWrongNotes = [
    WrongNoteItem(
      id: 1,
      chapterId: 1,
      chapterTitle: '주식 기초 이론',
      quizId: 101,
      question: '주식의 기본 개념에서 주주가 갖는 권리가 아닌 것은?',
      options: ['의결권', '배당수익권', '잔여재산분배권', '채권자 우선변제권'],
      correctAnswer: '채권자 우선변제권',
      userAnswer: '의결권',
      explanation: '주주는 기업의 소유자로서 의결권, 배당수익권, 잔여재산분배권을 가지지만, 채권자 우선변제권은 채권자의 권리입니다.',
      wrongDate: DateTime.now().subtract(const Duration(days: 2)),
      isRetried: false,
    ),
    WrongNoteItem(
      id: 2,
      chapterId: 2,
      chapterTitle: '기술적 분석',
      quizId: 201,
      question: 'RSI 지표에서 과매수 구간으로 판단하는 수치는?',
      options: ['50 이상', '60 이상', '70 이상', '80 이상'],
      correctAnswer: '70 이상',
      userAnswer: '80 이상',
      explanation: 'RSI는 일반적으로 70 이상을 과매수, 30 이하를 과매도 구간으로 판단합니다.',
      wrongDate: DateTime.now().subtract(const Duration(days: 1)),
      isRetried: true,
    ),
    WrongNoteItem(
      id: 3,
      chapterId: 3,
      chapterTitle: '기업 분석',
      quizId: 301,
      question: 'PER(주가수익비율)이 낮다는 것은 무엇을 의미하는가?',
      options: ['주가가 비싸다', '주가가 저평가되어 있다', '수익성이 낮다', '위험도가 높다'],
      correctAnswer: '주가가 저평가되어 있다',
      userAnswer: '주가가 비싸다',
      explanation: 'PER이 낮다는 것은 주가가 기업의 수익 대비 저평가되어 있음을 의미합니다.',
      wrongDate: DateTime.now(),
      isRetried: false,
    ),
  ];

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
          chapterId: request.chapterId,
          chapterTitle: '챕터 ${request.chapterId}',
          quizId: result.quizId,
          question: '새로운 틀린 문제 ${result.quizId}',
          options: ['옵션1', '옵션2', '옵션3', '옵션4'],
          correctAnswer: '정답',
          userAnswer: '사용자 답변',
          explanation: '문제 해설입니다.',
          wrongDate: DateTime.now(),
          isRetried: false,
        );
        _mockWrongNotes.add(newWrongNote);
      }
    }
  }

  /// 특정 오답 문제 재시도 표시
  Future<void> markAsRetried(String userId, int quizId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _mockWrongNotes.indexWhere((item) => item.quizId == quizId);
    if (index != -1) {
      _mockWrongNotes[index] = _mockWrongNotes[index].copyWith(isRetried: true);
    }
  }

  /// 오답노트에서 문제 삭제 (정답 처리 시)
  Future<void> removeWrongNote(String userId, int quizId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _mockWrongNotes.removeWhere((item) => item.quizId == quizId);
  }
}
