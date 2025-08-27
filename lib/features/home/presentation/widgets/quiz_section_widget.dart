import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import 'quiz_item_widget.dart';

/// 메인 대시보드 퀴즈 섹션 위젯
class QuizSectionWidget extends StatelessWidget {
  const QuizSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Text(
            '오늘의 퀴즈',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.grey900,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // 퀴즈 컨테이너
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.grey700.withValues(alpha: 0.3)
                    : AppTheme.grey300.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 퀴즈 1
                QuizItemWidget(
                  number: 1,
                  question: "주식 투자에서 분산투자는 위험을 줄이는 효과적인 방법이다.",
                  onAnswerO: () => _handleAnswer(context, 1, true),
                  onAnswerX: () => _handleAnswer(context, 1, false),
                ),
                
                SizedBox(height: 16.h),
                
                // 퀴즈 2
                QuizItemWidget(
                  number: 2,
                  question: "ETF는 개별 주식보다 항상 더 안전한 투자 방법이다.",
                  onAnswerO: () => _handleAnswer(context, 2, true),
                  onAnswerX: () => _handleAnswer(context, 2, false),
                ),
                
                SizedBox(height: 16.h),
                
                // 퀴즈 3
                QuizItemWidget(
                  number: 3,
                  question: "투자할 때는 모든 자금을 한 번에 투입하기보다는 시간을 나누어 투자하는 것이 좋다.",
                  onAnswerO: () => _handleAnswer(context, 3, true),
                  onAnswerX: () => _handleAnswer(context, 3, false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 퀴즈 답변 처리
  void _handleAnswer(BuildContext context, int quizNumber, bool isTrue) {
    // TODO: 실제 퀴즈 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '퀴즈 $quizNumber번: ${isTrue ? "O" : "X"} 선택됨',
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: isTrue ? AppTheme.successColor : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}