import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/action_button.dart';
import '../../../../app/core/widgets/app_card.dart';

// 현재 진행 학습 정보 카드 위젯
class CurrentLearningCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTheoryPressed;
  final VoidCallback? onQuizPressed;
  final bool isTheoryCompleted; // 이론학습 완료 여부
  final bool isSelectedChapter; // 선택된 챕터 여부
  final VoidCallback? onClearSelection; // 선택 해제 콜백

  const CurrentLearningCard({
    super.key,
    required this.title,
    required this.description,
    this.onTheoryPressed,
    this.onQuizPressed,
    this.isTheoryCompleted = false, // 기본값은 미완료
    this.isSelectedChapter = false, // 기본값은 선택되지 않음
    this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 현재 진행 학습 정보 카드 위젯
    return AppCard(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 챕터 헤더
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSelectedChapter
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  isSelectedChapter ? Icons.star : Icons.trending_up,
                  color: isSelectedChapter
                      ? AppTheme.successColor
                      : (theme.brightness == Brightness.dark
                          ? Colors.white
                          : Theme.of(context).primaryColor),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  isSelectedChapter ? '선택된 챕터' : '현재 진행 학습',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : AppTheme.grey900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 선택된 챕터일 때만 선택 해제 버튼 표시
              if (isSelectedChapter && onClearSelection != null)
                GestureDetector(
                  onTap: onClearSelection,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppTheme.infoColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 14.sp,
                          color: AppTheme.infoColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '다른 챕터',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.infoColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                        onPressed:
                            onQuizPressed ?? () => debugPrint('퀴즈 풀기 클릭'),
                      )
                    : Container(
                        height: 48.h, // ActionButton과 동일한 높이로 통일
                        decoration: BoxDecoration(
                          color: AppTheme.grey300.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppTheme.grey400.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: AppTheme.grey500,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '이론학습 먼저',
                                  style: TextStyle(
                                    color: AppTheme.grey500,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '완료해주세요 📚',
                                  style: TextStyle(
                                    color: AppTheme.grey500,
                                    fontSize: 9.sp,
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
        ],
      ),
    );
  }
}
