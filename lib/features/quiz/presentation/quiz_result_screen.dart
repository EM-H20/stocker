import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/config/app_routes.dart';
import '../../../app/core/widgets/action_button.dart';
import 'quiz_provider.dart';
import '../domain/models/quiz_result.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRoutes.education),
        ),
        title: Text(
          '퀴즈 결과',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingResults) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            );
          }

          if (provider.resultsError != null || provider.quizResults.isEmpty) {
            return Center(
              child: Text(
                '퀴즈 결과를 불러올 수 없습니다.',
                style: TextStyle(color: Colors.white70, fontSize: 16.sp),
              ),
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
                  _buildResultCard(latestResult),

                  SizedBox(height: 24.h),

                  // 상세 통계
                  _buildDetailStats(latestResult),

                  SizedBox(height: 24.h),

                  // 이전 결과 목록
                  if (provider.quizResults.length > 1)
                    _buildPreviousResults(
                      provider.quizResults.skip(1).toList(),
                    ),

                  SizedBox(height: 32.h),

                  // 액션 버튼들
                  _buildActionButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(QuizResult result) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              result.isPassed
                  ? [
                    const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  ]
                  : [
                    const Color(0xFFF44336).withValues(alpha: 0.2),
                    const Color(0xFFC62828).withValues(alpha: 0.1),
                  ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              result.isPassed
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF44336),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // 합격/불합격 아이콘
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  result.isPassed
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
            ),
            child: Icon(
              result.isPassed ? Icons.check : Icons.close,
              color: Colors.white,
              size: 40.sp,
            ),
          ),

          SizedBox(height: 16.h),

          // 합격/불합격 텍스트
          Text(
            result.isPassed ? '합격!' : '불합격',
            style: TextStyle(
              color:
                  result.isPassed
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),

          // 점수 애니메이션
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              final animatedScore =
                  (result.scorePercentage * _scoreAnimation.value).toInt();
              return Text(
                '$animatedScore점',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),

          SizedBox(height: 4.h),

          // 등급
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _getGradeColor(result.grade).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: _getGradeColor(result.grade), width: 1),
            ),
            child: Text(
              '등급: ${result.grade}',
              style: TextStyle(
                color: _getGradeColor(result.grade),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStats(QuizResult result) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상세 통계',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16.h),

          _buildStatRow('전체 문제', '${result.totalQuestions}문제'),
          _buildStatRow('정답', '${result.correctAnswers}문제', Colors.green),
          _buildStatRow('오답', '${result.wrongAnswers}문제', Colors.red),
          _buildStatRow('정답률', '${(result.accuracyRate * 100).toInt()}%'),
          _buildStatRow('소요 시간', result.formattedTimeSpent),
          _buildStatRow(
            '완료 시간',
            '${result.completedAt.month}/${result.completedAt.day} '
                '${result.completedAt.hour.toString().padLeft(2, '0')}:'
                '${result.completedAt.minute.toString().padLeft(2, '0')}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousResults(List<QuizResult> previousResults) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이전 결과',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16.h),

          ...previousResults
              .take(5)
              .map(
                (result) => Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${result.completedAt.month}/${result.completedAt.day} '
                            '${result.completedAt.hour.toString().padLeft(2, '0')}:'
                            '${result.completedAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${result.correctAnswers}/${result.totalQuestions} 정답',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${result.scorePercentage}점',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  result.isPassed
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              result.isPassed ? '합격' : '불합격',
                              style: TextStyle(
                                color:
                                    result.isPassed ? Colors.green : Colors.red,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // 다시 풀기 버튼
        ActionButton(
          text: '다시 풀기',
          icon: Icons.refresh,
          color: const Color(0xFF4CAF50),
          onPressed:
              () =>
                  context.go('${AppRoutes.quiz}?chapterId=${widget.chapterId}'),
        ),

        SizedBox(height: 12.h),

        // 교육 탭으로 돌아가기 버튼
        ActionButton(
          text: '교육 탭으로 돌아가기',
          icon: Icons.home,
          color: Colors.grey[600]!,
          onPressed: () => context.go(AppRoutes.education),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return const Color(0xFF4CAF50);
      case 'B':
        return const Color(0xFF2196F3);
      case 'C':
        return const Color(0xFFFF9800);
      case 'D':
        return const Color(0xFFFF5722);
      case 'F':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }
}
