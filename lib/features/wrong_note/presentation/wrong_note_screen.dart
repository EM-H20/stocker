import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widgets/wrong_answer_card.dart';
import 'widgets/wrong_note_stats_card.dart';
import 'widgets/wrong_note_filter_tabs.dart';
import 'widgets/wrong_note_empty_state.dart';
import '../../../app/config/app_theme.dart';

/// 오답노트 메인 화면
///
/// 사용자가 틀린 퀴즈 문제들을 모아서 복습할 수 있는 화면입니다.
/// 챕터별로 분류되어 있으며, 다시 풀기 기능을 제공합니다.
class WrongNoteScreen extends StatefulWidget {
  const WrongNoteScreen({super.key});

  @override
  State<WrongNoteScreen> createState() => _WrongNoteScreenState();
}

class _WrongNoteScreenState extends State<WrongNoteScreen> {
  // 현재 선택된 필터 (전체, 챕터별)
  String _selectedFilter = '전체';

  // 더미 오답 데이터 (실제로는 Provider에서 관리)
  final List<WrongAnswerItem> _wrongAnswers = [
    WrongAnswerItem(
      id: 1,
      chapterId: 1,
      chapterTitle: '주식 기초 이론',
      question: '주식의 기본 개념에서 주주가 갖는 권리가 아닌 것은?',
      correctAnswer: '채권자 우선변제권',
      userAnswer: '의결권',
      explanation:
          '주주는 기업의 소유자로서 의결권, 배당수익권, 잔여재산분배권을 가지지만, 채권자 우선변제권은 채권자의 권리입니다.',
      wrongDate: DateTime.now().subtract(const Duration(days: 2)),
      isRetried: false,
    ),
    WrongAnswerItem(
      id: 2,
      chapterId: 2,
      chapterTitle: '기술적 분석',
      question: 'RSI 지표에서 과매수 구간으로 판단하는 수치는?',
      correctAnswer: '70 이상',
      userAnswer: '80 이상',
      explanation: 'RSI는 일반적으로 70 이상을 과매수, 30 이하를 과매도 구간으로 판단합니다.',
      wrongDate: DateTime.now().subtract(const Duration(days: 1)),
      isRetried: true,
    ),
    WrongAnswerItem(
      id: 3,
      chapterId: 1,
      chapterTitle: '주식 기초 이론',
      question: '주식 시장에서 IPO의 의미는?',
      correctAnswer: 'Initial Public Offering',
      userAnswer: 'International Public Offering',
      explanation:
          'IPO는 Initial Public Offering의 약자로, 기업이 처음으로 주식을 공개 발행하는 것을 의미합니다.',
      wrongDate: DateTime.now(),
      isRetried: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 필터링된 오답 목록
    final filteredAnswers =
        _selectedFilter == '전체'
            ? _wrongAnswers
            : _wrongAnswers
                .where((item) => item.chapterTitle.contains(_selectedFilter))
                .toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 커스텀 헤더
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Text(
                    '오답노트',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${_wrongAnswers.length}개',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 상단 통계 카드
            WrongNoteStatsCard(wrongAnswers: _wrongAnswers),

            // 필터 탭
            WrongNoteFilterTabs(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),

            // 오답 목록
            Expanded(
              child:
                  filteredAnswers.isEmpty
                      ? WrongNoteEmptyState(
                        onGoToQuiz: () {
                          // 교육 탭으로 이동
                        },
                      )
                      : _buildWrongAnswersList(filteredAnswers),
            ),
          ],
        ),
      ),
    );
  }

  /// 오답 목록
  Widget _buildWrongAnswersList(List<WrongAnswerItem> answers) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: answers.length,
      itemBuilder: (context, index) {
        final item = answers[index];
        return WrongAnswerCard(item: item, onRetry: () => _retryQuestion(item));
      },
    );
  }

  /// 문제 다시 풀기
  void _retryQuestion(WrongAnswerItem item) {
    // 실제로는 해당 퀴즈 화면으로 이동
    setState(() {
      item.isRetried = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.chapterTitle} 퀴즈로 이동합니다'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}

/// 오답 아이템 모델
class WrongAnswerItem {
  final int id;
  final int chapterId;
  final String chapterTitle;
  final String question;
  final String correctAnswer;
  final String userAnswer;
  final String explanation;
  final DateTime wrongDate;
  bool isRetried;

  WrongAnswerItem({
    required this.id,
    required this.chapterId,
    required this.chapterTitle,
    required this.question,
    required this.correctAnswer,
    required this.userAnswer,
    required this.explanation,
    required this.wrongDate,
    this.isRetried = false,
  });
}
