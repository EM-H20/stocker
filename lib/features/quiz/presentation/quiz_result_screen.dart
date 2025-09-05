import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/config/app_routes.dart';
import '../../../app/config/app_theme.dart';
import 'quiz_provider.dart';
import 'widgets/quiz_result_card_widget.dart';
import 'widgets/quiz_result_stats_widget.dart';
import 'widgets/quiz_result_history_widget.dart';
import 'widgets/quiz_result_actions_widget.dart';
import 'widgets/quiz_result_error_widget.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key, required this.chapterId});

  final int chapterId;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadQuizResults();
  }

  void _setupAnimations() {
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 애니메이션 시작
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _scoreAnimationController.forward();
    });
  }

  void _loadQuizResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadQuizResults(widget.chapterId);
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
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
          '퀴즈 결과',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppTheme.grey900,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingResults) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.successColor),
            );
          }

          if (provider.resultsError != null || provider.quizResults.isEmpty) {
            return const QuizResultErrorWidget(
              message: '퀴즈 결과를 불러올 수 없습니다.',
            );
          }

          final latestResult = provider.quizResults.first;

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // 결과 카드
                  QuizResultCardWidget(
                    result: latestResult,
                    scoreAnimation: _scoreAnimation,
                  ),

                  SizedBox(height: 24.h),

                  // 상세 통계
                  QuizResultStatsWidget(result: latestResult),

                  SizedBox(height: 24.h),

                  // 이전 결과 목록
                  if (provider.quizResults.length > 1)
                    QuizResultHistoryWidget(
                      previousResults: provider.quizResults.skip(1).toList(),
                    ),

                  SizedBox(height: 32.h),

                  // 액션 버튼들
                  QuizResultActionsWidget(chapterId: widget.chapterId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
