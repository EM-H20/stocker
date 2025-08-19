import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/config/app_routes.dart';
import '../../../app/core/widgets/action_button.dart';
import 'quiz_provider.dart';

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
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRoutes.education),
        ),
        title: Text(
          '퀴즈',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // 타이머 표시
          Consumer<QuizProvider>(
            builder: (context, provider, child) {
              if (provider.isTimerRunning) {
                return Container(
                  margin: EdgeInsets.only(right: 16.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Text(
                    provider.formattedRemainingTime,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingQuiz) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            );
          }

          if (provider.quizError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 64.sp),
                  SizedBox(height: 16.h),
                  Text(
                    '퀴즈 로드 실패',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    provider.quizError!,
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ActionButton(
                    text: '다시 시도',
                    icon: Icons.refresh,
                    color: const Color(0xFF4CAF50),
                    onPressed: () => _startQuiz(),
                  ),
                ],
              ),
            );
          }

          final session = provider.currentQuizSession;
          if (session == null) {
            return const Center(
              child: Text(
                '퀴즈 세션을 찾을 수 없습니다.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final currentQuiz = session.currentQuiz;
          return Column(
            children: [
              // 진행률 표시
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                color: const Color(0xFF2A2A2A),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '문제 ${session.currentQuizIndex + 1} / ${session.totalCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(provider.progressRatio * 100).toInt()}% 완료',
                          style: TextStyle(
                            color: const Color(0xFF4CAF50),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    LinearProgressIndicator(
                      value: provider.progressRatio,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),

              // 퀴즈 내용
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 문제
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          currentQuiz.question,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // 선택지들
                      ...currentQuiz.options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        final isSelected = _selectedAnswer == index;
                        final userAnswer =
                            session.userAnswers[session.currentQuizIndex];
                        final hasAnswered = userAnswer != null;

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          child: InkWell(
                            onTap:
                                hasAnswered
                                    ? null
                                    : () {
                                      setState(() {
                                        _selectedAnswer = index;
                                      });
                                    },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color:
                                    hasAnswered
                                        ? (userAnswer == index
                                            ? (userAnswer ==
                                                    currentQuiz
                                                        .correctAnswerIndex
                                                ? Colors.green.withValues(
                                                  alpha: 0.2,
                                                )
                                                : Colors.red.withValues(
                                                  alpha: 0.2,
                                                ))
                                            : (index ==
                                                    currentQuiz
                                                        .correctAnswerIndex
                                                ? Colors.green.withValues(
                                                  alpha: 0.2,
                                                )
                                                : const Color(0xFF2A2A2A)))
                                        : (isSelected
                                            ? const Color(
                                              0xFF4CAF50,
                                            ).withValues(alpha: 0.2)
                                            : const Color(0xFF2A2A2A)),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color:
                                      hasAnswered
                                          ? (userAnswer == index
                                              ? (userAnswer ==
                                                      currentQuiz
                                                          .correctAnswerIndex
                                                  ? Colors.green
                                                  : Colors.red)
                                              : (index ==
                                                      currentQuiz
                                                          .correctAnswerIndex
                                                  ? Colors.green
                                                  : Colors.grey[600]!))
                                          : (isSelected
                                              ? const Color(0xFF4CAF50)
                                              : Colors.grey[600]!),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // 선택 표시 원
                                  Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          hasAnswered
                                              ? (userAnswer == index
                                                  ? (userAnswer ==
                                                          currentQuiz
                                                              .correctAnswerIndex
                                                      ? Colors.green
                                                      : Colors.red)
                                                  : (index ==
                                                          currentQuiz
                                                              .correctAnswerIndex
                                                      ? Colors.green
                                                      : Colors.transparent))
                                              : (isSelected
                                                  ? const Color(0xFF4CAF50)
                                                  : Colors.transparent),
                                      border: Border.all(
                                        color:
                                            hasAnswered
                                                ? (userAnswer == index
                                                    ? (userAnswer ==
                                                            currentQuiz
                                                                .correctAnswerIndex
                                                        ? Colors.green
                                                        : Colors.red)
                                                    : (index ==
                                                            currentQuiz
                                                                .correctAnswerIndex
                                                        ? Colors.green
                                                        : Colors.grey))
                                                : (isSelected
                                                    ? const Color(0xFF4CAF50)
                                                    : Colors.grey),
                                        width: 2,
                                      ),
                                    ),
                                    child:
                                        hasAnswered
                                            ? (userAnswer == index
                                                ? Icon(
                                                  userAnswer ==
                                                          currentQuiz
                                                              .correctAnswerIndex
                                                      ? Icons.check
                                                      : Icons.close,
                                                  color: Colors.white,
                                                  size: 16.sp,
                                                )
                                                : (index ==
                                                        currentQuiz
                                                            .correctAnswerIndex
                                                    ? Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 16.sp,
                                                    )
                                                    : null))
                                            : (isSelected
                                                ? Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16.sp,
                                                )
                                                : null),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      // 해설 (답변 후 표시)
                      if (session.userAnswers[session.currentQuizIndex] !=
                          null) ...[
                        SizedBox(height: 24.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: const Color(0xFF4CAF50),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: const Color(0xFF4CAF50),
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '해설',
                                    style: TextStyle(
                                      color: const Color(0xFF4CAF50),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                currentQuiz.explanation,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14.sp,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // 하단 버튼들
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    // 이전 버튼
                    if (session.currentQuizIndex > 0)
                      Expanded(
                        child: ActionButton(
                          text: '이전',
                          icon: Icons.arrow_back,
                          color: Colors.grey[700]!,
                          onPressed: () {
                            provider.moveToPreviousQuiz();
                            setState(() {
                              _selectedAnswer =
                                  session.userAnswers[session.currentQuizIndex -
                                      1];
                            });
                          },
                        ),
                      ),

                    if (session.currentQuizIndex > 0) SizedBox(width: 12.w),

                    // 답안 제출/다음/완료 버튼
                    Expanded(child: _buildActionButton(provider, session)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton(QuizProvider provider, session) {
    final hasAnswered = session.userAnswers[session.currentQuizIndex] != null;
    final isLastQuiz = session.currentQuizIndex == session.totalCount - 1;

    if (!hasAnswered) {
      // 답안 제출 버튼
      final canSubmit = _selectedAnswer != null && !_isSubmitting && !provider.isSubmittingAnswer;
      return ActionButton(
        text: _isSubmitting || provider.isSubmittingAnswer ? '제출 중...' : '답안 제출',
        icon: _isSubmitting || provider.isSubmittingAnswer ? Icons.hourglass_empty : Icons.send,
        color: canSubmit ? const Color(0xFF4CAF50) : Colors.grey,
        onPressed: canSubmit ? () => _submitAnswer(provider) : () {},
      );
    } else if (!isLastQuiz) {
      // 다음 문제 버튼
      return ActionButton(
        text: '다음 문제',
        icon: Icons.arrow_forward,
        color: const Color(0xFF4CAF50),
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
        color: const Color(0xFF4CAF50),
        onPressed: () => _completeQuiz(provider),
      );
    }
  }

  Future<void> _submitAnswer(QuizProvider provider) async {
    if (_selectedAnswer == null || _isSubmitting || provider.isSubmittingAnswer) return;

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
