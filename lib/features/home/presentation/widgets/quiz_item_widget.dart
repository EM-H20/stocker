import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

/// 개별 퀴즈 아이템 위젯
class QuizItemWidget extends StatelessWidget {
  final int number;
  final String question;
  final VoidCallback? onAnswerO;
  final VoidCallback? onAnswerX;

  const QuizItemWidget({
    super.key,
    required this.number,
    required this.question,
    this.onAnswerO,
    this.onAnswerX,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.grey800.withValues(alpha: 0.5)
            : AppTheme.grey200,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // 질문 헤더
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 원
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.grey700
                      : AppTheme.grey400,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // 질문 텍스트
              Expanded(
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppTheme.grey900,
                      ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // O/X 버튼들
          Row(
            children: [
              // O 버튼
              Expanded(
                child: GestureDetector(
                  onTap: onAnswerO,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.grey100.withValues(alpha: 0.95)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.grey300
                            : AppTheme.grey300,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .shadowColor
                              .withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'O',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // X 버튼
              Expanded(
                child: GestureDetector(
                  onTap: onAnswerX,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.grey100.withValues(alpha: 0.95)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.grey300
                            : AppTheme.grey300,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .shadowColor
                              .withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'X',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
