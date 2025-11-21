import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_routes.dart';
import '../../../app/config/app_theme.dart';
import '../../../app/core/utils/theme_utils.dart';
import '../../../app/core/widgets/action_button.dart';
import 'riverpod/quiz_notifier.dart';
import 'riverpod/quiz_state.dart';
import 'widgets/quiz_progress_widget.dart';
import 'widgets/quiz_question_widget.dart';
import 'widgets/quiz_option_widget.dart';
import 'widgets/quiz_explanation_widget.dart';
import 'widgets/quiz_navigation_widget.dart';
import 'widgets/quiz_error_widget.dart';
import '../../../app/core/widgets/loading_widget.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen(
      {super.key,
      required this.chapterId,
      this.singleQuizId,
      this.isReadOnly = false});

  final int chapterId;
  final int? singleQuizId; // 단일 퀴즈 모드용 quiz ID
  final bool isReadOnly; // 읽기 전용 모드 (오답노트 복습용)

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _selectedAnswer;
  bool _isSubmitting = false;
  bool _waitingForWrongNoteRemoval = false; // 오답 삭제 대기 상태

  @override
  void initState() {
    super.initState();

    // 단일 퀴즈 모드일 때 오답 삭제 완료 콜백 등록
    if (widget.singleQuizId != null) {
      Future.microtask(() {
        final quizNotifier = ref.read(quizNotifierProvider.notifier);
        quizNotifier.addOnWrongNoteRemovedCallback(_onWrongNoteRemoved);
      });
    }

    // 🎯 일반 퀴즈 모드: 시작 전 안내 다이얼로그 표시
    // 단일 퀴즈/ReadOnly 모드: 바로 시작
    if (widget.singleQuizId == null && !widget.isReadOnly) {
      Future.microtask(() => _showQuizStartDialog());
    } else {
      Future.microtask(() => _startQuiz());
    }
  }

  /// 퀴즈를 바로 시작 (단일 퀴즈 모드 및 읽기 전용 모드 지원)
  Future<void> _startQuiz() async {
    final quizNotifier = ref.read(quizNotifierProvider.notifier);

    try {
      if (widget.singleQuizId != null) {
        // 단일 퀴즈 모드
        debugPrint(
            '🧠 [QUIZ_SCREEN] 단일 퀴즈 진입 - 챕터: ${widget.chapterId}, 퀴즈: ${widget.singleQuizId}, 읽기전용: ${widget.isReadOnly}');
        await quizNotifier.startSingleQuiz(widget.singleQuizId!);
      } else {
        // 일반 퀴즈 모드
        debugPrint('🧠 [QUIZ_SCREEN] 일반 퀴즈 진입 - 챕터 ID: ${widget.chapterId}');
        await quizNotifier.startQuiz(widget.chapterId);
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
    if (widget.singleQuizId != null) {
      try {
        final quizNotifier = ref.read(quizNotifierProvider.notifier);
        quizNotifier.removeOnWrongNoteRemovedCallback(_onWrongNoteRemoved);
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

  /// 퀴즈 시작 전 안내 다이얼로그 표시
  Future<void> _showQuizStartDialog() async {
    final isDarkMode = ThemeUtils.isDarkMode(context);

    final shouldStart = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 뒤로가기로 닫기 불가
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.quiz, color: AppTheme.successColor, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              '퀴즈 시작 안내',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppTheme.grey900,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('📚', '이번 챕터는 총 30문제입니다.', isDarkMode),
            SizedBox(height: 12.h),
            _buildInfoRow('⏱️', '약 10-15분 정도 소요됩니다.', isDarkMode),
            SizedBox(height: 12.h),
            _buildInfoRow(
              '⚠️',
              '중간에 나가면 처음부터 다시 풀어야 합니다.',
              isDarkMode,
              isWarning: true,
            ),
            SizedBox(height: 16.h),
            Text(
              '지금 시작하시겠습니까?',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: isDarkMode ? Colors.white : AppTheme.grey900,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(
              '나중에',
              style: TextStyle(
                color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              '시작하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (mounted) {
      if (shouldStart == true) {
        await _startQuiz();
      } else {
        // 나중에 선택 시 교육 탭으로 이동
        context.go(AppRoutes.education);
      }
    }
  }

  /// 안내 정보 행 위젯
  Widget _buildInfoRow(String icon, String text, bool isDarkMode,
      {bool isWarning = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: 16.sp),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: isWarning
                  ? AppTheme.errorColor
                  : (isDarkMode ? AppTheme.grey300 : AppTheme.grey700),
              fontWeight: isWarning ? FontWeight.w600 : FontWeight.normal,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 퀴즈 종료 확인 다이얼로그
  Future<bool?> _showExitConfirmDialog() {
    final isDarkMode = ThemeUtils.isDarkMode(context);

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          '퀴즈를 종료하시겠습니까?',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppTheme.grey900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '현재까지 푼 문제는 저장되지 않습니다.',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkMode ? AppTheme.grey300 : AppTheme.grey700,
                height: 1.4,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '처음부터 다시 풀어야 합니다.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              '계속 풀기',
              style: TextStyle(
                color: AppTheme.successColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: Text(
              '나가기',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizNotifierProvider);

    return PopScope(
      canPop: false, // 자동 뒤로가기 차단
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // 이미 pop된 경우 무시

        // 단일 퀴즈 모드나 ReadOnly 모드는 경고 없이 바로 나가기
        if (widget.singleQuizId != null || widget.isReadOnly) {
          if (context.mounted) {
            context.go(AppRoutes.education);
          }
          return;
        }

        // 일반 퀴즈 모드: 경고 다이얼로그 표시
        final shouldExit = await _showExitConfirmDialog();
        if (shouldExit == true && context.mounted) {
          context.go(AppRoutes.education);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(context),
        body: () {
          if (quizState.isLoadingQuiz) {
            return _buildLoadingState();
          }

          if (quizState.quizError != null) {
            return QuizErrorWidget(
              title: '퀴즈 로드 실패',
              errorMessage: quizState.quizError!,
              onRetry: _startQuiz,
            );
          }

          final session = quizState.currentQuizSession;
          if (session == null) {
            return _buildEmptyState();
          }

          return _buildQuizContent(context, quizState, session);
        }(),
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
        onPressed: () async {
          // 단일 퀴즈/ReadOnly 모드는 바로 나가기
          if (widget.singleQuizId != null || widget.isReadOnly) {
            context.go(AppRoutes.education);
            return;
          }

          // 일반 퀴즈 모드: 경고 다이얼로그 표시
          final shouldExit = await _showExitConfirmDialog();
          if (shouldExit == true && context.mounted) {
            context.go(AppRoutes.education);
          }
        },
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
    return const Center(child: LoadingWidget());
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
    QuizState quizState,
    session,
  ) {
    final currentQuiz = session.currentQuiz;
    final isDarkMode = ThemeUtils.isDarkMode(context);

    return Column(
      children: [
        // 진행률 표시
        QuizProgressWidget(
          currentIndex: session.currentQuizIndex,
          totalCount: session.totalCount,
          progressRatio: quizState.progressRatio,
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

        // 💡 안내 텍스트 (일반 퀴즈 모드에만 표시)
        if (widget.singleQuizId == null && !widget.isReadOnly)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.1),
              border: Border(
                top: BorderSide(
                  color: AppTheme.warningColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18.sp,
                  color: AppTheme.warningColor,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    '💡 Tip: ${session.totalCount}문제를 모두 완료해야 저장됩니다',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDarkMode
                          ? AppTheme.warningColor.withValues(alpha: 0.9)
                          : AppTheme.warningColor,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 하단 네비게이션
        QuizNavigationWidget(
          showPrevious: session.currentQuizIndex > 0,
          onPrevious: () {
            ref.read(quizNotifierProvider.notifier).moveToPreviousQuiz();
            setState(() {
              _selectedAnswer =
                  session.userAnswers[session.currentQuizIndex - 1];
            });
          },
          actionButton: _buildActionButton(quizState, session),
        ),
      ],
    );
  }

  /// 액션 버튼 빌드
  Widget _buildActionButton(QuizState quizState, session) {
    final hasAnswered = session.userAnswers[session.currentQuizIndex] != null;
    final isLastQuiz = session.currentQuizIndex == session.totalCount - 1;

    if (!hasAnswered) {
      // 답안 제출 버튼
      final canSubmit = _selectedAnswer != null &&
          !_isSubmitting &&
          !quizState.isSubmittingAnswer;
      return ActionButton(
        text:
            _isSubmitting || quizState.isSubmittingAnswer ? '제출 중...' : '답안 제출',
        icon: _isSubmitting || quizState.isSubmittingAnswer
            ? Icons.hourglass_empty
            : Icons.send,
        color: canSubmit ? AppTheme.successColor : Colors.grey,
        onPressed: canSubmit ? () => _submitAnswer() : () {},
      );
    } else if (!isLastQuiz) {
      // 다음 문제 버튼
      return ActionButton(
        text: '다음 문제',
        icon: Icons.arrow_forward,
        color: AppTheme.successColor,
        onPressed: () {
          ref.read(quizNotifierProvider.notifier).moveToNextQuiz();
          setState(() {
            _selectedAnswer = session.userAnswers[session.currentQuizIndex + 1];
          });
        },
      );
    } else {
      // 퀴즈 완료 버튼
      return ActionButton(
        text: _waitingForWrongNoteRemoval ? '처리 중...' : '퀴즈 완료',
        icon: _waitingForWrongNoteRemoval
            ? Icons.hourglass_empty
            : Icons.check_circle,
        color:
            _waitingForWrongNoteRemoval ? Colors.grey : AppTheme.successColor,
        onPressed: _waitingForWrongNoteRemoval ? () {} : () => _completeQuiz(),
      );
    }
  }

  Future<void> _submitAnswer() async {
    final quizState = ref.read(quizNotifierProvider);
    if (_selectedAnswer == null ||
        _isSubmitting ||
        quizState.isSubmittingAnswer) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await ref
          .read(quizNotifierProvider.notifier)
          .submitAnswer(_selectedAnswer!);
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

  Future<void> _completeQuiz() async {
    final result = await ref.read(quizNotifierProvider.notifier).completeQuiz();

    if (result != null && mounted) {
      if (widget.singleQuizId != null) {
        // 🎯 단일 퀴즈 모드
        final quizState = ref.read(quizNotifierProvider);
        final session = quizState.currentQuizSession;
        if (session != null && session.quizList.isNotEmpty) {
          final quiz = session.quizList.first;
          final userAnswer = session.userAnswers.first;
          final isCorrect = userAnswer == quiz.correctAnswerIndex;

          // 🚨 ReadOnly 모드 완료 처리 (무한루프 방지!)
          if (quizState.isReadOnlyMode) {
            debugPrint('📖 [QUIZ_SCREEN] ReadOnly 퀴즈 완료 - 복습 모드 종료');

            // 🕐 잠깐 대기 후 오답노트로 이동 (자동 퀴즈 시작 방지)
            await Future.delayed(const Duration(milliseconds: 500));

            // 🛡️ ReadOnly 모드 해제 후 안전하게 오답노트로 이동
            ref.read(quizNotifierProvider.notifier).exitQuiz();
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
