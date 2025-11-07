import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/config/app_routes.dart';
import '../../../app/config/app_theme.dart';
import '../../../app/core/utils/theme_utils.dart';
import '../../../app/core/widgets/action_button.dart';
import 'quiz_provider.dart';
import 'widgets/quiz_progress_widget.dart';
import 'widgets/quiz_question_widget.dart';
import 'widgets/quiz_option_widget.dart';
import 'widgets/quiz_explanation_widget.dart';
import 'widgets/quiz_navigation_widget.dart';
import 'widgets/quiz_error_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.chapterId, this.singleQuizId, this.isReadOnly = false});

  final int chapterId;
  final int? singleQuizId; // 단일 퀴즈 모드용 quiz ID
  final bool isReadOnly; // 읽기 전용 모드 (오답노트 복습용)

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedAnswer;
  bool _isSubmitting = false;
  bool _waitingForWrongNoteRemoval = false; // 오답 삭제 대기 상태

  @override
  void initState() {
    super.initState();
    
    // 단일 퀴즈 모드일 때 오답 삭제 완료 콜백 등록
    if (widget.singleQuizId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final quizProvider = context.read<QuizProvider>();
        quizProvider.addOnWrongNoteRemovedCallback(_onWrongNoteRemoved);
      });
    }
    
    // 빌드 완료 후 다음 프레임에서 퀴즈 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() => _startQuiz());
    });
  }

  /// 퀴즈를 바로 시작 (단일 퀴즈 모드 및 읽기 전용 모드 지원)
  Future<void> _startQuiz() async {
    final quizProvider = context.read<QuizProvider>();

    try {
      if (widget.singleQuizId != null) {
        // 단일 퀴즈 모드
        debugPrint('🧠 [QUIZ_SCREEN] 단일 퀴즈 진입 - 챕터: ${widget.chapterId}, 퀴즈: ${widget.singleQuizId}, 읽기전용: ${widget.isReadOnly}');
        await quizProvider.startSingleQuiz(widget.chapterId, widget.singleQuizId!, isReadOnly: widget.isReadOnly);
      } else {
        // 일반 퀴즈 모드
        debugPrint('🧠 [QUIZ_SCREEN] 일반 퀴즈 진입 - 챕터 ID: ${widget.chapterId}');
        await quizProvider.startQuiz(widget.chapterId);
      }
    } catch (e) {
      debugPrint('❌ [QUIZ_SCREEN] 퀴즈 시작 실패 - 챕터: ${widget.chapterId}, 에러: $e');
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
  void dispose() {
    // 단일 퀴즈 모드일 때 콜백 해제
    if (widget.singleQuizId != null && mounted) {
      try {
        final quizProvider = context.read<QuizProvider>();
        quizProvider.removeOnWrongNoteRemovedCallback(_onWrongNoteRemoved);
      } catch (e) {
        // dispose 중 에러는 무시
      }
    }
    super.dispose();
  }

  /// 오답노트 삭제 완료 콜백
  void _onWrongNoteRemoved(int quizId) {
    if (widget.singleQuizId == quizId && mounted) {
      debugPrint('🎯 [QUIZ_SCREEN] 오답노트 삭제 완료 알림 수신 - Quiz $quizId, 오답노트로 이동');
      _waitingForWrongNoteRemoval = false;
      context.go(AppRoutes.wrongNote);
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
    final isDarkMode = ThemeUtils.isDarkMode(context);

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
    final isDarkMode = ThemeUtils.isDarkMode(context);

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
        text: _waitingForWrongNoteRemoval ? '처리 중...' : '퀴즈 완료',
        icon: _waitingForWrongNoteRemoval ? Icons.hourglass_empty : Icons.check_circle,
        color: _waitingForWrongNoteRemoval ? Colors.grey : AppTheme.successColor,
        onPressed: _waitingForWrongNoteRemoval ? () {} : () => _completeQuiz(provider),
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
      if (widget.singleQuizId != null) {
        // 🎯 단일 퀴즈 모드
        final session = provider.currentQuizSession;
        if (session != null && session.quizList.isNotEmpty) {
          final quiz = session.quizList.first;
          final userAnswer = session.userAnswers.first;
          final isCorrect = userAnswer == quiz.correctAnswerIndex;

          // 🚨 ReadOnly 모드 완료 처리 (무한루프 방지!)
          if (provider.isReadOnlyMode) {
            debugPrint('📖 [QUIZ_SCREEN] ReadOnly 퀴즈 완료 - 복습 모드 종료');

            // 🕐 잠깐 대기 후 오답노트로 이동 (자동 퀴즈 시작 방지)
            await Future.delayed(const Duration(milliseconds: 500));

            // 🛡️ ReadOnly 모드 해제 후 안전하게 오답노트로 이동
            provider.exitReadOnlyMode();
            debugPrint('🛡️ [QUIZ_SCREEN] ReadOnly 모드 해제 완료, 오답노트로 안전 이동');

            if (mounted) {
              context.go(AppRoutes.wrongNote);
            }
            return; // 🚨 여기서 완전 종료! 추가 로직 실행 방지
          }

          // 🔄 일반 모드: 기존 로직 유지
          if (isCorrect) {
            // 정답: 오답 삭제 완료를 기다림 (콜백에서 처리)
            setState(() {
              _waitingForWrongNoteRemoval = true;
            });
            debugPrint('🎯 [QUIZ_SCREEN] 단일 퀴즈 정답 완료, 오답 삭제 대기 중...');
          } else {
            // 오답: 바로 오답노트로 이동
            debugPrint('🎯 [QUIZ_SCREEN] 단일 퀴즈 오답 완료, 바로 오답노트로 이동');
            context.go(AppRoutes.wrongNote);
          }
        } else {
          // 세션 정보 없으면 바로 이동
          context.go(AppRoutes.wrongNote);
        }
      } else {
        // 일반 퀴즈 모드: 퀴즈 결과 화면으로 이동
        context.go('${AppRoutes.quizResult}?chapterId=${widget.chapterId}');
      }
    }
  }
}
