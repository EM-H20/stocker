import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/config/app_routes.dart';
import '../../../app/config/app_theme.dart';
import '../../../app/core/widgets/action_button.dart';
import 'quiz_provider.dart';
import 'widgets/quiz_progress_widget.dart';
import 'widgets/quiz_question_widget.dart';
import 'widgets/quiz_option_widget.dart';
import 'widgets/quiz_explanation_widget.dart';
import 'widgets/quiz_navigation_widget.dart';
import 'widgets/quiz_error_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.chapterId});

  final int chapterId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedAnswer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 빌드 완료 후 다음 프레임에서 퀴즈 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() => _startQuiz());
    });
  }

  /// 퀴즈를 바로 시작
  Future<void> _startQuiz() async {
    final quizProvider = context.read<QuizProvider>();

    try {
      await quizProvider.startQuiz(widget.chapterId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('퀴즈 시작 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingQuiz) {
            return _buildLoadingState();
          }

          if (provider.quizError != null) {
            return QuizErrorWidget(
              title: '퀴즈 로드 실패',
              errorMessage: provider.quizError!,
              onRetry: _startQuiz,
            );
          }

          final session = provider.currentQuizSession;
          if (session == null) {
            return _buildEmptyState();
          }

          return _buildQuizContent(context, provider, session);
        },
      ),
    );
  }

  /// AppBar 빌드
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDarkMode ? Colors.white : AppTheme.grey900,
        ),
        onPressed: () => context.go(AppRoutes.education),
      ),
      title: Text(
        '퀴즈',
        style: TextStyle(
          color: isDarkMode ? Colors.white : AppTheme.grey900,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 로딩 상태 위젯
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.successColor),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text(
        '퀴즈 세션을 찾을 수 없습니다.',
        style: TextStyle(
          color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
        ),
      ),
    );
  }

  /// 퀴즈 콘텐츠 빌드
  Widget _buildQuizContent(
    BuildContext context,
    QuizProvider provider,
    session,
  ) {
    final currentQuiz = session.currentQuiz;

    return Column(
      children: [
        // 진행률 표시
        QuizProgressWidget(
          currentIndex: session.currentQuizIndex,
          totalCount: session.totalCount,
          progressRatio: provider.progressRatio,
        ),

        // 퀴즈 내용
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 문제
                QuizQuestionWidget(question: currentQuiz.question),
                SizedBox(height: 24.h),

                // 선택지들
                ...currentQuiz.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = _selectedAnswer == index;
                  final userAnswer =
                      session.userAnswers[session.currentQuizIndex];
                  final hasAnswered = userAnswer != null;

                  return QuizOptionWidget(
                    option: option,
                    index: index,
                    isSelected: isSelected,
                    hasAnswered: hasAnswered,
                    userAnswer: userAnswer,
                    correctAnswerIndex: currentQuiz.correctAnswerIndex,
                    onTap: hasAnswered
                        ? null
                        : () {
                            setState(() {
                              _selectedAnswer = index;
                            });
                          },
                  );
                }),

                // 해설 (답변 후 표시)
                if (session.userAnswers[session.currentQuizIndex] != null) ...[
                  SizedBox(height: 24.h),
                  QuizExplanationWidget(explanation: currentQuiz.explanation),
                ],
              ],
            ),
          ),
        ),

        // 하단 네비게이션
        QuizNavigationWidget(
          showPrevious: session.currentQuizIndex > 0,
          onPrevious: () {
            provider.moveToPreviousQuiz();
            setState(() {
              _selectedAnswer =
                  session.userAnswers[session.currentQuizIndex - 1];
            });
          },
          actionButton: _buildActionButton(provider, session),
        ),
      ],
    );
  }

  /// 액션 버튼 빌드
  Widget _buildActionButton(QuizProvider provider, session) {
    final hasAnswered = session.userAnswers[session.currentQuizIndex] != null;
    final isLastQuiz = session.currentQuizIndex == session.totalCount - 1;

    if (!hasAnswered) {
      // 답안 제출 버튼
      final canSubmit = _selectedAnswer != null &&
          !_isSubmitting &&
          !provider.isSubmittingAnswer;
      return ActionButton(
        text:
            _isSubmitting || provider.isSubmittingAnswer ? '제출 중...' : '답안 제출',
        icon: _isSubmitting || provider.isSubmittingAnswer
            ? Icons.hourglass_empty
            : Icons.send,
        color: canSubmit ? AppTheme.successColor : Colors.grey,
        onPressed: canSubmit ? () => _submitAnswer(provider) : () {},
      );
    } else if (!isLastQuiz) {
      // 다음 문제 버튼
      return ActionButton(
        text: '다음 문제',
        icon: Icons.arrow_forward,
        color: AppTheme.successColor,
        onPressed: () {
          provider.moveToNextQuiz();
          setState(() {
            _selectedAnswer = session.userAnswers[session.currentQuizIndex + 1];
          });
        },
      );
    } else {
      // 퀴즈 완료 버튼
      return ActionButton(
        text: '퀴즈 완료',
        icon: Icons.check_circle,
        color: AppTheme.successColor,
        onPressed: () => _completeQuiz(provider),
      );
    }
  }

  Future<void> _submitAnswer(QuizProvider provider) async {
    if (_selectedAnswer == null || _isSubmitting || provider.isSubmittingAnswer) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await provider.submitAnswer(_selectedAnswer!);
      if (success) {
        // 답안 제출 성공
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('답안 제출에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _completeQuiz(QuizProvider provider) async {
    final result = await provider.completeQuiz();

    if (result != null && mounted) {
      // 퀴즈 결과 화면으로 이동
      context.go('${AppRoutes.quizResult}?chapterId=${widget.chapterId}');
    }
  }
}
