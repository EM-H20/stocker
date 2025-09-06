import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/config/app_routes.dart';
import '../../../app/config/app_theme.dart';
import 'quiz_provider.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key, required this.chapterId});

  final int chapterId;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _loadQuizResults();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  void _loadQuizResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadQuizResults(widget.chapterId);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
            return _buildErrorState();
          }

          final result = provider.quizResults.first;

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildResultCard(result, isDarkMode),
                          SizedBox(height: 40.h),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildResultCard(result, bool isDarkMode) {
    final isAllCorrect = result.correctAnswers == result.totalQuestions;
    final cardColor = isDarkMode ? AppTheme.grey800 : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppTheme.grey900;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 완료 아이콘
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: isAllCorrect ? AppTheme.successColor : AppTheme.warningColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAllCorrect ? Icons.celebration : Icons.thumb_up,
              size: 40.sp,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // 제목
          Text(
            isAllCorrect ? '완벽해요!' : '수고했어요!',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // 점수 표시
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              children: [
                TextSpan(text: '${result.correctAnswers}'),
                TextSpan(
                  text: ' / ${result.totalQuestions}',
                  style: TextStyle(
                    color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
                    fontSize: 36.sp,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            '${result.scorePercentage}% 정답',
            style: TextStyle(
              fontSize: 18.sp,
              color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // 등급 표시
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _getGradeColor(result.grade).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _getGradeColor(result.grade),
                width: 2,
              ),
            ),
            child: Text(
              '등급: ${result.grade}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _getGradeColor(result.grade),
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
        _buildCustomButton(
          text: '다시 풀기',
          onPressed: () {
            context.go('${AppRoutes.quiz}?chapterId=${widget.chapterId}');
          },
          backgroundColor: AppTheme.primaryColor,
          textColor: Colors.white,
        ),
        SizedBox(height: 16.h),
        _buildCustomButton(
          text: '교육으로 돌아가기',
          onPressed: () => context.go(AppRoutes.education),
          backgroundColor: Colors.transparent,
          textColor: AppTheme.primaryColor,
          borderColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: borderColor != null ? BorderSide(color: borderColor, width: 2) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: backgroundColor == Colors.transparent ? 0 : 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppTheme.grey900;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80.sp,
              color: AppTheme.errorColor,
            ),
            SizedBox(height: 24.h),
            Text(
              '퀴즈 결과를 불러올 수 없어요',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '네트워크 연결을 확인하고\n다시 시도해주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
              ),
            ),
            SizedBox(height: 32.h),
            _buildCustomButton(
              text: '다시 시도',
              onPressed: () {
                context.read<QuizProvider>().loadQuizResults(widget.chapterId);
              },
              backgroundColor: AppTheme.primaryColor,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return AppTheme.successColor;
      case 'B':
        return AppTheme.primaryColor;
      case 'C':
        return AppTheme.warningColor;
      case 'D':
        return Colors.orange;
      case 'F':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}