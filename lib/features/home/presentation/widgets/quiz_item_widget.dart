import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/utils/theme_utils.dart';

/// 개별 퀴즈 아이템 위젯 (선택 상태 및 비활성화 지원)
class QuizItemWidget extends StatelessWidget {
  final int number;
  final String question;
  final bool? selectedAnswer; // true: O 선택, false: X 선택, null: 선택 안함
  final VoidCallback onAnswerO;
  final VoidCallback onAnswerX;
  final bool isEnabled; // 활성화 여부

  const QuizItemWidget({
    super.key,
    required this.number,
    required this.question,
    this.selectedAnswer,
    required this.onAnswerO,
    required this.onAnswerX,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDarkMode(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark 
            ? AppTheme.grey800.withValues(alpha: 0.3)
            : AppTheme.grey50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark 
              ? AppTheme.grey700.withValues(alpha: 0.5)
              : AppTheme.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문제 번호와 질문
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 문제 번호
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              
              // 질문 텍스트
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppTheme.grey900,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // O/X 버튼
          Row(
            children: [
              const Spacer(),
              
              // O 버튼
              _buildAnswerButton(
                context: context,
                label: 'O',
                isSelected: selectedAnswer == true,
                onTap: isEnabled ? onAnswerO : null,
                color: AppTheme.successColor,
              ),
              
              SizedBox(width: 16.w),
              
              // X 버튼
              _buildAnswerButton(
                context: context,
                label: 'X', 
                isSelected: selectedAnswer == false,
                onTap: isEnabled ? onAnswerX : null,
                color: AppTheme.errorColor,
              ),
              
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  /// O/X 답변 버튼 생성
  Widget _buildAnswerButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
    required Color color,
  }) {
    final isDark = ThemeUtils.isDarkMode(context);
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : isDisabled
                  ? (isDark ? AppTheme.grey700 : AppTheme.grey300)
                  : (isDark ? AppTheme.grey800 : Colors.white),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? color
                : isDisabled
                    ? (isDark ? AppTheme.grey600 : AppTheme.grey400)
                    : (isDark ? AppTheme.grey600 : AppTheme.grey300),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : !isDisabled
                  ? [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : isDisabled
                      ? (isDark ? AppTheme.grey500 : AppTheme.grey500)
                      : (isDark ? Colors.white : AppTheme.grey900),
            ),
          ),
        ),
      ),
    );
  }
}