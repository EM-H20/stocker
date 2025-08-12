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

  const CurrentLearningCard({
    super.key,
    required this.title,
    required this.description,
    this.onTheoryPressed,
    this.onQuizPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 현재 진행 학습 정보 카드 위젯
    return Card(
      elevation: 4,
      color: AppTheme.darkSurface,
      shadowColor: AppTheme.grey900.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w), // 기존 20.w에서 확대
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 챕터 헤더
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: AppTheme.primaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '현재 진행 학습',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
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
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h), // 기존 8.h에서 확대
            // 챕터 설명
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.grey400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h), // ActionButton을 위한 공간
            // ActionButton 추가
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    text: '이론 학습',
                    icon: Icons.book_outlined,
                    color: AppTheme.primaryColor, // app_theme.dart의 색상 사용
                    // 아래 코드 해석 :
                    // onTheoryPressed가 null이면 debugPrint('이론 학습 클릭')을 실행
                    // 그렇지 않으면 onTheoryPressed를 실행
                    onPressed: onTheoryPressed ?? () => debugPrint('이론 학습 클릭'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ActionButton(
                    text: '퀴즈 풀기',
                    icon: Icons.quiz_outlined,
                    color: AppTheme.successColor, // app_theme.dart의 성공색 사용
                    onPressed: onQuizPressed ?? () => debugPrint('퀴즈 풀기 클릭'),
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
