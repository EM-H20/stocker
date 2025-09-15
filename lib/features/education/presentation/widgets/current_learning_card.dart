import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/action_button.dart';

// 현재 진행 학습 정보 카드 위젯
class CurrentLearningCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTheoryPressed;
  final VoidCallback? onQuizPressed;
  final bool isTheoryCompleted; // 이론학습 완료 여부

  const CurrentLearningCard({
    super.key,
    required this.title,
    required this.description,
    this.onTheoryPressed,
    this.onQuizPressed,
    this.isTheoryCompleted = false, // 기본값은 미완료
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 현재 진행 학습 정보 카드 위젯
    return Card(
      elevation: 4,
      color: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(20.w), // 기존 20.w에서 확대
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 챕터 헤더
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '현재 진행 학습',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.grey900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h), // 기존 16.h에서 확대
            // 챕터 제목
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : AppTheme.grey900,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h), // 기존 8.h에서 확대
            // 챕터 설명
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h), // ActionButton을 위한 공간
            // ActionButton 추가 - 동일한 크기로 통일
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    text: '이론 학습',
                    icon: Icons.book_outlined,
                    color: theme.brightness == Brightness.dark
                        ? AppTheme.infoColor
                        : Theme.of(context).primaryColor,
                    onPressed: onTheoryPressed ?? () => debugPrint('이론 학습 클릭'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: isTheoryCompleted
                      ? ActionButton(
                          text: '학습용 퀴즈',
                          icon: Icons.quiz_outlined,
                          color: theme.brightness == Brightness.dark
                              ? AppTheme.successColor
                              : AppTheme.successColor,
                          onPressed: onQuizPressed ?? () => debugPrint('퀴즈 풀기 클릭'),
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            color: AppTheme.grey300.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppTheme.grey400.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: AppTheme.grey500,
                                size: 20.sp,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '이론학습 먼저',
                                style: TextStyle(
                                  color: AppTheme.grey500,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '완료해주세요 📚',
                                style: TextStyle(
                                  color: AppTheme.grey500,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
